ID=$(date +%s)
LOG="../em-$ID.log"

init_dir () {
  DIR="em-$ID"
  echo "dir: $DIR"
  mkdir $DIR && cd $DIR
}

_write_log () {
  tee -a $LOG
}

init_man () {
  man -k . | awk '{print $1}' | grep "(1)" | \
    sed 's/(1)//g' | sed 's/,//g' | xargs touch

  echo "$(($(ls -l | wc -l) - 1)) man pages found." | \
    _write_log
}

_check_man () {
  man "$1" > /dev/null 2>&1
  return $?
}

_export_man () { 
  man $1 2>> $LOG | col -b 1> $2 || \
    return 5 
}

_tolower_export_man () {
  local _lowercase="$(echo $1 | awk '{ print tolower($1) }')"
  _check_man $_lowercase && _export_man $_lowercase $1
}


_add_extension () {
  for FILE in *; do
    mv "$FILE" "$FILE.txt"
  done
}

export_man () {
  for COMMAND in *; do
    _check_man $COMMAND
    if [[ $? -eq 0 ]]; then 
      _export_man $COMMAND $COMMAND
    else 
       _tolower_export_man $COMMAND
     fi
  done
  _add_extension || return 6
  
  return $?
}

error_handling () {
  local prefix="error: unable to"
  case $1 in
    3) echo "$prefix create directory: $DIR" | \
      _write_log
      ;;
    4) echo "$prefix scan or create man files" | \
      _write_log
      ;;
    5) echo "$prefix export $COMMAND's man page" | \
      _write_log
      ;;
    6) echo "$prefix add extension to exported mans" | \
      _write_log
      ;;
    *) echo "error: unknown error(s) :(" | \
      _write_log
      ;;
  esac
}

main () {
  echo "initializing..."
  # init_dir || return 3
  cd "./man/1/"
  init_man || return 4

  echo "exporting..."
  export_man
}

main || error_handling $?
echo "done in $(($(date +%s) - ID)) seconds." | \
  tee -a $LOG
