let
  # Users
  chrisseto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIClQd+Mx8j4tLqk/a2s705FlLPfEbXbXpMeUCcuwDqZ8";

  # Machines
  asahi-mini = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILsMS9pGBFELlWSTzSm6GfzGSazfi6s8MwdiqcemnKpH";
  personal-air = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDc1g7RE9FGTqmCis62U/ChQa1gpBr4EZKLl1ASm93o/";
in {
  "assets/secrets/memento-deploy-key.age".publicKeys = [asahi-mini personal-air];
}
