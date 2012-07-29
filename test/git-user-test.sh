#!/usr/bin/env roundup

describe "git user"

set -u # report the usage of uninitialized variables
set -x

[ "$(whoami)" != 'root' ] && ( echo ERROR: run as root user; exit 1 )

cd /vagrant/ # need to hardcode as roundup overrides $0
release_path=$(pwd)

rm -rf /tmp/before_all_run_already

before_all() {
  echo "|"
  echo "| Stopping any existing jobs"
  echo "|"
  sm bosh-solo stop

  echo "|"
  echo "| Deleting storage"
  echo "|"
  rm -rf /var/vcap/store

  if [ -d /home/git/ ]
  then
    echo "|"
    echo "| Deleting git user"
    echo "|"
    userdel -f git
    rm -rf /home/git/
  fi

  # update deployment with example properties
  example=${release_path}/examples/one_user.yml
  sm bosh-solo update ${example}

  # show last 20 processes (for debugging if test fails)
  ps ax | tail -n 20
}

# before() is only hook into roundup
# TODO add before_all() to roundup
before() {
  if [ ! -f /tmp/before_all_run_already ]
  then
    before_all
    touch /tmp/before_all_run_already
  fi
}

it_creates_git_home() {
  test -d /home/git
}

it_creates_gitolite_admin() {
  test -d /home/git/repositories/gitolite-admin.git/
}

it_creates_authorized_keys() {
  test -f /home/git/.ssh/authorized_keys
}

it_has_chunkin_module_in_nginx() {
  test $(/var/vcap/packages/nginx_next/sbin/nginx -V 2>&1 | grep 'chunkin' | wc -l) = 1
}

it_runs_nginx() {
  expected='sbin/nginx -c /var/vcap/jobs/gitolite/config/nginx.conf'
  test $(ps ax | grep "${expected}" | grep -v 'grep' | wc -l) = 1
}

it_restarted_nginx() {
  test $(cat /var/vcap/sys/log/gitolite/nginx.stderr.log | wc -l) = 0
}
# TODO test that .ssh/authorized_keys uses symlinks instead of 
# command="/var/vcap/data/packages/gitolite/0.10-dev/src/gitolite-shell gitolite