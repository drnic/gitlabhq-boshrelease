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

function taillogs() {
  load_job_properties 'taillogs' ${1:-xxx}
  tail -f ${JOB_LOGS[@]}
}

function tailmonit() {
  tail -f /var/vcap/monit/monit.log
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

function load_job_properties() {
  script=$1
  jobname=${2:-xxx}
  if [[ "${jobname}" = "xxx" ]]
  then
    echo "USAGE: ${script} myjob"
    exit 1
  fi
  source /var/vcap/jobs/${jobname}/data/properties.sh
}
