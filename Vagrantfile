
Vagrant.configure("2") do |config|
  
  config.vm.box = "bento/ubuntu-20.04"


  config.vm.network "forwarded_port", guest: 9090, host: 8080, host_ip: "127.0.0.1"


  config.vm.synced_folder "./shared-files", "/home/files_shared_with_docker",
    id: "files_shared_with_docker"
  config.vm.synced_folder "./dockerLearn", "/home/dockerLearn",
    id: "dockerLearn"
    



  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false
  
    # Customize the amount of memory on the VM:
    vb.memory = "1024"
    vb.cpus = 2
    vb.name = 'ubuntu20-docker-practice'
  end

  config.vm.provision :shell, :path => "vagrant-docker-vm-init.sh", :args => "#{ARGV.join(" ")}"
end
