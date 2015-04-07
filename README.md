Vagrantfile for fpbuild VM
==========================

This sets up a VM that works nicely with fpbuild if you're on a non-Linux platform. This is a work-in-progress and has rough edges.  That said, it seems to work. The VM will also work for general Docker use without fpbuild.

Note: Docker in the VM to uses the new `overlay` storage driver (which requires a very recent Linux kernel).  In theory, this driver should not suffer from the various problems that devicemapper, aufs, and btrfs have.  We'll see...

To use:

- Search for `CHANGEME` in the `Vagrantfile` and `bootstrap.sh` for any areas you need to adjust for your system.

- Run `vagrant up`.  You will probably have to enter your root password so that Vagrant can set up NFS.

- Run `vagrant reload` (REQUIRED!)

- Set the `DOCKER_HOST` environment variable:

        export DOCKER_HOST="tcp://192.168.33.10:2375"

    Adjust the IP address if you changed the `private_network` in `Vagrantfile`.

- Build `fpbuild` from <git@github.com:fpco/dev-tools.git> for your platform. [TODO: provide pre-built fpbuild binaries for common platforms]
