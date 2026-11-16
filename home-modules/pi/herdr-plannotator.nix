# Plannotator reviews from a headless machine, opened on the computer running
# the Herdr app.
#
# Plannotator serves each review on a random localhost port of the machine pi
# (or the `plannotator` CLI) runs on, then calls $PLANNOTATOR_BROWSER with the
# URL. On a headless box there's no browser, so `herdr-plannotator-browser`
# instead labels the calling herdr-core terminal:
#
#   plannotator.cli-<port> = "review <url>"
#
# The Herdr app's `plannotator` mod (~/.config/herdr-app/mods/plannotator on
# the Mac) watches terminals() for those labels, opens an `ssh -N -L` tunnel
# for the port (a hidden `pnfwd-*` hc terminal) and runs `open` on the URL.
# A detached watcher clears the label once the review's server stops; the mod
# also prunes labels whose port is no longer listening.
#
# Every review, pi extension or CLI, goes through Plannotator's openBrowser()
# once, so this one env var covers both paths. It's set as a session variable
# so it doesn't depend on how pi was started. The script falls back to a real
# browser (or just printing the URL) outside herdr-core or when a display
# exists, so setting it unconditionally on Linux is safe.
{ pkgs, lib, ... }:
let
  browser = pkgs.writeShellApplication {
    name = "herdr-plannotator-browser";
    runtimeInputs = [ pkgs.iproute2 pkgs.gnugrep pkgs.gnused pkgs.util-linux pkgs.coreutils ];
    # `hc` comes from PATH on purpose: it must be the one talking to the
    # running herdr-core.
    text = ''
      url="''${1:-}"
      term="''${HC_TERMINAL_ID:-}"
      port=$(printf '%s' "$url" | sed -nE 's#^https?://[^/]*:([0-9]+).*#\1#p')

      fallback() {
        if { [ -n "''${DISPLAY:-}" ] || [ -n "''${WAYLAND_DISPLAY:-}" ]; } && command -v xdg-open >/dev/null 2>&1; then
          exec xdg-open "$url"
        fi
        printf 'Plannotator: open %s\n' "$url" >&2
        exit 0
      }

      # Not inside a herdr-core terminal, or a local display exists: behave
      # like a normal browser handler.
      if [ -z "$term" ] || [ -z "$port" ] || [ -n "''${DISPLAY:-}" ] || [ -n "''${WAYLAND_DISPLAY:-}" ] \
        || ! command -v hc >/dev/null 2>&1; then
        fallback
      fi

      key="plannotator.cli-$port"
      hc label "$term" "$key=review $url" >/dev/null 2>&1 || fallback

      # Clear the label once the review's server stops. Detached with setsid
      # so it outlives pi / the plannotator CLI exiting or being killed.
      # shellcheck disable=SC2016 # expanded by the inner sh, not here
      setsid sh -c '
        sleep 3
        while ss -ltnH "sport = :$1" 2>/dev/null | grep -q .; do sleep 2; done
        hc label "$2" "$3=" >/dev/null 2>&1
      ' _ "$port" "$term" "$key" </dev/null >/dev/null 2>&1 &
      exit 0
    '';
  };
in
{
  config = lib.mkIf pkgs.stdenv.isLinux {
    home.packages = [ browser ];

    # An explicit value set later (e.g. `PLANNOTATOR_BROWSER=none pi`) still wins.
    home.sessionVariables.PLANNOTATOR_BROWSER = lib.getExe browser;
  };
}
