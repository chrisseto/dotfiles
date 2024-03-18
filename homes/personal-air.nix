{ config
, pkgs
, lib
, unstable
, ...
}: {
  home.packages = [
    pkgs._1password
    pkgs.lima
    pkgs.docker
    pkgs.ffmpeg
    pkgs.k3d
    pkgs.kubectl
    pkgs.mp4v2
    pkgs.nodePackages.typescript
    pkgs.nodePackages.typescript-language-server
    pkgs.poetry
    pkgs.pyright
    pkgs.python310
    pkgs.zig
    pkgs.zls
    unstable.llama-cpp
    unstable.openai-whisper-cpp
  ];
}
