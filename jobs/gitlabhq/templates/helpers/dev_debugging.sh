#!/usr/bin/env bash

# Collection of functions to help debug a job VM
#
# Installation:
# > bosh ssh JOBNAME 0
# $ sudo su -
# # source /var/vcap/jobs/THISJOB/helpers/dev_debugging.sh
#
# Usage:
# # tailjob myjob
# 

function tailjob() {
  jobname=${1:-xxx}
  if [[ "$jobname" = "xxx" ]]
  then
    echo "USAGE: tailjob myjob"
    exit 1
  fi
  tail -f -n 50 /var/vcap/sys/log/monit/${jobname}.* /var/vcap/sys/log/${jobname}/*
}

function tailmonit() {
  tail -f /var/vcap/monit/monit.log
}

function tailpkg() {
  pkgname=${1:-xxx}
  if [[ "$pkgname" = "xxx" ]]
  then
    echo "USAGE: cd_pkg mypkg"
    exit 1
  fi
  tail -f -n 50 /var/vcap/packages/${pkgname}/**/*.log
}


function cd_job() {
  jobname=${1:-xxx}
  if [[ "$jobname" = "xxx" ]]
  then
    echo "USAGE: cd_job myjob"
    exit 1
  fi
  cd /var/vcap/jobs/${jobname}
}

function cd_pkg() {
  pkgname=${1:-xxx}
  if [[ "$pkgname" = "xxx" ]]
  then
    echo "USAGE: cd_pkg mypkg"
    exit 1
  fi
  cd /var/vcap/jobs/${jobname}
}
