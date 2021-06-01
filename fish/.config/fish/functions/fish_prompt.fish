function fish_prompt
 set_color blue
 echo -n (prompt_pwd)
 set_color red
 echo -n " ❯"
 set_color yellow
 echo -n "❯"
 set_color green
 echo -n "❯ "
 set_color normal
end
