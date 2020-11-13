Vagrant-Docker
==============

Vagrant box with Docker using Ubuntu (bento/ubuntu-20.04).

The box contains a Nginx Docker container already ready to use 


How To
===================

###### Start box
```Shell
vagrant --installDocker up --provsion
```

###### Access to Nginx
```Shell
http://localhost:8080/
```

Access to the box
===================
You can connect to the box and start creating your own containers, Here is an example :

###### Connect to the box
```Shell
vagrant ssh
```

###### Hello World
```Shell
sudo docker run hello-world
```

Other useful commands
===================

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
