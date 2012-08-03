#!/usr/bin/env bash

# Helper to create a linux user
# Usage:
#  create_user $user $general_info
function create_user() {
  login=$1
  general_info=${2:-'stranger in the night'}
  login_home="/home/${login}"
  if [[ ! -d ${login_home} ]]
  then
    /usr/sbin/adduser \
        --system \
        --shell /bin/bash \
        --gecos "${general_info}" \
        --group \
        --disabled-password \
        --home ${login_home} ${login}
  fi

  touch ${login_home}/.bashrc
  chown ${login}:${login} ${login_home}/.bashrc
}

# Helper for installing priv/pub keypair for target user
# Usage:
#  install_keypair $pubkey $privkey $login $keyname
function install_keypair() {
  pubkey=$1
  privkey=$2
  login=$3
  keyname=$4
  login_home="/home/${login}"
  
  ssh_dir=${login_home}/.ssh
  mkdir -p ${ssh_dir}
  chmod 700 ${ssh_dir}
  chown ${login}:${login} ${ssh_dir}
  
  echo ${pubkey} > ${ssh_dir}/${keyname}.pub
  chmod 644 ${ssh_dir}/${keyname}.pub
  chown ${login}:${login} ${ssh_dir}/${keyname}.pub
  
  echo ${privkey} > ${ssh_dir}/${keyname}
  chmod 600 ${ssh_dir}/${keyname}
  chown ${login}:${login} ${ssh_dir}/${keyname}
}
