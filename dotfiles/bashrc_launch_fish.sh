if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z "${BASH_EXECUTION_STRING}" ]]; then
  shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
  exec /run/current-system/sw/bin/fish $LOGIN_OPTION
fi
