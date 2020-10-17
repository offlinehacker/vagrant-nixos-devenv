# -*- mode: ruby -*-
# vi: set ft=ruby :

def numvcpus
  begin
    os_cpu_cores
  rescue
    4
  end
end

# Get the number of logical cpu cores.
def os_cpu_cores
  case RbConfig::CONFIG['host_os']
  when /darwin/
    Integer(`sysctl -n hw.ncpu`)
  when /linux/
    Integer(`cat /proc/cpuinfo | grep processor | wc -l`)
  else
    raise StandardError, "Unsupported platform"
  end
end

Vagrant.configure("2") do |config|
  config.vm.hostname = "nixos-dev"
  config.vm.box = "xtruder/nix-profiles-nixos-x86_64"

  # code-server
  config.vm.network "forwarded_port", guest: 8080, host: 10035

  config.vm.synced_folder "./workspace", "/home/vagrant/workspace", type: "sshfs",
    sshfs_opts_append: "-o idmap=user -o uid=1000 -o gid=1000", ssh_username: "vagrant"

  config.vm.synced_folder ".", "/home/vagrant/workspace/nixos-devenv", type: "sshfs",
    sshfs_opts_append: "-o idmap=user -o uid=1000 -o gid=1000", ssh_username: "vagrant"

  config.vm.provider "libvirt" do |libvirt|
    libvirt.cpus = numvcpus

    # Use QEMU session instead of system connection
    libvirt.qemu_use_session = true
    # Path to store Libvirt images for the virtual machine, default is as ~/.local/share/libvirt/images
    libvirt.storage_pool_path = '/home/user/.local/share/libvirt/images'
    # Management network device, default is below
    libvirt.management_network_device = 'virbr0'

    libvirt.memory = "8192"
    libvirt.machine_virtual_size = 50

    libvirt.management_network_device = "virbr0"

    libvirt.graphics_type = "spice"
    libvirt.graphics_autoport = "yes"
    libvirt.graphics_ip = "0.0.0.0"
    libvirt.video_type = "virtio"

    libvirt.channel :type => "spicevmc", :target_name => "com.redhat.spice.0", :target_type => "virtio"
  end

  config.vm.provision "shell", inline: <<-SHELL
    nixos-rebuild switch -L --flake /home/vagrant/workspace/nixos-devenv#dev-vagrant-libvirt
  SHELL
end
