if [[ $(ps -p "$PPID" -o comm= | xargs basename) != 'fish' ]]; then
  exec /run/current-system/sw/bin/fish -l
fi
