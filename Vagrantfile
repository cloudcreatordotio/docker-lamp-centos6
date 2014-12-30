# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'
Vagrant.configure("2") do |config|
  config.vm.define "my_docker" # proxy vagrant machine name
  config.vm.provider "docker" do |d|
    d.vagrant_vagrantfile = "./Vagrantfile.boot2docker"
#    d.build_dir = "."
#    d.build_args = "--tag='yutaf/lamp-centos6'"
    d.image = "yutaf/lamp-centos6"
    d.name = "c"
    d.vagrant_machine = "docker_host"
    d.volumes = ["/www/:/srv/www:rw"]
    # enable to mount
    d.create_args = ["--cap-add=SYS_ADMIN"]
    #d.has_ssh = true
  end
  config.vm.network :forwarded_port, guest: 80, host: 80
end
