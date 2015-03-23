#!/bin/bash
set -e # If any command fails, stop execution of the hook with that error

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

function juju-log {
  echo "${1:-RaiseYourVoice}"
}

function config-get {
  local key="${1}"
  ${DIR}/config_get.sh ${key} ${CONFIG_DIR}
}

function relation-get {
  local key="${1}"
  ${DIR}/config_get.sh ${key} ${RELATION_DIR}
}
