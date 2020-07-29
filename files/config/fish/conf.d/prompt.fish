function fish_title
    echo -n -s $USER '@' (hostname)
end

function fish_right_prompt
   if not set -q -g __fish_freak_magic_functions_defined
        set -g __fish_freak_magic_functions_defined

        function __git_branch_name
            set -l branch (git branch --show-current 2> /dev/null)
            if [ $branch ]
                echo $branch
            else
                git rev-parse --short HEAD 2> /dev/null
            end
        end

        function __is_git_dirty
            if not git diff-files --no-ext-diff --quiet
                echo 1
            else if not git diff-index --no-ext-diff --quiet --cached HEAD
                echo 2
            else if [ (git ls-files --other --exclude-standard 2> /dev/null) ]
                echo 3
            end
        end

        function __is_git_repo
            type -q git or return 1
            git rev-parse --is-inside-work-tree > /dev/null 2> /dev/null
        end

        function __hg_branch_name
            hg bookmarks 2> /dev/null | grep \* | awk '{print $2}'
        end

        function __is_hg_dirty
            hg status -A 2> /dev/null
        end

        function __is_hg_repo
            type -q hg or return 1
            hg root > /dev/null 2> /dev/null
        end

        function _repo_branch_name
            eval "__$argv[1]_branch_name"
        end

        function _is_repo_dirty
            eval "__is_$argv[1]_dirty"
        end

        function _repo_type
            if __is_hg_repo
                echo 'hg'
            else if __is_git_repo
                echo 'git'
            end
        end
    end

    set -l repo_type (_repo_type)
    if [ $repo_type ]
        set -l repo_branch (_repo_branch_name $repo_type)

        if [ (_is_repo_dirty $repo_type) ]
            set_color -o $fish_color_error
            echo '✗ '
        end
    
        set_color -o $fish_color_cwd
        echo -s '[' $repo_branch ']' 
        set_color normal
    end
end

function fish_prompt
    set -l last_status $status

    # Separator
    set_color -o $fish_color_comment
    echo '————————————————————————————————————————————————————————————'

    # Current Working Directory
    set_color $fish_color_cwd
    echo -n (basename (prompt_pwd))

    # Cursor highlighted with last exit status
    if [ $last_status = 0 ]
        set_color -o $fish_color_status
        echo -n ' ⪢ '
    else
        set_color -o $fish_color_error
        echo -n ' ⩔ '
    end

    set_color normal
end