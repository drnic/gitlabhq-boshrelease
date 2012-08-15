#!/usr/bin/env bash

# Create git user, if not already created
#
# Tutorials being followed:
# * http://www.bigfastblog.com/gitolite-installation-step-by-step

set -u # report the usage of uninitialized variables
set +x

export HOME=${GIT_HOME}
packages=/var/vcap/packages
export git_user_grp=${GIT_USER}:vcap

if [[ ! -d ${GIT_HOME} ]]
then
  /usr/sbin/adduser \
      --system \
      --shell /bin/bash \
      --gecos 'git version control' \
      --uid 112 \
      --group \
      --disabled-password \
      --home ${GIT_HOME} ${GIT_USER}

  chpst -u ${git_user_grp} touch ${GIT_HOME}/.bashrc
  chpst -u ${git_user_grp} git config --global \
    init.templatedir /var/vcap/packages/git/share/git-core/templates
  
  echo 'export PATH=${packages}/perl/bin:$PATH' >> ${GIT_HOME}/.bashrc
  echo 'export PATH=${packages}/git/bin:$PATH' >> ${GIT_HOME}/.bashrc
  echo 'export PATH=${packages}/gitolite/src:$PATH' >> ${GIT_HOME}/.bashrc
fi

mkdir -p ${GIT_HOME}/repositories/
chown ${git_user_grp} ${GIT_HOME}/repositories/
chmod 775 ${GIT_HOME}/repositories/

link_job_file config/dot.gitolite.rc $GIT_HOME/.gitolite.rc

export PATH=${packages}/perl/bin:$PATH
export PATH=${packages}/git/bin:$PATH
export PATH=${packages}/gitolite/src:$PATH

chown git -R $(readlink ${packages}/gitolite)
echo chpst -u ${git_user_grp} $(readlink ${packages}/gitolite)/install
chpst -u ${git_user_grp} $(readlink ${packages}/gitolite)/install

echo "${ADMIN_PUB_KEY}" > ${GIT_HOME}/gitlab.pub
chmod 0444 ${GIT_HOME}/gitlab.pub

# TODO how to make idempotent? what is it doing?
echo "gitolite at" $(which gitolite)
echo chpst -u ${git_user_grp} gitolite setup -pk ${GIT_HOME}/gitlab.pub
chpst -u ${git_user_grp} gitolite setup -pk ${GIT_HOME}/gitlab.pub
