{ config
, pkgs
, lib
, unstable
, ...
}: {
  home.packages = [
    pkgs.rclone
    # pkgs._1password
    # pkgs.lima
    # pkgs.docker
    pkgs.ffmpeg
    # pkgs.k3d
    pkgs.mp4v2
    pkgs.poetry
    pkgs.python310
    unstable.rustup
    # unstable.llama-cpp
    # unstable.openai-whisper-cpp
  ];
}
