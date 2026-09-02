if [[ -f $XDG_CONFIG_HOME/dircolors/theme ]]; then
  eval "$(dircolors -b $XDG_CONFIG_HOME/dircolors/theme)"
else
  eval "$(dircolors -b)"
fi