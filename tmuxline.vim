let g:tmuxline_preset = {
      \'a'    : '#S',
      \'b'    : '#(echo #T | sed "s/:.*//")',
      \'c'    : '#(echo #T | sed "s/.*://" )',
      \'win'  : '#I #W #F',
      \'cwin' : '#I #W #F',
      \'x'    : '%a %F',
      \'y'    : '%R',
      \'z'    : '#H'}


