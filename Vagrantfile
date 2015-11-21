#!/bin/sh
$script = <<SCRIPT
export DEBIAN_FRONTEND=noninteractive
echo "Update packages"
sudo killall -9 java > /dev/null 2>&1
sudo apt-get -yqq update > /dev/null 2>&1
sudo apt-get -yqq install virtualbox-guest-additions-iso > /dev/null 2>&1
echo "Install Java"
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections > /dev/null 2>&1
sudo apt-get -yqq install curl software-properties-common > /dev/null 2>&1
sudo add-apt-repository -y ppa:webupd8team/java > /dev/null 2>&1
sudo apt-get -yqq update > /dev/null 2>&1
sudo apt-get -yqq install autoconf libtool libssl-dev libkrb5-dev python-dev python-pip haveged openssl wget git oracle-java8-installer oracle-java8-unlimited-jce-policy > /dev/null 2>&1
sudo apt-get install -q -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" krb5-user > /dev/null 2>&1
#entropy generator
haveged -w 1024 > /dev/null 2>&1
sudo pip install httpie-negotiate > /dev/null 2>&1
su -c "/vagrant/setup.sh" vagrant
SCRIPT
# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.network :forwarded_port, guest: 5601, host: 5601
  config.vm.network :forwarded_port, guest: 9200, host: 9200
  config.vm.network :forwarded_port, guest: 88, host: 8888, protocol: 'udp'
  #config.vm.network :forwarded_port, guest: 9300, host: 9300

  config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--cpus", "2", "--memory", "2048"]
  end
  config.vm.provision "shell", inline: $script
end
