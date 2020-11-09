Vagrant-Docker
==============

Vagrant box with Docker using Ubuntu (bento/ubuntu-20.04).


HOW-To
===================

###### Start box
```Shell
vagrant up
```

###### Connect to the box
```Shell
vagrant ssh
```

###### Hello World
```Shell
sudo docker run hello-world
```

###### Display docker containers
```Shell
sudo docker ps -a
```

###### Shut down the box
```Shell
vagrant halt
```

###### Destroy the box
```Shell
vagrant destroy
```
