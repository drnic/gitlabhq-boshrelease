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

export JOB_NAME=${1:-$JOB_NAME}

if [[ ! -f /var/vcap/jobs/${JOB_NAME}/helpers/ctl_setup.sh ]]
then
  echo "USAGE: dev_debugging.sh JOB_NAME"
else
  source /var/vcap/jobs/${JOB_NAME}/helpers/ctl_setup.sh $JOB_NAME

  function taillogs() {
    tail -f ${JOB_LOGS[@]}
  }

  function tailmonit() {
    tail -f /var/vcap/monit/monit.log
  }

  function cd_job() {
    target_jobname=${1:-$JOB_NAME}
    cd /var/vcap/jobs/${target_jobname}
  }

  function cd_pkg() {
    pkgname=${1:-$JOB_NAME}
    cd /var/vcap/packages/${pkgname}
  }
fi
