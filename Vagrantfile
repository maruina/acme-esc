# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "puphpet/debian75-x64"
  config.vm.hostname = "debian-esc.vagrant.vm"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.99"

  config.vm.synced_folder "salt", "/srv/salt/"
  config.vm.synced_folder "pillar", "/srv/pillar/"

  config.vm.provider "virtualbox" do |vb|
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
      vb.name = "debian-test-salt"
  end


  # vagrant issue #5973
  # https://github.com/mitchellh/vagrant/issues/5973
  config.vm.provision :file, source: "minion", destination: "/tmp/minion"


  # Salt configuration
  config.vm.provision :salt do |salt|

      salt.minion_config = "minion"
      salt.run_highstate = true
      salt.log_level = "info"
      salt.bootstrap_options = "-P -c /tmp"
      salt.colorize = true
      salt.verbose = true

  end


end
