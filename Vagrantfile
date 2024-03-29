# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'

dir = File.dirname(File.expand_path(__FILE__))
data = YAML.load_file("#{dir}/novame.yaml")
conf = data['vagrantfile-config']
require 'yaml'

dir = File.dirname(File.expand_path(__FILE__))
data = YAML.load_file("#{dir}/novame.yaml")
conf = data['vagrantfile-config']

case
  when !conf['vm']['chosen_provider'].nil?
    provider_name = conf['vm']['chosen_provider']
  when !"#{ENV['VAGRANT_DEFAULT_PROVIDER']}".empty?
    provider_name = "#{ENV['VAGRANT_DEFAULT_PROVIDER']}"
  else
    provider_name = 'virtualbox'
end

# todo: odd; removing
# ENV['VAGRANT_DEFAULT_PROVIDER'] = provider_name
provider = conf['vm']['providers'][provider_name]

shell = conf['vm']['provision']['shell']
puppet = conf['vm']['provision']['puppet']
network = conf['vm']['providers'][provider_name]['network']
synced_folder = conf['vm']['synced_folder'];
ssh = conf['ssh']
Vagrant.require_version conf['vagrant']['require_version']

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/trusty64"

  config.vm.provider :digital_ocean do |p, override|
    override.ssh.username = "#{ssh['username']}"
    override.ssh.private_key_path = "#{ssh['private_key_path']}"
    override.vm.box = "#{provider['box']}"
    override.vm.box_url = "#{provider['box_url']}"

    p.token = "#{provider['token']}"
    p.image = "#{provider['image']}"
    p.region = "#{provider['region']}"
    p.size = "#{provider['size']}"
    p.ssh_key_name = "#{provider['ssh_key_name']}"
  end
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  synced_folder.each do |key, folder|
    unless folder['source'].empty? || folder['target'].empty?
      sync_type = !folder['sync_type'].nil? ? folder['sync_type'] : 'rsync'
      config.vm.synced_folder "#{folder['source']}", "#{folder['target']}", type: sync_type,
        rsync__exclude: folder['rsync']['exclude'],
        rsync__args: folder['rsync']['args'],
        rsync__auto: folder['rsync']['auto']
    end
  end

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL
  # Working directory
  wdir = "#{provider['wdir']}"
  # Shell provision
  config.vm.provision "install", type: "shell", run: "once" do |i|
    i.path = "#{shell['install']}"
  end
end
