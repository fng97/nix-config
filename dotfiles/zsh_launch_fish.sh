if [[ $(ps -o command= -p "$PPID" | awk '{print $1}') != 'fish' ]]; then
  exec /run/current-system/sw/bin/fish -l
fi
