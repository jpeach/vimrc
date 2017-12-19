# -*- mode: ruby -*-
# vi: set ft=ruby sw=2 ts=2 et :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

$master = <<EOF
if command -v yum ; then
  yum install -y ccache
fi

if command -v systemctl ; then
  systemctl mask tmp.mount
fi

if command -v ccache ; then
  sudo -i -u vagrant bash -c 'ccache -M 10G'
fi

sudo -i -u vagrant bash -c 'echo "set -o vi" >> $HOME/.bashrc'
EOF

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--cpus", "2"]
    v.customize ["modifyvm", :id, "--memory", "2048"]
  end

  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.synced_folder ".", "/opt/home", type: "nfs"
  config.vm.provision :shell, inline: $master
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true

  config.vm.define "centos6" do |config|
    config.vm.hostname = "centos-6"
    config.vm.box = "centos/6"
    config.vm.network "private_network", ip: "172.16.0.20"
  end

  config.vm.define "centos7" do |config|
    config.vm.hostname = "centos-7"
    config.vm.box = "centos/7"
    config.vm.network "private_network", ip: "172.16.0.30"
  end

  config.vm.define "fedora25" do |config|
    config.vm.hostname = "fedora-25"
    config.vm.box = "fedora/25-cloud-base"
    config.vm.network "private_network", ip: "172.16.0.40"
  end

  config.vm.define "fedora26" do |config|
    config.vm.hostname = "fedora-26"
    config.vm.box = "fedora/26-cloud-base"
    config.vm.network "private_network", ip: "172.16.0.10"
  end

  config.vm.define "fedora27" do |config|
    config.vm.hostname = "fedora-27"
    config.vm.box = "fedora/27-cloud-base"
    config.vm.network "private_network", ip: "172.16.0.11"
  end

end
