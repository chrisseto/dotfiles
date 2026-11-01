{ pkgs, ... }: {
  programs.zsh.enable = true;
  programs.fish.enable = true;

  environment.shells = [ pkgs.fish pkgs.bash pkgs.zsh ];
  users.defaultUserShell = pkgs.fish;

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    trusted-users = [ "root" "@wheel" ];
    experimental-features = [ "nix-command" "flakes" ];
  };

  environment.systemPackages = with pkgs; [
    vim
  ];
}
