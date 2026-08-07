{ pkgs
, inputs
, ezModules
, ...
}:
let
  unstable = import inputs.nixpkgs-unstable { inherit (pkgs) system; };
in
{

  imports = [
    ezModules.nvim
  ];

  home.packages = [
    pkgs.ffmpeg
    pkgs.mp4v2
    pkgs.poetry
    pkgs.python310
    pkgs.rclone
    # unstable.llama-cpp
    # unstable.openai-whisper-cpp
    unstable.bun
    unstable.rustup
    unstable.uv
    unstable.zig # For cargo-zigbuild
  ];
}
