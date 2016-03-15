# -*- mode: ruby -*-
# vi: set ft=ruby :

#
# Adjust the following constants:
#

# Number of virtual CPUs to give the VM.
VM_CPUS = 2
# Amount of memory to dedicate to VM.
VM_MEMORY = 2048 # 2 GB
# Maximum size of Docker disk.
DISK_DOCKER_SIZE = 100 * 1024 # 100 GB
# Maximum size of swap disk.
DISK_SWAP_SIZE = 8192 # 8 GB

#
# The following constants are less frequently adjusted:
#

# Adjust the private IP address if it conflicts with anything on your network.
PRIVATE_IP_ADDRESS = "192.168.83.84"
# Path to directory containing all your stack projects and your stack root (usually `~/.stack`).
PROJECTS_DIRECTORY = ENV["HOME"]
# Directory to store extra virtual disks (for /var/lib/docker and swap).
DISK_VDI_DIR = File.realpath( "." ).to_s

#
# Configuration
#

Vagrant.configure(2) do |config|
    config.vm.box = "ubuntu/wily64"
    #config.vm.box_check_update = false
    config.vm.network "private_network", ip: PRIVATE_IP_ADDRESS
    #config.vm.network "public_network"
    config.ssh.forward_agent = true
    config.vm.synced_folder ".", "/vagrant", type: "nfs"
    config.vm.synced_folder PROJECTS_DIRECTORY, PROJECTS_DIRECTORY, type: "nfs"
    config.vm.provider "virtualbox" do |vb|
        #vb.gui = true
        vb.cpus = VM_CPUS
        vb.customize ["modifyvm", :id, "--memory", VM_MEMORY]
        # Sync time with host if it's drifted more than a second
        vb.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 1000]
        file_to_swap = DISK_VDI_DIR + "/swap.vdi"
        if ARGV[0] == "up" && ! File.exist?(file_to_swap)
            puts "Creating swap disk #{file_to_swap}."
            vb.customize [
                'createhd',
                '--filename', file_to_swap,
                '--format', 'VDI',
                '--size', DISK_SWAP_SIZE
                ]
            vb.customize [
                'storageattach', :id,
                '--storagectl', 'SATAController',
                '--port', 1, '--device', 0,
                '--type', 'hdd', '--medium',
                file_to_swap
                ]
        end
        file_to_docker = DISK_VDI_DIR + "/docker.vdi"
        if ARGV[0] == "up" && ! File.exist?(file_to_docker)
            puts "Creating docker disk #{file_to_docker}."
            vb.customize [
                'createhd',
                '--filename', file_to_docker,
                '--format', 'VDI',
                '--size', DISK_DOCKER_SIZE
                ]
            vb.customize [
                'storageattach', :id,
                '--storagectl', 'SATAController',
                '--port', 2, '--device', 0,
                '--type', 'hdd', '--medium',
                file_to_docker
                ]
        end
    end
    config.vm.provision "shell", path: "bootstrap.sh"
end
