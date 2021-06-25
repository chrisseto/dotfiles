function fish_prompt
 if set -q SSH_CLIENT; or set -q SSH_TTY
   set_color green
   echo -n (prompt_pwd)
   set_color blue
   echo -n " ❯❯❯ "
 else
   set_color blue
   echo -n (prompt_pwd)
   set_color red
   echo -n " ❯"
   set_color yellow
   echo -n "❯"
   set_color green
   echo -n "❯ "
 end
set_color normal
end
