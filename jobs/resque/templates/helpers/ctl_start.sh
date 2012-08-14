#!/usr/bin/env bash

# Either:
#   properties:
#     webapp:
#       appstack: puma
#       puma:
#         threads:
#           min: 0
#           max: 16
#
# Or PHP-FPM:
#   properties:
#     webapp:
#       appstack: php-fpm
#
# Or (default)
#   properties:
#     webapp:
#       appstack: rackup
#
# Requires env variables:
# * $WEBAPP_DIR
# * $PIDFILE
# * $PORT
function ctl_start() {
  runas=${1:-vcap}
  webapp_dir=${2:-$WEBAPP_DIR}
  cd ${webapp_dir}

  appstack=${3:-$WEBAPP_APPSTACK}

  echo "Launching $JOB_NAME within $WEBAPP_DIR with ${appstack}"
  wait_for_database

  if [[ "${appstack}" = "puma" ]]
  then
    <% puma_threads = properties.webapp.puma && properties.webapp.puma.threads %>
    MIN_THREADS=<%= (puma_threads && puma_threads.min) || 0 %>
    MAX_THREADS=<%= (puma_threads && puma_threads.max) || 16 %>
    chpst -u ${runas}:vcap bundle exec puma --pidfile $PIDFILE -p $PORT -t $MIN_THREADS:$MAX_THREADS \
         >>$LOG_DIR/webapp.stdout.log \
         2>>$LOG_DIR/webapp.stderr.log

  elif [[ "${appstack}" = "rackup" ]]
  then
    chpst -u ${runas}:vcap bundle exec rackup -D -P $PIDFILE -p $PORT \
         >>$LOG_DIR/webapp.stdout.log \
         2>>$LOG_DIR/webapp.stderr.log

  elif [[ "${appstack}" = "phpfpm" || "${appstack}" = "php-fpm" ]]
  then
    chpst -u ${runas}:vcap /var/vcap/packages/php5/sbin/php-fpm \
      -c $JOB_DIR/etc/php.ini \
      --fpm-config $JOB_DIR/etc/php-fpm.conf \
      --pid $PIDFILE

  # else invalid appstack requested
  else
    echo "ERROR: properties.webapp.appstack = ${appstack}. Valid values: puma, rackup"
    exit 1
  fi

  chown ${runas} $PIDFILE
  chgrp vcap $PIDFILE
}

# Requires env variables:
# * $WEBAPP_DIR
function ctl_start_prepare_webapp() {
  runas=${1:-vcap}
  webapp_dir=${2:-$WEBAPP_DIR}

  chown ${runas} -R ${webapp_dir}/*
  chgrp vcap -R ${webapp_dir}/*
  chmod g+w -R ${webapp_dir}/*
  
  # To avoid this warning/error, make it a git repo
  #   fatal: Not a git repository (or any parent up to mount point /var/vcap/data)
  #   Stopping at filesystem boundary (GIT_DISCOVERY_ACROSS_FILESYSTEM not set).
  if [[ ! -d ${webapp_dir}/.git ]]
  then
    cd ${webapp_dir}
    chpst -u ${runas} git config --global \
      init.templatedir /var/vcap/packages/git/share/git-core/templates

    chpst -u ${runas} git config user.email "you@example.com"
    chpst -u ${runas} git config user.name "bosh"
    chpst -u ${runas} git init
    chpst -u ${runas} git add *
    chpst -u ${runas} git commit -m "stub commit to convert package to git repo"
  fi
}

