#!/usr/bin/env bash
# vim: ft=bash
# @description Shared Utilities.

is.loaded utils && return

sedx() {
  if command -V gsed >/dev/null; then
    gsed "$@"
  elif command -V sed >/dev/null; then
    sed "$@"
  else
    /usr/bin/sed "$@"
  fi
}

is.a-function () {
  if [[ -n ${1} ]] && typeset -f "$1" > /dev/null 2>&1; then
      return 0;
  else
      return 1;
  fi
}

is.numeric() {
  [[ $1 =~ ^[+-]?([0-9]+([.][0-9]*)?|\.[0-9]+)$ ]]
}

# This function tests for whether there is STDIN defined,
# and if so attempts to read zero bytes to verify that there
# is something to read.
have.stdin() {
  [[ -t 0 ]] && read -t 0
}

log.error() {
  printf "\e[1;31mERROR: $*\e[0;0m\n" >&2
}

log.info() {
  printf "\e[1;32m INFO: $*\e[0;0m\n" >&2
}

is.debug() {
  [[ -n $DEBUG ]]
}
