#!/bin/bash
set -uex

CONFIG_DIR="puppet"

# Downloads and install Debian package provided by PuppetLabs
function installPuppetDeb {
  idempotentInstall 'wget'
  local DISTRIB_CODENAME=$(lsb_release --codename --short)
  local REPO_DEB_URL="$(printf $(config-get "puppet-repo") ${DISTRIB_CODENAME})"
  local REPO_DEB_PATH=$(mktemp)
  wget -q --output-document="${REPO_DEB_PATH}" "${REPO_DEB_URL}"
  dpkg -i "${REPO_DEB_PATH}" >/dev/null
  rm "${REPO_DEB_PATH}"
}

function purgePuppetDeb {
  local DEB_PROVIDES="/etc/apt/sources.list.d/puppetlabs.list"
  if [ -e ${DEB_PROVIDES} ]; then
    dpkg --purge 'puppetlabs-release'
  fi
}

function installPuppet {
  local pin="${1:-3.7.3}"
  local package="puppet"
  local test=0

  dpkg --compare-versions $(puppet --version) ge ${pin} || test=$?
  if [[ "0" -ne "${test}" ]]; then
    purgePackage ${package}
    purgePuppetDeb
    installPuppetDeb
    apt-get update >/dev/null
    installPackage ${package}
  else
    juju-log "Puppet already at version ${pin}"
  fi
}
