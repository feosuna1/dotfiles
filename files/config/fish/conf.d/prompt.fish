function fish_title
    echo -n -s $USER '@' (hostname)
end

function fish_right_prompt
   if not set -q -g __fish_freak_magic_functions_defined
        set -g __fish_freak_magic_functions_defined
        function _git_branch_name
            set -l branch (git symbolic-ref --quiet HEAD ^/dev/null)
            if set -q branch[1]
                echo (string replace -r '^refs/heads/' '' $branch)
            else
                echo (git rev-parse --short HEAD ^/dev/null)
            end
        end

        function _is_git_dirty
            echo (git status -s --ignore-submodules=dirty ^/dev/null)
        end

        function _is_git_repo
            type -q git
            or return 1
            git status -s >/dev/null ^/dev/null
        end

        function _hg_branch_name
            echo (hg branch ^/dev/null)
        end

        function _is_hg_dirty
            echo (hg status -mard ^/dev/null)
        end

        function _is_hg_repo
            type -q hg
            or return 1
            hg summary >/dev/null ^/dev/null
        end

        function _repo_branch_name
            eval "_$argv[1]_branch_name"
        end

        function _is_repo_dirty
            eval "_is_$argv[1]_dirty"
        end

        function _repo_type
            if _is_hg_repo
                echo 'hg'
            else if _is_git_repo
                echo 'git'
            end
        end
    end

    set -l repo_type (_repo_type)
    if [ $repo_type ]
        set -l branch_color (set_color -o $fish_color_cwd)
        set -l repo_branch (_repo_branch_name $repo_type)
        set repo_info "$branch_color [$repo_branch]$normal"

        if [ (_is_repo_dirty $repo_type) ]
            set -l status_color (set_color -o $fish_color_error)
            set -l dirty $status_color'✗'
            set repo_info $dirty$repo_info
        end
        echo -n -s $repo_info
    end
end

function fish_prompt
    set -l __last_command_exit_status $status
    set -l normal (set_color -o normal)
    set -l cwd_color (set_color -o $fish_color_cwd)
    set -l cwd_root_color (set_color -o $fish_color_cwd_root)
    set -l success_color (set_color -o $fish_color_status)
    set -l failure_color (set_color -o $fish_color_error)
    set -l separator_color (set_color -o $fish_color_comment)

    set -l cwd $cwd_color(basename (prompt_pwd))

    set -l cursor_color $success_color
    if test $__last_command_exit_status != 0
        set cursor_color $failure_color
    end
    set -l cursor " $cursor_color»$normal"

    echo -s $separator_color "------------------------------------------------------------"
    echo -n -s $cwd $cursor ' '
end
