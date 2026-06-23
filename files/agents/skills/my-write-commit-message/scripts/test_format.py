#!/usr/bin/env python3
"""Tests for format.py.

Zero-dependency: drives format.py as a subprocess through its real CLI, so the
tests exercise stdin draft parsing, validation, wrapping, fixes, and exit codes
exactly as the skill invokes it. The draft (subject + body) is fed on stdin;
only -f/--fixes is an argument.

Run:
    python3 -m unittest test_format          # from the scripts/ directory
    python3 scripts/test_format.py
"""
import os
import subprocess
import sys
import unicodedata
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
SCRIPT = os.path.join(HERE, "format.py")


def display_width(text):
    """Display width, counting combining marks as zero — mirrors format.py so
    wrap assertions pin the real 72-*display*-column contract, not code units.
    Replicated rather than imported to keep the suite black-box."""
    return sum(0 if unicodedata.combining(c) else 1 for c in text)


def run(stdin, args=None):
    proc = subprocess.run(
        [sys.executable, SCRIPT] + (args or []),
        input=stdin,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return proc.returncode, proc.stdout, proc.stderr


def draft(subject, body=None):
    return subject if body is None else f"{subject}\n\n{body}"


def body_lines(out):
    # Lines after the subject and its blank separator.
    return out.rstrip("\n").split("\n")[2:]


class TestSubjectValidation(unittest.TestCase):
    def test_within_limit_passes(self):
        rc, out, _ = run(draft("Add rate limiting"))
        self.assertEqual(rc, 0)
        self.assertEqual(out, "Add rate limiting\n")

    def test_over_50_fails_with_no_stdout(self):
        rc, out, err = run(draft("X" * 51, "body"))
        self.assertEqual(rc, 1)
        self.assertEqual(out, "")  # nothing emitted on failure
        self.assertIn("max 50", err)

    def test_exactly_50_passes(self):
        rc, _, _ = run(draft("X" * 50))
        self.assertEqual(rc, 0)

    def test_trailing_period_fails(self):
        rc, _, err = run(draft("Fix the bug."))
        self.assertEqual(rc, 1)
        self.assertIn("period", err)

    def test_lowercase_first_word_fails(self):
        rc, _, err = run(draft("fix the bug"))
        self.assertEqual(rc, 1)
        self.assertIn("capitalized", err)

    def test_backtick_subject_lowercase_fails(self):
        rc, _, _ = run(draft("`login` is broken"))
        self.assertEqual(rc, 1)

    def test_backtick_subject_capitalized_passes(self):
        rc, _, _ = run(draft("`Login` is fine"))
        self.assertEqual(rc, 0)

    def test_numeric_first_word_skips_capitalization(self):
        # By design the capitalization rule only applies to a leading *letter*.
        # A first word that is not alphabetic (digits, symbols) has no case to
        # check, so it is accepted. Pins that decision against a future change
        # that might start rejecting non-alpha-led subjects.
        rc, _, _ = run(draft("123 rebuild cache"))
        self.assertEqual(rc, 0)

    def test_unbalanced_backtick_subject_fails(self):
        # The subject is emitted verbatim, never wrapped, so the body's
        # per-paragraph guard doesn't cover it; validate_subject must reject a
        # dangling backtick itself.
        rc, out, err = run(draft("Reject empty `config"))
        self.assertEqual(rc, 1)
        self.assertEqual(out, "")
        self.assertIn("backtick", err)

    def test_balanced_backticks_subject_passes(self):
        # Guards the even-count branch: multiple balanced spans must pass.
        rc, _, _ = run(draft("Wire `foo` to `bar`"))
        self.assertEqual(rc, 0)

    def test_combining_marks_not_double_counted(self):
        # Decomposed "letter + combining acute": width 1 each, 2 code units each.
        up, lo = "É", "é"
        rc, _, _ = run(draft(up + lo * 49))  # width 50
        self.assertEqual(rc, 0)
        rc, _, _ = run(draft(up + lo * 50))  # width 51
        self.assertEqual(rc, 1)

    def test_empty_draft_fails(self):
        rc, out, err = run("")
        self.assertEqual(rc, 1)
        self.assertEqual(out, "")
        self.assertIn("subject is empty", err)

    def test_whitespace_only_subject_fails(self):
        for ws in ("   ", "\t", " \t \n "):
            with self.subTest(ws=repr(ws)):
                rc, out, err = run(ws)
                self.assertEqual(rc, 1)
                self.assertEqual(out, "")
                self.assertIn("subject is empty", err)

    def test_multiple_problems_all_reported(self):
        # Too long AND uncapitalized AND trailing period: validate_subject
        # collects every problem, and all must reach stderr together.
        rc, out, err = run(draft("x" * 60 + "."))
        self.assertEqual(rc, 1)
        self.assertEqual(out, "")
        self.assertIn("max 50", err)
        self.assertIn("capitalized", err)
        self.assertIn("period", err)


class TestSubjectQuoting(unittest.TestCase):
    """The reason the subject rides on stdin: backticks and apostrophes must
    survive verbatim, with no shell escaping required of the caller."""

    def test_backtick_and_apostrophe_survive_verbatim(self):
        subject = "Reject empty `apiKey` when it's blank"
        rc, out, _ = run(draft(subject, "A blank value disabled auth."))
        self.assertEqual(rc, 0)
        self.assertEqual(out.split("\n", 1)[0], subject)


class TestBody(unittest.TestCase):
    def test_paragraph_wraps_to_72(self):
        rc, out, _ = run(draft("Subject", "word " * 60))
        self.assertEqual(rc, 0)
        for line in body_lines(out):
            self.assertLessEqual(display_width(line), 72, repr(line))

    def test_combining_mark_paragraph_wraps_by_display_width(self):
        # Decomposed accents are zero-width, so a line can carry more code units
        # than display columns. Wrapping must honor display width: every line
        # stays within 72 columns even though len() would read higher.
        word = "é" * 6   # 6 display cols, 12 code units
        rc, out, _ = run(draft("Subject", (word + " ") * 40))
        self.assertEqual(rc, 0)
        wrapped = False
        for line in body_lines(out):
            self.assertLessEqual(display_width(line), 72, repr(line))
            if len(line) > 72:
                wrapped = True   # a line exceeding 72 code units proves the point
        self.assertTrue(wrapped, "test did not exercise the code-unit/width gap")

    def test_paragraph_content_survives_wrapping(self):
        # Distinct words so a drop, duplicate, or reorder is detectable; enough
        # of them to force several line breaks. The greedy wrap must lose nothing.
        words = [f"w{i}" for i in range(40)]
        rc, out, _ = run(draft("Subject", " ".join(words)))
        self.assertEqual(rc, 0)
        self.assertEqual(" ".join(body_lines(out)).split(), words)

    def test_crlf_input_normalized_to_lf(self):
        rc, out, _ = run("Subject here\r\n\r\nBody text here.\r\n")
        self.assertEqual(rc, 0)
        self.assertNotIn("\r", out)
        self.assertEqual(out, "Subject here\n\nBody text here.\n")

    def test_lone_cr_normalized_to_lf(self):
        # Old-Mac line endings (bare \r, no \n) exercise the second replace in
        # parse_draft, which \r\n input alone never reaches.
        rc, out, _ = run("Subject here\rBody text here.\r")
        self.assertEqual(rc, 0)
        self.assertNotIn("\r", out)
        self.assertEqual(out, "Subject here\n\nBody text here.\n")

    def test_whitespace_only_body_dropped(self):
        # A body of only blank/whitespace lines yields no wrapped block, so
        # build_message emits the subject alone.
        rc, out, _ = run("Subject\n   \n\t  \n")
        self.assertEqual(rc, 0)
        self.assertEqual(out, "Subject\n")

    def test_subject_leading_trailing_spaces_stripped(self):
        rc, out, _ = run(draft("   Subject here   ", "Body."))
        self.assertEqual(out, "Subject here\n\nBody.\n")

    def test_internal_multiple_spaces_collapse(self):
        rc, out, _ = run(draft("Subject", "word  double   spaced  text"))
        self.assertEqual(body_lines(out), ["word double spaced text"])

    def test_consecutive_blank_lines_normalized_to_one(self):
        rc, out, _ = run(draft("Subject", "Para one.\n\n\n\nPara two."))
        self.assertEqual(out, "Subject\n\nPara one.\n\nPara two.\n")

    def test_prose_list_prose_blocks_preserve_order(self):
        rc, out, _ = run(draft("Subject", "First.\n\n- a\n- b\n\nLast."))
        self.assertEqual(out, "Subject\n\nFirst.\n\n- a\n- b\n\nLast.\n")

    def test_blank_line_separates_subject_and_body(self):
        rc, out, _ = run(draft("Subject", "A short body."))
        self.assertEqual(out, "Subject\n\nA short body.\n")

    def test_two_paragraphs_keep_blank_line(self):
        rc, out, _ = run(draft("Subject", "First para.\n\nSecond para."))
        self.assertEqual(out, "Subject\n\nFirst para.\n\nSecond para.\n")

    def test_subject_only_when_no_body(self):
        rc, out, _ = run(draft("Fix typo"))
        self.assertEqual(out, "Fix typo\n")

    def test_missing_blank_after_subject_is_normalized(self):
        rc, out, _ = run("Subject here\nBody on the next line.")
        self.assertEqual(out, "Subject here\n\nBody on the next line.\n")

    def test_backtick_span_with_spaces_kept_whole(self):
        rc, out, _ = run(draft("Subject",
                               "Call `foo bar baz` before you continue here now."))
        self.assertIn("`foo bar baz`", out)

    def test_punctuation_stays_glued_to_backtick(self):
        rc, out, _ = run(draft("Subject", "Rename `getUser`, then ship."))
        self.assertIn("`getUser`,", out)
        self.assertNotIn("`getUser` ,", out)

    def test_long_url_kept_whole_on_own_line(self):
        url = "https://example.com/" + "a" * 90
        rc, out, _ = run(draft("Subject", f"See {url} for details."))
        self.assertIn(url, out)

    def test_unbalanced_backtick_rejected(self):
        # An unclosed span would otherwise swallow the rest of the paragraph
        # into one unbreakable token; reject loudly instead of emitting it.
        rc, out, err = run(draft("Subject", "Call `foo bar baz and continue"))
        self.assertEqual(rc, 1)
        self.assertEqual(out, "")
        self.assertIn("backtick", err)

    def test_unbalanced_backtick_error_omits_full_paragraph(self):
        # The rejection names the problem and points at the start of the
        # offending block, but does not echo the entire (possibly long)
        # paragraph back to stderr.
        tail = "ZZZ" + "z" * 80  # distinctive, lives well past any short excerpt
        rc, out, err = run(draft("Subject", f"Open `span and then keep going {tail}"))
        self.assertEqual(rc, 1)
        self.assertEqual(out, "")
        self.assertIn("backtick", err)
        self.assertNotIn(tail, err)

    def test_unbalanced_backtick_in_list_item_rejected(self):
        # tokenize() also runs on list-item content (a separate code path from
        # prose), so the guard must fire there too.
        rc, out, err = run(draft("Subject", "- Item with `unclosed backtick here"))
        self.assertEqual(rc, 1)
        self.assertEqual(out, "")
        self.assertIn("backtick", err)

    def test_unbalanced_backtick_across_paragraphs_rejected(self):
        # Discriminates per-block checking from a naive whole-body count: the
        # body holds two backticks (even total, which a whole-body count would
        # wave through), but each paragraph has one — a span can't cross the
        # blank line, so both blocks are unbalanced and the first odd one is
        # rejected, never silently mangled.
        rc, out, err = run(draft("Subject", "Open `span here\n\nand close it` later."))
        self.assertEqual(rc, 1)
        self.assertEqual(out, "")
        self.assertIn("backtick", err)

    def test_balanced_backticks_in_each_paragraph_pass(self):
        # The guard is per-block balance, not "any backticks present": two
        # paragraphs each holding a closed span are accepted and kept whole.
        rc, out, _ = run(draft("Subject", "First `alpha` done.\n\nSecond `beta` too."))
        self.assertEqual(rc, 0)
        self.assertIn("`alpha`", out)
        self.assertIn("`beta`", out)


class TestFixes(unittest.TestCase):
    def test_well_formed_fixes_appended(self):
        # Exact match (not endswith): with no body, the blank line separating
        # the subject from the Fixes block must still be present — a regression
        # dropping it would slip past an endswith check.
        rc, out, _ = run(draft("Fix bug"),
                         ["-f", "https://tracker.example.com/T-1",
                          "-f", "https://tracker.example.com/T-2"])
        self.assertEqual(rc, 0)
        self.assertEqual(out,
                         "Fix bug\n\n"
                         "Fixes: https://tracker.example.com/T-1\n"
                         "Fixes: https://tracker.example.com/T-2\n")

    def test_blank_line_before_fixes(self):
        rc, out, _ = run(draft("Fix bug", "Body."), ["-f", "https://x.test/1"])
        self.assertEqual(out, "Fix bug\n\nBody.\n\nFixes: https://x.test/1\n")

    def test_malformed_fixes_fails(self):
        rc, _, err = run(draft("Fix bug"), ["-f", "not-a-url"])
        self.assertEqual(rc, 1)
        self.assertIn("not a URL", err)

    def test_fixes_url_surrounding_whitespace_stripped(self):
        rc, out, _ = run(draft("Fix bug"), ["-f", "  https://x.test/T-1  "])
        self.assertEqual(rc, 0)
        self.assertEqual(out, "Fix bug\n\nFixes: https://x.test/T-1\n")

    def test_fixes_non_http_scheme_rejected(self):
        rc, _, err = run(draft("Fix bug"), ["-f", "ftp://example.com/bug"])
        self.assertEqual(rc, 1)
        self.assertIn("not a URL", err)

    def test_three_fixes_preserve_order(self):
        urls = [f"https://tracker.example.com/T-{i}" for i in (1, 2, 3)]
        args = [a for url in urls for a in ("-f", url)]
        rc, out, _ = run(draft("Fix bug"), args)
        self.assertEqual(rc, 0)
        self.assertTrue(out.endswith("".join(f"Fixes: {u}\n" for u in urls)))

    def test_fixes_url_with_query_and_fragment_intact(self):
        url = "https://x.test/T-1?priority=high&s=open#c-42"
        rc, out, _ = run(draft("Fix bug"), ["-f", url])
        self.assertEqual(rc, 0)
        self.assertIn(f"Fixes: {url}\n", out)


class TestLists(unittest.TestCase):
    def test_unordered_items_not_flattened(self):
        rc, out, _ = run(draft("Subject", "- one\n- two\n- three"))
        self.assertEqual(body_lines(out), ["- one", "- two", "- three"])

    def test_empty_list_item_marker_preserved(self):
        # A content-less marker ("- ") wraps to no tokens; the marker is kept
        # (trailing space stripped) and the following item is unaffected.
        rc, out, _ = run(draft("Subject", "- \n- has content"))
        self.assertEqual(body_lines(out), ["-", "- has content"])

    def test_lead_in_prose_kept_before_list(self):
        rc, out, _ = run(draft("Subject", "Changes:\n- one\n- two"))
        self.assertEqual(body_lines(out), ["Changes:", "- one", "- two"])

    def test_lazy_continuation_folded_into_item(self):
        # A non-marker physical line following a list item is folded into that
        # item (lazy continuation) and the item reflows as one wrapped unit;
        # the next marker starts a fresh item. Pins this live wrap_block branch.
        rc, out, _ = run(draft("Subject", "- First part\n  second part\n- Next item"))
        self.assertEqual(rc, 0)
        self.assertEqual(body_lines(out),
                         ["- First part second part", "- Next item"])

    def test_ordered_item_wraps_with_hanging_indent(self):
        rc, out, _ = run(draft("Subject", "1. " + "word " * 25))
        body = body_lines(out)
        self.assertGreater(len(body), 1)          # the item wrapped
        self.assertTrue(body[0].startswith("1. "))
        for cont in body[1:]:
            self.assertTrue(cont.startswith("   "))   # aligned under the marker
            self.assertFalse(cont.lstrip().startswith("1."))
        for line in body:
            self.assertLessEqual(len(line), 72, repr(line))

    def test_backtick_span_in_item_kept_whole(self):
        rc, out, _ = run(draft("Subject", "- uses `foo bar` in the item"))
        self.assertIn("`foo bar`", out)

    def test_nested_item_indent_preserved(self):
        rc, out, _ = run(draft("Subject", "- top\n  - nested"))
        self.assertEqual(body_lines(out), ["- top", "  - nested"])

    def test_nested_long_item_wraps_with_deeper_indent(self):
        body = "- top level\n  - nested " + "word " * 25
        rc, out, _ = run(draft("Subject", body))
        lines = body_lines(out)
        self.assertEqual(lines[0], "- top level")
        self.assertTrue(lines[1].startswith("  - nested "))
        self.assertGreater(len(lines), 2)              # the nested item wrapped
        for cont in lines[2:]:
            self.assertTrue(cont.startswith("    "))     # 4-space hang under "  - "
            self.assertFalse(cont.lstrip().startswith("-"))

    def test_line_starting_with_marker_is_a_list_item(self):
        # Intended behavior: a physical line beginning with a list marker is
        # treated as a list item, even right after a prose lead-in. The model
        # writes paragraphs as flowing text, so a leading "1. " is a deliberate
        # list, never accidental prose. This test pins that decision.
        rc, out, _ = run(draft("Subject", "Steps:\n1. first\n2. second"))
        self.assertEqual(body_lines(out), ["Steps:", "1. first", "2. second"])

    def test_unordered_item_wraps_with_hanging_indent(self):
        words = [f"w{i}" for i in range(40)]  # distinct words, well over 72 chars
        rc, out, _ = run(draft("Subject", "- " + " ".join(words)))
        body = body_lines(out)
        self.assertGreater(len(body), 1)               # the item wrapped
        self.assertTrue(body[0].startswith("- "))
        for cont in body[1:]:
            self.assertTrue(cont.startswith("  "))      # aligned under the marker
            self.assertFalse(cont.lstrip().startswith(("-", "*", "+")))
        for line in body:
            self.assertLessEqual(len(line), 72, repr(line))
        # content integrity: every word survives, in order, with none added.
        rebuilt = (body[0][2:] + " " + " ".join(c.strip() for c in body[1:])).split()
        self.assertEqual(rebuilt, words)

    def test_all_marker_variants_recognized_and_wrap(self):
        long_words = " ".join(f"w{i}" for i in range(40))  # forces a wrap
        for marker in ["-", "*", "+", "1.", "1)"]:
            with self.subTest(marker=marker):
                # short items stay on their own lines, not flattened into prose
                rc, out, _ = run(draft("Subject", f"{marker} a\n{marker} b"))
                self.assertEqual(body_lines(out), [f"{marker} a", f"{marker} b"])
                # a long item wraps with a hanging indent sized to the marker
                rc, out, _ = run(draft("Subject", f"{marker} {long_words}"))
                body = body_lines(out)
                self.assertGreater(len(body), 1)
                self.assertTrue(body[0].startswith(f"{marker} "))
                indent = " " * len(f"{marker} ")
                for cont in body[1:]:
                    self.assertTrue(cont.startswith(indent))
                self.assertTrue(all(len(line) <= 72 for line in body))

    def test_overlong_token_in_item_kept_whole_and_indented(self):
        url = "https://example.com/" + "a" * 90  # 110 chars, exceeds 72 alone
        rc, out, _ = run(draft("Subject", f"- see {url} now"))
        body = body_lines(out)
        self.assertTrue(body[0].startswith("- "))
        self.assertTrue(any(url in line for line in body))   # never split
        for cont in body[1:]:
            self.assertTrue(cont.startswith("  "))           # hanging indent kept


if __name__ == "__main__":
    unittest.main()
