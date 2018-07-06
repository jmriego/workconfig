let g:tmuxline_preset = {
      \'a'    : '#S',
      \'b'    : '#(uname -s | sed -e "s/Linux/ /" -e "s/Darwin/ /")#(echo "#T" | sed "s/:.*//")',
      \'c'    : '#(echo "#T" | sed "s/.*://" )',
      \'win'  : '#I #W #F',
      \'cwin' : '#I #W #F',
      \'x'    : ' %a %F',
      \'y'    : ' %R',
      \'z'    : '#(~/workconfig/zsh/prompt/taskwarrior.zsh)'}
