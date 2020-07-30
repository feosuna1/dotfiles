function fish_title
    echo -n -s $USER '@' (hostname)
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

function __freak_prompt_find_repo_dir
    set -l dir $PWD
    while [ "$dir" != '/' ]; and [ "$dir" != '' ]
        if [ $dir = $HOME ]
            break
        end

        for meta_dir in '.git' '.hg'
            if [ -d "$dir/$meta_dir" ]
                echo "$dir/$meta_dir"
                return
            end
        end

        set dir (realpath (string join -- / (string split -- / "$dir")[1..-2]) 2> /dev/null)
    end
end

function fish_right_prompt
    set -l repo_dir (__freak_prompt_find_repo_dir)
    if [ $repo_dir ]
        set -l scm_info (__freak_prompt_scm_info "$repo_dir")
        set -l repo_type $scm_info[1]
        set -l repo_is_dirty $scm_info[2]
        set -l repo_branch $scm_info[3]

        set -l normal_color (set_color -o normal)
        set -l error_color (set_color -o $fish_color_error)
        set -l cwd_color (set_color -o $fish_color_cwd)

        if [ "$repo_is_dirty" != '0' ]
            echo -n -s $error_color '✗' $normal_color ' '
        end

        echo -n -s $normal_color '[' $cwd_color $repo_type ': '
        if [ $repo_branch ]
            echo -n -s $repo_branch
        else
            echo -n -s $error_color 'none'
        end
        echo -n -s $normal_color ']'
    end
end

function __freak_prompt_scm_info
    switch (string split -- / "$argv[1]")[-1]
        case .git
            echo 'git'
            __freak_prompt_git_is_dirty $argv
            __freak_prompt_git_branch_name $argv
        case .hg
            echo 'hg'
            __freak_prompt_hg_is_dirty $argv
            __freak_prompt_hg_branch_name $argv
        case '*'
            echo 'none'
            echo 'unknown'
            echo 0
    end
end

function __freak_prompt_git_branch_name
    set -l branch (git branch --show-current 2> /dev/null)
    if [ $branch ]
        echo $branch
    else
        git rev-parse --short HEAD 2> /dev/null
    end
end

function __freak_prompt_git_is_dirty
    set -l hide_is_dirty (git config --type bool --get prompt.hide-is-dirty 2> /dev/null)
    if [ "$hide_is_dirty" = 'true' ]
        echo 0
    else
        if not git diff-files --no-ext-diff --quiet
            echo 1
        else if not git diff-index --no-ext-diff --quiet --cached HEAD
            echo 2
        else if [ (git ls-files --other --exclude-standard 2> /dev/null) ]
            echo 3
        else
            echo 0
        end
    end
end

function __freak_prompt_hg_branch_name
    hg bookmarks 2> /dev/null | grep \* | awk '{ print $2 }'
end

function __freak_prompt_hg_is_dirty
    set -l hide_is_dirty (hg config prompt.hide-is-dirty)
    if [ "$hide_is_dirty" = 'true' ]
        echo 0
    else
        if [ (hg status 2> /dev/null) ]
            echo 1
        else
            echo 0
        end
    end
end
