#!/usr/bin/env bash
# shellcheck disable=SC2207
# vim: ft=bash
# @file path.sh
# @description Utilities for managing the $system_path variable
# @author © 2024 Konstantin Gredeskoul
#
# This file is borrowed from the open source project
# called Bashmatic (https://github.com/kigster/bashmatic)

# USAGE:
#   These functions below operate on the copy of the $PATH
#   variable called ${system_path}. In order to define this
#   variable from $PATH, call path.system-path.set. If you are mutating
#   ${system_path}, and want to preserve such mutation between
#   various manipulations, call path.system-path.ensure to make sure that
#   ${system_path} is set and if not, copies from $PATH.
#   When you are done with manipulations, call path.system-path.export()
#   to actually mutate $PATH.

is.loaded path && return

declare -gx system_path

# $PATH must always include those, or shit won't work
[[ -z ${required_paths} ]] && declare -gxra required_paths=(/bin /usr/bin /sbin /usr/sbin)

# @description This file only mutates the copy of the $PATH variable, called
#              ${system_path}. Call path.system-path.export() to copy from ${system_path}
#              to $PATH.
function path.system-path.set() {
  export system_path="${PATH}"
}

function path.system-path.ensure() {
  export system_path="${system_path:-${PATH}}"
}

# @description Sets $PATH to the value of ${system_path} as long as it passes
#              validations and includes the required OS system paths.
function path.system-path.export() {
  if [[ -n "${system_path}" && "${system_path}" != "${PATH}" ]]; then

    path.has-required-paths || {
      log.error "Mutated path is missing required directories:\n — ${required_paths[*]}"
      return 1
    }

    is.debug && log.info "Redefining PATH:\n • old value: ${PATH}\n • new value: ${system_path}\n"
    export PATH="${system_path}"
  elif [[ -z "${system_path}" ]]; then
    log.info "Not changing $PATH because system_path is nil."
  else
    is.debug && log.info "Not changing $PATH because system_path is identical."
  fi
}


#——————————————————————————————————————————————————————————————————————————————————————
# Boolean functions that can be used to test various conditions.
#——————————————————————————————————————————————————————————————————————————————————————

# @description Returns true if the first argument is a member of the path-like string
#              passed as the second argument.
#
function path.includes() {
  local dir="$1"
  local path_string="${2:-${system_path}}"

  [[ -n "${dir}" && -n ${path_string} && ${path_string} =~ (^|:)${dir}(:|^) ]]
}

# @description Returns true if the current ${system_path} includes the required OS paths.
function path.has-required-paths() {
  path.system-path.ensure

  local dir
  for dir in "${required_paths[@]}"; do
    path.includes "${dir}" || return 1
  done
}

#——————————————————————————————————————————————————————————————————————————————————————
# The following functions print the mutated result to STDOUT only.
#——————————————————————————————————————————————————————————————————————————————————————

# @description Removes a trailing slash from an argument path
function path.strip-slash() {
  path.system-path.ensure
  local local_path="${1:-${system_path}}"
  local local_path="$(echo "${local_path}" | sedx -E 's#\/+$##g')"
  printf -- "%s" "${local_path}"
}

# @description Join multiple lines coming from STDIN into a path-like string,
#              while validating that each is an actual existing directory.
function path.append-from-stdin() {
  local local_path
  local line
  while IFS= read -r line; do
    [[ -d "${line}" ]] && {
      [[ -n ${local_path} ]] && local_path+=":"
      local_path+="${line}"
    }
  done

  printf -- "%s" "${local_path}"
}

# @description Prints a new-line separated list of paths obtained from either:
#              1. STDIN
#              2. Function arguments
#              3. $system_path
function path.dirs.by-line() {
  path.system-path.ensure

  # if output has STDIN
  (
    if have.stdin; then
      path.append-from-stdin
    elif [[ -n "$*" ]]; then
      for line in "$@"; do
        for local_path in $(echo "${line}" | sedx 's/:/\n/g'); do
          [[ -n ${local_path} && -d ${local_path} ]] && echo "${local_path}"
        done
      done
    else
      echo "${system_path}"
    fi
  ) | sedx 's/:/\n/g' | sedx '/^$/d'
}

# @description Prints the total number of paths in the path argument,
#              which defaults to $system_path
function path.dirs.size() {
  path.dirs.by-line | /usr/bin/wc -l | /usr/bin/tr -d ' '
}

# @description
#     Prints all folders in $system_path, one per line, removing any duplicates,
#     Does not mutate the $system_path
function path.dirs.uniq() {
  path.system-path.ensure

  local -a seen_dirs=()
  local dir
  for dir in $(path.dirs.by-line); do
    if array.includes "${dir}" "${seen_dirs[@]}"; then
      continue
    else
      echo "${dir}"
      seen_dirs+=("${dir}")
    fi
  done
}

function path.dirs.sort() {
  path.dirs.uniq | sort
}

function path.dirs.sort-rev() {
  path.dirs.uniq | sort -r
}

# @description
#     Deletes any number of folders from the system_path passedx as the first
#     string argument (defaults to $PATH). Does not mutate the $PATH,
#     just prints the result to STDOUT
# @arg1 String representation of a system_path, eg "/bin:/usr/bin:/usr/local/bin"
# @arg2 An array of paths to be removed from the system_path
function path.dirs.delete() {
  path.system-path.set
  local local_path="${1:${system_path}}"
  shift

  for dir_to_remove in "$@"; do
    [[ "${local_path}" =~ ${dir_to_remove} ]] || continue
    local_path="$(echo "${local_path}" | sedx "s#(^|:)${dir_to_remove}(:|$)##g")"
  done

  export system_path="${local_path}"
  return
}

function path.dirs.join() {
  path.system-path.set

  echo "${system_path}" | sedx 's/$/:/g' | tr -d '\n'
}

# @description
#     Removes duplicates from the $system_path (or argument) and prints the
#     results in the system_path format (column-joined). DOES NOT mutate the actual $system_path
function path.uniq() {
  # shellcheck disable=2046
 path.system-path.set
 local -a path_components
 path_components=( $(path.dirs.uniq "$@") )
 array.join ':' "${path_components[@]}"
}

# @description
#     Using sedx and tr uniq the system_path without re-sorting it.
function path.uniqify() {
  path.system-path.set
  local new_path="$(printf "${system_path}" | sedx 's/:/\n/g' | uniq | tr '\n' ':')"
  if [[ "${new_path}" != "${system_path}" ]] ; then
    export system_path="${new_path}"
  fi
}

# @description
#    Appends a new directory to the $system_path and prints the result to STDOUT,
#    Does NOT mutate the actual $system_path
function path.append() {
  local new_path="${system_path}"
  for __path in "$@"; do
    [[ -d "${__path}" ]] || {
      log.error "Argument ${__path} is not a valid directory, abort." >&2
      return 1
    }
    path.dirs.uniq | grep -q -E "^${__path}\$" && continue
    new_path="${new_path}:${__path}"
  done
  printf -- "%s" "${new_path}"
}

# @description
#   Prepends a new directory to the $system_path and prints to STDOUT,
#   If one of the arguments already in the system_path its moved to the front.
#   DOES NOT mutate the actual $system_path
function path.prepend() {
  local new_path="${system_path}"
  for __path in "$@"; do
    [[ -d "${__path}" ]] || {
      log.error "Argument ${__path} is not a valid directory, abort." >&2
      return 1
    }
    local p="$(path.dirs.uniq | grep -v -E "^${__path}\$" | tr '\n' ':')"
    new_path="${__path}:${p}"
  done
  printf -- "%s" "${new_path}"
}

#
# The following methods do change the $system_path variable, but if they are
# executed in a subshell, the will not modify the system_path of the outer shell
#

# @description
#     Removes any duplicates from $system_path and exports it.
function path.mutate.uniq() {
  export system_path="$(path.uniq "$@")"
}

# @description
#     Deletes paths from the system_path provided on the command line
function path.mutate.delete() {
  export system_path="$(path.dirs.delete "$@")"
}

# @description
#     Appends valid directories to those in the system_path, and
#     exports the new value of the system_path
function path.mutate.append() {
  export system_path="$(path.append "$@")"
}

# @description
#     Prepends valid directories to those in the system_path, and
#     exports the new value of the system_path
function path.mutate.prepend() {
  export system_path="$(path.prepend "$@")"
}

# @description Returns an absolute version of a given path
function path.absolute() {
  if [[ -d "$1" ]]; then
    pushd "$1" >/dev/null || exit
    pwd
    popd >/dev/null || exit
  elif [[ -e "$1" ]]; then
    pushd "$(dirname "$1")" >/dev/null || exit
    echo "$(pwd)/$(basename "$1")"
    popd >/dev/null || exit
  else
    echo "$1" does not exist! >&2
    return 127
  fi
}
