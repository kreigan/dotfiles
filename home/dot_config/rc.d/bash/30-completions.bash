{{ template "managed_by_chezmoi.tmpl" }}

if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    . /etc/bash_completion
  fi
fi

if [[ $- == *i* ]]; then
  bind 'set completion-ignore-case on' # Ignore case when completing file names with TAB
  bind 'set show-all-if-ambiguous on'  # Show all possible completions immediately when pressing TAB for the first time
  bind 'set colored-stats on'          # Highlight the common part when focused on a completion
  bind 'set visible-stats on'          # Show file type indicators when completing file names (like ls -F)
fi
