Vagrantfile for Stack's Docker integration
==========================================

This sets up a VM that works reasonably well with
[Stack's Docker integration](https://github.com/commercialhaskell/stack/blob/release/doc/docker_integration.md)
if you're on a non-Linux platform. See
[stack#194](https://github.com/commercialhaskell/stack/issues/194) for why
boot2docker does not work with Stack's Docker integration. This is a
work-in-progress and has rough edges. That said, it seems to work alright. The
VM will also work for general Docker use without Stack.

Docker in the VM is configured to use the new `overlay` storage driver. Despite
its newness, I've had no problems with it, and every other driver has given me
trouble when building large images, so I definitely recommend it.

This uses Vagrant's support for synced folders using NFS, which alleviates
the extreme slowness of VirtualBox shared folders (see
[boot2docker/boot2docker#593](https://github.com/boot2docker/boot2docker/issues/593)),
but is still significantly slower than native filesystem mounting.

**Note: requires at least stack-0.1.6.0 and Docker 1.9.1**

**Note: only tested on Mac OS X.** It definitely won't work on Windows, as it uses
NFS, and Stack's Docker integration doesn't support Windows paths.

To set up:

 1. Edit the `Vagrantfile` and adjust the constants at the top to your preference.

 2. Run `vagrant up`. You will probably have to enter your root password (on the
    host) so that Vagrant can set up its NFS exports.

 3. Set the `DOCKER_HOST` environment variable:

        export DOCKER_HOST="tcp://192.168.83.84:2375"

    Adjust the IP address if you changed the `PRIVATE_IP_ADDRESS` constant in
    the `Vagrantfile`.

Now use you can use `stack` with Docker enabled normally from your host. You can
also use `docker` commands from the host.

To access server processes running in a Docker container (e.g. `stack exec warp`),
you must connect to the VM's IP address instead of `localhost` (e.g. open
<http://192.168.83.84:3000/>).
