# BOSH Release for GitLabHQ



## Status

Whilst developing this release, you can check how GitLabHQ feels about things with its own status report:

```
sm bosh-solo rvm boshruby

su - gitlab
rvm ext-boshruby
cd /var/vcap/packages/gitlabhq
export PYTHONPATH=`pwd`/vendor/lib/python:$PYTHONPATH
export LD_LIBRARY_PATH=/var/vcap/packages/python27/lib:$LD_LIBRARY_PATH
export RAILS_ENV=production
rake gitlab:app:status
```