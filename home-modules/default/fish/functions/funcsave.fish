# Wraps fish's funcsave to save into ~/.nixpkgs: back to the module a function
# was loaded from, or, for new functions, the most specific module on
# $fish_function_path. An explicit -d is respected.
source $__fish_data_dir/functions/funcsave.fish
functions -c funcsave __fish_funcsave_stock

function funcsave --description "Save the current definition of all specified functions to file"
    argparse -n funcsave --ignore-unknown d/directory= -- $argv
    or return

    if set -q _flag_directory
        __fish_funcsave_stock -d $_flag_directory $argv
        return
    end

    set -l repo_dirs (string match -- "$HOME/.nixpkgs/*" $fish_function_path)
    set -l flags (string match -- '-*' $argv)
    set -l names (string match -v -- '-*' $argv)
    if not set -q names[1]
        __fish_funcsave_stock $flags
        return
    end

    set -l retval 0
    for funcname in $names
        set -l funcdir $repo_dirs[1]
        set -l src (functions -D -- $funcname 2>/dev/null)
        if contains -- (path dirname -- $src) $repo_dirs
            set funcdir (path dirname -- $src)
        else if not functions -q -- $funcname
            # NB: Erased functions have no source; find their file so it's removed.
            for dir in $repo_dirs
                if test -e $dir/$funcname.fish
                    set funcdir $dir
                    break
                end
            end
        end

        if test -n "$funcdir"
            __fish_funcsave_stock $flags -d $funcdir -- $funcname
        else
            __fish_funcsave_stock $flags -- $funcname
        end
        or set retval 1
    end
    return $retval
end
