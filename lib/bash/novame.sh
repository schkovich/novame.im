#!/bin/bash
set -uex

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${DIR}" ]]; then DIR="${PWD}"; fi

source "/home/goran/lib/bash/common/juju_stubs.sh"
source "/home/goran/lib/bash/common/helpers.sh"
source "/home/goran/lib/bash/puppet/functions.sh"

# See http://serverfault.com/questions/500764/dpkg-reconfigure-unable-to-re-open-stdin-no-file-or-directory
locale-gen en_GB en_GB.UTF-8
export LANGUAGE=en_GB.UTF-8
export LANG=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8
dpkg-reconfigure locales

function rubyAlternatives {
  local version="${1:-2.1.0}"
  version="${version%.*}"
  update-alternatives --remove ruby /usr/bin/ruby${version}
  update-alternatives --remove irb /usr/bin/irb${version}
  update-alternatives --remove gem /usr/bin/gem${version}

  update-alternatives \
    --install /usr/bin/ruby ruby /usr/bin/ruby${version} 50 \
    --slave /usr/bin/irb irb /usr/bin/irb${version} \
    --slave /usr/bin/rake rake /usr/bin/rake${version} \
    --slave /usr/bin/gem gem /usr/bin/gem${version} \
    --slave /usr/bin/rdoc rdoc /usr/bin/rdoc${version} \
    --slave /usr/bin/testrb testrb /usr/bin/testrb${version} \
    --slave /usr/bin/erb erb /usr/bin/erb${version} \
    --slave /usr/bin/ri ri /usr/bin/ri${version}
}

# test: echo -e "require 'augeas'\nputs Augeas.open" | ruby -rrubygems
function nastyAugeasFix {
#  purgePackage 'ruby1.9.1'
  idempotentInstallRuby '2.1.0'
  installPuppet
  installPackage ruby-augeas
  cur_dir=$(pwd)
  cd /usr/lib/x86_64-linux-gnu/ruby/vendor_ruby/
  ver_two_one='2.1.0'
  if ! [ -h "${ver_two_one}" ]
  then
      rm -r "${ver_two_one}/";
      ln -s 2.0.0/ ${ver_two_one}
  fi;
  cd ../../
  if ! [ -h 'libruby-2.0.so.2.0' ]
  then
      ln -s libruby-2.1.so.2.1 libruby-2.0.so.2.0
  fi;
  cd ${cur_dir}
  update-alternatives --config ruby
}

function installRuby {
  local version="${1:-2.1.0}"
#  purgePackage 'ruby1.9.1'
  apt-add-repository --yes ppa:brightbox/ruby-ng
  apt-get update >/dev/null
  # http://stackoverflow.com/a/4170409
  installPackage "ruby${version%.*}"
  installPackage "ruby${version%.*}-dev"
  rubyAlternatives ${version}
}

function idempotentInstallRuby {
  local pin="${1:-2.1.0}"
  local test=0
  isPackageInstalled "ruby2.1" || test=$?
  if [ "0" -ne  "${test}" ]; then
    installRuby ${pin}
  else
    dpkg --compare-versions $(ruby -e 'puts "#{RUBY_VERSION}"') ge ${pin} || test=$?
    if [[ "0" -ne "${test}" ]]; then
      installRuby ${pin}
    else
      juju-log "Ruby already at or greater than version ${pin}"
    fi
  fi
}

function installLibrarianPuppet {
  local test=0
  gem list "librarian-puppet" -i || test=$?

  if [[ "0" -ne $test ]]; then
    gem install librarian-puppet --no-rdoc --no-ri
  else
    juju-log "gem librarian-puppet alreary installed"
  fi
}

idempotentInstall "build-essential"
idempotentInstall "git"
nastyAugeasFix
installLibrarianPuppet
