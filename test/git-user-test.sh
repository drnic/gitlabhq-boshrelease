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
  
  echo "|"
  echo "| Deleting git user"
  echo "|"
  userdel -f -r git || true

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