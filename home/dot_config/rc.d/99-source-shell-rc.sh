{{ template "managed_by_chezmoi.tmpl" }}

if [ -n "$BASH_VERSION" ]; then
  currentShell="bash"
elif [ -n "$ZSH_VERSION" ]; then
  currentShell="zsh"
else
  currentShell="sh"
fi

if test -d "$RCDIR"/${currentShell}; then
  for rcfile in "$RCDIR"/${currentShell}/*.${currentShell}; do
    test -f "$rcfile" && test -r "$rcfile" && . "$rcfile"
  done
  unset rcfile
fi

unset currentShell