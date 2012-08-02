#!/usr/bin/env bash

set -e # exit immediately if a simple command exits with a non-zero status
set -u # report the usage of uninitialized variables
set +x

initial_example='examples/one_user.yml'

if [[ ! -f ~/install_dependencies_complete ]]
then
  echo Installing dependencies for bosh-solo

  if [[ ! -f /etc/resolv.conf.bak ]]
  then
    mv /etc/resolv.conf /etc/resolv.conf.bak
    echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
    echo 'nameserver 8.8.4.4' >> /etc/resolv.conf
  fi
  
  sudo apt-get install curl git-core -y
  
  if [[ ! -x /opt/sm/bin/sm ]]
  then
    if [[ ! -f /tmp/smf.sh ]]
    then
      curl -s -L https://get.smf.sh -o /tmp/smf.sh
    fi
    sudo chmod +x /tmp/smf.sh
    sudo sh /tmp/smf.sh
  fi
  sudo /opt/sm/bin/sm ext install bosh-solo git://github.com/drnic/bosh-solo.git
  sudo /opt/sm/bin/sm bosh-solo install_dependencies

  touch ~/install_dependencies_complete
  
fi

# FIXME - why doesn't this work?
# echo '${initial_example}' ${initial_example}
# 
# if [[ ${initial_example} != '' && -f /vagrant/${initial_example} ]]
# then
#   sudo /opt/sm/bin/sm bosh-solo update /vagrant/${initial_example}
# fi
