let
  # Users
  chrisseto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIClQd+Mx8j4tLqk/a2s705FlLPfEbXbXpMeUCcuwDqZ8";

  # Machines
  asahi-mini = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILsMS9pGBFELlWSTzSm6GfzGSazfi6s8MwdiqcemnKpH";
  personal-air = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDc1g7RE9FGTqmCis62U/ChQa1gpBr4EZKLl1ASm93o/";
in
{
  # Secrets to be managed by agenix.
  # 1. Add secrets to this file in the form: "path/to/file".publicKeys = [readers];
  # 2. Modify the secret: `nix run github:ryantm/agenix -- e path/to/file`

  "assets/secrets/memento-deploy-key.age".publicKeys = [ asahi-mini personal-air ];
  "nixos-modules/silverbullet/seto-world-cloudflare-token.age".publicKeys = [ personal-air asahi-mini ];
}
