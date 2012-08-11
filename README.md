# BOSH Release for GitLabHQ

## Release to your BOSH

To create and upload this release to your BOSH:

```
bosh target BOSH_URL
git clone git@github.com:engineyard/cassandra-boshrelease.git
cd cassandra-boshrelease
bosh create release
# blobs are automatically downloaded
# name it 'cassandra-dev' or something unique to your bosh
bosh upload release
```

## Development with Vagrant

This project includes development support within Vagrant using [bosh-solo](http://drnic.github.com/bosh-solo)

```
$ bundle
$ bosh create release

$ vagrant up
...
[default] Booting VM...
[default] Waiting for VM to boot. This can take a few minutes.
[default] VM booted and ready for use!
[default] Mounting shared folders...
[default] -- bosh-src: /bosh
[default] -- v-root: /vagrant

... installs lots of stuff...

$ vagrant ssh
```

Inside the VM:

```
[inside vagrant as vagrant user]
sudo su -

[inside vagrant as root user]
cd /vagrant/
sm bosh-solo update examples/default.yml
```

This process will take some time to install Ubuntu packages (during `install_dependencies`) and the source packages within this release.

After that, development is very quick and responsive.

### Deploying new development releases

Each time you change your bosh release you can quickly deploy it into the VM:

```
[outside vagrant within the project]
$ bosh create release

[inside vagrant as root user]
cd /vagrant/
sm bosh-solo update examples/default.yml
```

All logs will be sent to the terminal so you can watch for any errors as quickly as possible.

```
[inside vagrant as root user]
sm bosh-solo tail_logs
```

### Finalizing a release

If you create a final release `bosh create release --final`, you must immediately create a new development release. Yeah, this is a bug I guess.

```
[outside vagrant]
bosh create release --final
bosh create release

[inside vagrant as vcap user]
/vagrant/scripts/update examples/default.yml
```


### Alternate configurations

This BOSH release is configurable during deployment with properties. 

Please maintain example scenarios in the `examples/` folder.

To switch between example scenarios, run `sm bosh-solo update examples/FILE.yml` with a different example scenario.

### GitlabHQ Rails console

Whilst developing this release, you can check how GitLabHQ feels about things with its own status report:

```
sm bosh-solo rvm boshruby

su - gitlab
rvm ext-boshruby
cd /var/vcap/packages/gitlabhq
export PYTHONPATH=`pwd`/vendor/lib/python:$PYTHONPATH
export LD_LIBRARY_PATH=/var/vcap/packages/python27/lib:$LD_LIBRARY_PATH
export RAILS_ENV=production
bundle exec rails c
```

## Uploading to BOSH

Once you have a BOSH release that you like, you can upload it to BOSH and deploy it.

```
bosh upload release
bosh deployment path/to/manifest.yml
bosh deploy
```

Example `properties` for your `manifest.yml` can be taken from the examples in `examples\`

