{ config
, home
, ...
}: {
  home.file.".git-credentials" = age.secrets.git-credentials.path;
}
