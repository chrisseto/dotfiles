{ pkgs
, lib
, config
, ...
}:
let
  basePath = "${config.home.homeDirectory}/.nixpkgs/home-modules/claude";
  symlink = config.lib.file.mkOutOfStoreSymlink;
in
{

  home.packages = [
    pkgs.jq
  ];

  home.file = {
    ".claude/CLAUDE.md".source = symlink "${basePath}/CLAUDE.md";
    ".claude/settings.json".source = symlink "${basePath}/settings.json";
    # Hooks and skills have individual files linked so home-manager doesn't
    # clobber anything that was installed by claude.
  } // lib.concatMapAttrs
    (path: _type: {
      ".claude/skills/${path}".source = symlink "${basePath}/skills/${path}";
    })
    (builtins.readDir ./skills)
  // lib.concatMapAttrs
    (path: _type: {
      ".claude/hooks/${path}".source = symlink "${basePath}/hooks/${path}";
    })
    (builtins.readDir ./hooks);
}
