#!/usr/bin/env bash
# vim: ft=bash

declare shell_dir
export shell_dir="${root_dir:=$(pwd -P)}/development"

# shellcheck source=./shell/is-loaded.sh
source "${shell_dir}/shell/is-loaded.sh"

function unload.helpers() {
  unload.file utils
  unload.file array
  unload.file path
}

unload.helpers

# shellcheck source=./shell/utils.sh
source "${shell_dir}/shell/utils.sh"

# shellcheck source=./shell/array.sh
source "${shell_dir}/shell/array.sh"

# shellcheck source=./shell/path.sh
source "${shell_dir}/shell/path.sh"

