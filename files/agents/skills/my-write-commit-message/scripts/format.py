#!/usr/bin/env python3
"""Assemble and format a commit message from a draft.

This script owns every deterministic detail — subject validation, 72-column
body wrapping, blank-line separators, and the Fixes block. Invalid structure
is impossible to emit; the caller only has to write good content.

The draft is read from stdin: the first line is the subject, and everything
after it (leading blank lines ignored) is the body, with blank lines separating
paragraphs. Reading the whole draft from stdin — rather than passing the subject
as an argument — means apostrophes and `backtick identifiers` in *either* the
subject or the body are never mangled by shell quoting, as long as a quoted
heredoc is used. Fixes are passed as arguments because URLs have no characters
the shell will touch.

    format.py -f https://tracker.example.com/SEC-204 <<'EOF'
    Reject empty values for `apiKey` config

    A blank `apiKey` silently disabled authentication instead of failing,
    leaving deployments unexpectedly open.
    EOF

On success the formatted message is written to stdout and the exit code is 0.
On any validation failure nothing is written to stdout, the reason is written
to stderr, and the exit code is non-zero. Because a shell pipeline still runs
the downstream command even when an upstream command fails, do NOT pipe this
straight into a commit command blind. Gate on the exit code first, e.g.:

    msg=$(format.py <<'EOF'
    Subject line
    ...
    EOF
    ) && printf '%s' "$msg" | jj describe --stdin
"""
import argparse
import re
import sys
import unicodedata
from typing import NamedTuple

SUBJECT_LIMIT = 50   # hard cap: the subject is rejected if it exceeds this
BODY_WIDTH = 72      # column the body wraps at (protected tokens may exceed it)

FIXES_URL_RE = re.compile(r"^https?://\S+$")
LIST_RE = re.compile(r"^(\s*)([-*+]|\d+[.)])\s+(.*)$")


def display_width(text: str) -> int:
    """Character count, ignoring zero-width combining marks."""
    return sum(0 if unicodedata.combining(c) else 1 for c in text)


def validate_subject(subject: str) -> list[str]:
    """Return a list of human-readable problems with the subject."""
    problems = []
    stripped = subject.strip()
    if not stripped:
        problems.append("subject is empty")
        return problems
    n = display_width(stripped)
    if n > SUBJECT_LIMIT:
        problems.append(f"subject is {n} chars (max {SUBJECT_LIMIT}); "
                        f"trim {n - SUBJECT_LIMIT}")
    if stripped.endswith("."):
        problems.append("subject ends with a period")
    if stripped.count("`") % 2 != 0:
        problems.append("subject has unbalanced backticks (odd number of `)")
    first = stripped.split(" ", 1)[0].lstrip("`")
    if first and first[0].isalpha() and not first[0].isupper():
        problems.append(f"subject first word is not capitalized: {first!r}")
    return problems


def tokenize(paragraph: str):
    """Split a paragraph into wrap tokens. Whitespace breaks tokens only when
    it falls outside a backtick span, so `foo bar` stays one token and trailing
    punctuation stays glued to its word (`login`. is a single token).

    An odd number of backticks means a span is never closed; the remainder of
    the paragraph would silently collapse into one unbreakable token, so reject
    it instead with a ValueError that main() surfaces on stderr."""
    if paragraph.count("`") % 2 != 0:
        excerpt = paragraph.strip()
        if len(excerpt) > 40:
            excerpt = excerpt[:40] + "…"
        raise ValueError(f"unbalanced backtick (odd number of `) in: {excerpt!r}")
    tokens = []
    char_buf = []
    in_backtick = False
    for ch in paragraph:
        if ch == "`":
            in_backtick = not in_backtick
            char_buf.append(ch)
        elif ch.isspace() and not in_backtick:
            if char_buf:
                tokens.append("".join(char_buf))
                char_buf = []
        else:
            char_buf.append(ch)
    if char_buf:
        tokens.append("".join(char_buf))
    return tokens


def wrap_tokens(tokens, width: int, first_indent: str = "", cont_indent: str = ""):
    """Greedy-fill `tokens` to `width`. `first_indent` is the literal leading
    text of the first line and `cont_indent` the leading text of each wrapped
    continuation line — both are the whole line-opening string (e.g. a list
    marker plus its hanging indent), prepended verbatim, not a decoration. A
    token longer than the available width is never split — it takes its own
    line, so URLs and long backtick spans stay intact."""
    if not tokens:
        return [first_indent.rstrip()] if first_indent.strip() else []
    lines = []
    indent = first_indent
    cur = None
    for tok in tokens:
        if cur is None:
            cur = indent + tok
        elif display_width(cur) + 1 + display_width(tok) <= width:
            cur += " " + tok
        else:
            lines.append(cur)
            indent = cont_indent
            cur = indent + tok
    lines.append(cur)
    return lines


class ListItem(NamedTuple):
    """A Markdown list item being accumulated mid-wrap."""
    first: str          # leading text of the first line (marker + indent)
    cont: str           # leading text of continuation lines (hanging indent)
    content: list[str]  # content fragments, joined when the item is flushed


def wrap_block(block: str, width: int):
    """Wrap one blank-line-delimited block. Prose lines reflow as a paragraph;
    a line opening with a list marker (-, *, +, 1., 1)) starts an item that
    wraps with a hanging indent. Non-marker lines after an item are folded into
    it (lazy continuation), matching how the marker would read in Markdown."""
    out = []
    prose = []          # pending prose lines
    item = None         # pending ListItem being accumulated

    def flush_prose():
        if prose:
            out.extend(wrap_tokens(tokenize(" ".join(prose)), width))
            prose.clear()

    def flush_item():
        nonlocal item
        if item is not None:
            first, cont, content = item
            out.extend(wrap_tokens(tokenize(" ".join(content)), width, first, cont))
            item = None

    for line in block.splitlines():
        m = LIST_RE.match(line)
        if m:
            flush_prose()
            flush_item()
            indent, marker, content = m.groups()
            first = f"{indent}{marker} "
            item = ListItem(first, " " * display_width(first), [content.strip()])
        elif item is not None:
            item.content.append(line.strip())
        elif line.strip():
            prose.append(line.strip())
    flush_prose()
    flush_item()
    return out


def parse_draft(raw: str):
    """Split a raw stdin draft into (subject, body_text). The first line is the
    subject; everything after it (leading blanks ignored) is the body. CRLF and
    lone-CR line endings are normalized to LF up front so no \\r survives into
    the output."""
    raw = raw.replace("\r\n", "\n").replace("\r", "\n")
    text = raw.lstrip("\n")
    newline = text.find("\n")
    if newline == -1:
        return text.strip(), ""
    return text[:newline].strip(), text[newline + 1:]


def build_message(subject: str, body_text: str, fixes: list[str], width: int = BODY_WIDTH) -> str:
    out = [subject.strip()]
    for block in re.split(r"\n\s*\n", body_text.strip("\n")):
        wrapped = wrap_block(block, width)
        if wrapped:
            out.append("")
            out.extend(wrapped)
    if fixes:
        out.append("")
        out.extend(f"Fixes: {url}" for url in fixes)
    return "\n".join(out) + "\n"


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("-f", "--fixes", action="append", default=[], metavar="URL",
                   help="Issue/task URL this commit fixes (repeatable)")
    args = p.parse_args()

    raw = "" if sys.stdin.isatty() else sys.stdin.read()
    subject, body_text = parse_draft(raw)

    errors = validate_subject(subject)
    for url in args.fixes:
        if not FIXES_URL_RE.match(url.strip()):
            errors.append(f"fixes value is not a URL: {url!r}")

    if errors:
        for e in errors:
            print(f"error: {e}", file=sys.stderr)
        return 1

    fixes = [url.strip() for url in args.fixes]
    try:
        message = build_message(subject, body_text, fixes)
    except ValueError as e:
        print(f"error: {e}", file=sys.stderr)
        return 1
    sys.stdout.write(message)
    return 0


if __name__ == "__main__":
    sys.exit(main())
