{ pkgs
, unstable
, ...
}:
{
  home.packages = [
    pkgs.ffmpeg
    pkgs.mp4v2
    pkgs.poetry
    pkgs.python310
    pkgs.rclone
    # unstable.llama-cpp
    # unstable.openai-whisper-cpp
    unstable.bun
    unstable.nodejs_24 # For claude-code
    unstable.rustup
    unstable.uv
    unstable.zig # For cargo-zigbuild
  ];
}
