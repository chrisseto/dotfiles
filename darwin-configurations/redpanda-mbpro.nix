{ config, ... }: {

  nix.enable = true;
  nix.optimise.automatic = true;
  nix.gc.automatic = true;

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.chrisseto = {
    name = "chrisseto";
    home = "/Users/chrisseto";
  };

  # envtest (controller-runtime) regularly leaks etcd and kube-apiserver
  # processes when a test binary dies without cleaning up after itself. They
  # never live longer than a test run, so anything older than 90s is a leak.
  launchd.user.agents.reap-envtest = {
    serviceConfig = {
      RunAtLoad = true;
      StartInterval = 60; # Seconds.
      ProcessType = "Background";
      # launchd does not expand ~ or $HOME, so the path has to be absolute.
      StandardOutPath = "${config.users.users.chrisseto.home}/Library/Logs/reap-envtest.log";
      StandardErrorPath = "${config.users.users.chrisseto.home}/Library/Logs/reap-envtest.log";
    };

    script = ''
      max=90 # Seconds.
      now=$(/bin/date +%s)

      for name in etcd kube-apiserver; do
        for pid in $(/usr/bin/pgrep -x -U "$(/usr/bin/id -u)" "$name"); do
          # macOS ps has no `etimes`, so ages are computed from lstart, which is
          # a ctime(3) string: "Wed Aug  6 09:12:33 2026". The day is space
          # padded, hence the squeeze.
          lstart=$(/bin/ps -o lstart= -p "$pid" | /usr/bin/tr -s ' ')
          [ -n "$lstart" ] || continue # Exited between pgrep and now.

          started=$(/bin/date -j -f '%a %b %d %H:%M:%S %Y ' "$lstart" +%s) || continue
          age=$((now - started))

          if [ "$age" -gt "$max" ]; then
            echo "killing $name (pid: $pid, age: ''${age}s)"
            /bin/kill $pid
          fi
        done
      done
    '';
  };
}
