# Completions for `wt` (files/bin/wt). Suggests the subcommand first, then the
# worktree names that the repo in the current directory actually has.

# `wt ls` separates its columns with tabs when stdout is not a terminal, so the
# first field is the name on its own.
function __wt_worktree_names
    wt ls 2>/dev/null | cut -f1
end

set -l wt_commands new create rm remove ls list cd vs code sync
set -l wt_no_subcommand "not __fish_seen_subcommand_from $wt_commands"
set -l wt_takes_name '__fish_seen_subcommand_from rm remove cd vs code sync'

complete -c wt -f

complete -c wt -n "$wt_no_subcommand" -a new -d 'create a worktree, print its path'
complete -c wt -n "$wt_no_subcommand" -a rm -d 'remove a worktree'
complete -c wt -n "$wt_no_subcommand" -a ls -d 'list every worktree of the repo'
complete -c wt -n "$wt_no_subcommand" -a cd -d "print a worktree's path"
complete -c wt -n "$wt_no_subcommand" -a vs -d 'open a worktree in VS Code'
complete -c wt -n "$wt_no_subcommand" -a sync -d 're-link .wt/include'

complete -c wt -s h -l help -d 'show usage'
complete -c wt -n "__fish_seen_subcommand_from $wt_commands" -s p -l project -r -F \
    -d 'project to act on'
complete -c wt -n '__fish_seen_subcommand_from new create' -s w -l worktrees-base-dir -r -F \
    -d 'where new puts worktrees'

complete -c wt -n "$wt_takes_name" -a '(__wt_worktree_names)' -d worktree
