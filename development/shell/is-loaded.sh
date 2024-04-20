#!/usr/bin/env bash
# @description This function provides memoization of shell files and skips
#              loading the file more than once, even if it's sourced in from
#              multiple locations.3
#
# @usage To use, place the following at the top of a shell library file,
#        say the file is called "functions.sh":
#
# @example
#        #!/usr/bin/env bash
#        # @file: functions.sh
#        #
#        # is.loaded functions && return
#        #
#        # Body of the file follows.
#
# @note: export DEBUG_LOADER=1 to see the decision about loading or not.
#        export DEBUG_LOADER_SOURCE=1 to see the contents of the evaluated file.

typeset -axg loaded_files
declare -a loaded_files

is.loaded() {
  local file="$1"

  [[ -z ${file} ]] && {
    echo "ERROR: no argument to the function is.loaded() was provided." >&2
    return 1
  }

  local script="
    declare ${file}_loaded
    export ${file}_loaded=\${${file}_loaded:-0}
    [[ -n \${DEBUG_LOADER} ]] && {
      printf \"%10s ➜ \" \"\${file}\"
      if ((__${file}_loaded)) ; then echo -e \"\e[1;32m ✔︎ is already loaded.\e[0;0m\"; else echo -e \"\e[1;33m ✖︎ not yet loaded\e[0;0m. Loading...\"; fi
    }
    ((__${file}_loaded)) && return 0
    export __${file}_loaded=1
    [[ \${loaded_files[*]} =~ \$file ]] || loaded_files+=(\${file})
    return 1
  "

  if [[ -n ${DEBUG_LOADER_SOURCE} ]] && command -V bat >/dev/null; then
    echo "${script}" | bat --language bash
  fi

  eval "${script}"
}

unload.file() {
  local file="$1"

  [[ -z ${file} ]] && {
    echo "ERROR: no argument to the function is.loaded() was provided." >&2
    return 1
  }

  eval "unset __${file}_loaded"
  # shellcheck disable=SC2086,SC2207
  export loaded_files=( $(echo "${loaded_files[*]}" | tr ' ' '\n' | grep -v -E "^${file}$" | tr '\n' ' ') )
}

