{ pkgs
, lib
, config
, inputs
, ...
}:
let
  # Everything (git-tracked) under ./agent gets symlinked into ~/.pi/agent.
  # Only configuration lives here; state and secrets (auth.json, sessions/,
  # npm/, git/, memory dirs, ...) stay local in ~/.pi/agent and never enter
  # the repository. Use `pi-adopt` to move new plugin configs into the repo.
  src = ./agent;
  basePath = "${config.home.homeDirectory}/.nixpkgs/home-modules/pi/agent";
  symlink = config.lib.file.mkOutOfStoreSymlink;
  link = rel: { ".pi/agent/${rel}".source = symlink "${basePath}/${rel}"; };

  # Top-level files are linked directly. Directories (skills/, prompts/,
  # extensions/, ...) have their children linked individually so pi and
  # plugins can still write alongside them.
  linkEntry = name: type:
    if type == "directory"
    then lib.concatMapAttrs (child: _: link "${name}/${child}") (builtins.readDir (src + "/${name}"))
    else link name;
in
{
  home.packages = [
    inputs.inspect.packages.${pkgs.system}.default
    inputs.pi.packages.${pkgs.system}.default
    inputs.sem.packages.${pkgs.system}.default
    inputs.weave.packages.${pkgs.system}.default
    pkgs.nodejs # pi shells out to npm to install packages declared in settings.json.
    pkgs.python3 # required for plannotator.
    pkgs.gnumake # required for node-pty

    # Binaries for the npm:@plannotator/pi-extension pi package.
    # TODO: the extension (installed by pi from agent/settings.json) and this
    # binary are versioned independently and can drift apart. Pin the
    # extension to packages/plannotator's version, ideally from its update.sh.
    pkgs.plannotator
  ];

  home.sessionVariables = {
    # Updates come from bumping packages/plannotator, not from the binary
    # replacing itself (it would try to overwrite a read-only store path).
    PLANNOTATOR_UPDATE_CHECK = "0";
  };

  home.file = lib.concatMapAttrs linkEntry (builtins.readDir src);
}
