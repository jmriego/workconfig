# workconfig

The document expects the repository to be cloned to $HOME/workconfig

## TMUX
It uses the code for the amazing *tmux_picker* plugin but makes some custom changes to it. Mainly to allow for easy parameterizing of patterns.

* \<Prefix>f copy/open files
* \<Prefix>u copy/open urls
* \<Prefix>h copy/open hashes

When you get hints next to each fie/url/hash, type it to copy/paste it with tmux. Or type in uppercase to open it with the OS

### Installation of TMUX config
    setenv -g TMUX_CONF_DIR $HOME/workconfig/tmux
    source-file $HOME/workconfig/_tmux.conf
