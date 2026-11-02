function pi-adopt --description "Move pi config files from ~/.pi/agent into ~/.nixpkgs and link them"
    set -l agent ~/.pi/agent
    set -l repo ~/.nixpkgs/home-modules/pi/agent

    # Known state / secrets that should never be adopted.
    set -l ignored auth.json mcp-auth.json models-store.json

    if test (count $argv) -eq 0
        # List unmanaged (non-symlink) top-level config files.
        for f in $agent/*.json $agent/*.md
            test -f $f; or continue
            test -L $f; and continue
            set -l name (basename $f)
            contains -- $name $ignored; and continue
            echo $name
        end
        return
    end

    for f in $argv
        if contains -- (basename $f) $ignored
            echo "pi-adopt: refusing to adopt $f (state/secret)" >&2
            return 1
        end
        if test -L $agent/$f
            echo "pi-adopt: $f is already linked" >&2
            continue
        end
        if not test -e $agent/$f
            echo "pi-adopt: $agent/$f does not exist" >&2
            return 1
        end
        mkdir -p (dirname $repo/$f)
        mv $agent/$f $repo/$f
        # Flakes only see git-tracked files; staging is required for linking.
        git -C ~/.nixpkgs add $repo/$f
        echo "adopted $f"
    end

    echo "Run darwin-rebuild switch --flake ~/.nixpkgs to link." >&2
end
