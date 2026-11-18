{ pkgs
, inputs
, ezModules
, ...
}:
let
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{

  imports = [
    ezModules.nvim
    ezModules.pi
  ];

  home.packages = [
    pkgs.ffmpeg
    pkgs.mp4v2
    pkgs.poetry
    pkgs.rclone
    # unstable.llama-cpp
    # unstable.openai-whisper-cpp
    unstable.bun
    unstable.rustup
    unstable.uv
    unstable.zig # For cargo-zigbuild
  ];
}
