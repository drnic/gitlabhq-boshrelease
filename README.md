# BOSH Release for GitLabHQ



## Status

Whilst developing this release, you can check how GitLabHQ feels about things with its own status report:

```
sm bosh-solo rvm boshruby
rvm ext-boshruby
cd /var/vcap/packages/gitlabhq
RAILS_ENV=production rake gitlab:app:status
rvm default
```