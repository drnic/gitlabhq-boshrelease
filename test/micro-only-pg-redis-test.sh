#!/usr/bin/env roundup

# Run test:
# roundup postgres-test.sh

describe "micro VM running just gitlab and resque"

set -u # report the usage of uninitialized variables
# set -x

[ "$(whoami)" != 'root' ] && ( echo ERROR: run as root user; exit 1 )

cd /vagrant/ # need to hardcode as roundup overrides $0
release_path=$(pwd)

rm -rf /tmp/before_all_run_already

before_all() {

  sm bosh-solo stop

  rm -rf /var/vcap/store

  if [ "$(cat /etc/passwd | grep '^git:')" != '' ]
  then
    userdel -f git
  fi
  if [ "$(cat /etc/group | grep '^git:')" != '' ]
  then
    delgroup git
  fi
  rm -rf /home/git/

  if [ "$(cat /etc/passwd | grep '^gitlab:')" != '' ]
  then
    userdel -f gitlab
  fi
  if [ "$(cat /etc/group | grep '^gitlab:')" != '' ]
  then
    delgroup gitlab
  fi
  rm -rf /home/gitlab/

  # update deployment with example properties
  example=${release_path}/examples/micro-only-postgres-redis.yml
  sm bosh-solo update ${example}

  # wait for everything to boot up, migrate, create users, etc
  sleep 50

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

it_runs_no_gitolite_nginx() {
  expected='sbin/nginx -c /var/vcap/jobs/gitolite/config/nginx.conf'
  test $(ps ax | grep "${expected}" | grep -v 'grep' | wc -l) = 0
}

it_runs_no_gitlabhq_using_puma() {
  expected='puma --pidfile /var/vcap/sys/run/gitlabhq/gitlabhq.pid -p 5000 -t 0:20'
  test $(ps ax | grep "${expected}" | grep -v 'grep' | wc -l) = 0
}

it_runs_no_gitlabhq_nginx() {
  expected='sbin/nginx -c /var/vcap/jobs/gitlabhq/config/nginx.conf'
  test $(ps ax | grep "${expected}" | grep -v 'grep' | wc -l) = 0
}

it_runs_no_resque_workers() {
  expected='resque-1.20.0: Waiting for post_receive,mailer,system_hook'
  test $(ps ax | grep "${expected}" | grep -v 'grep' | wc -l) = 0
}

it_runs_redis() {
  expected='redis-server'
  test $(ps ax | grep "${expected}" | grep -v 'grep' | wc -l) = 1
}

it_runs_postgres() {
  expected='bin/postgres -D /var/vcap/store/postgres -h 0.0.0.0 -p 5432'
  test $(ps ax | grep "${expected}" | grep -v 'grep' | wc -l) = 1
}
