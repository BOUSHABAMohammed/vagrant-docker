#################################
#  Bash params for building env #
#################################
#get bash params
installDocker=false
for var in "$@"
do
    if [ "$var" = "--installDocker" ];then
        installDocker=true
    fi
done

#################################
#       Env configuration       #
#################################
if [ "$installDocker" = true ]; then
    #all following steps is for setup docker repo
    #Update the apt package index and install packages to allow apt to use a repository over HTTPS:
    sudo apt-get -y update
    sudo apt-get -y install apt-transport-https
    sudo apt-get -y install ca-certificates
    sudo apt-get -y install curl 
    sudo apt-get -y install gnupg-agent
    sudo apt-get -y install software-properties-common
    #Add Docker’s official GPG key:
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    #set up the stable repository
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) exist stable"
    sudo apt-get -y update
    sudo apt-get -y install docker-ce docker-ce-cli containerd.io
fi

#create a folder 
cd /tmp
SHARED_FILES="/tmp/files_shared_with_docker"
if [ ! -d "$SHARED_FILES" ]; then
    sudo mkdir $SHARED_FILES
fi

#################################
#  nginx Docker container setup #
#################################
if [ "$(sudo docker image ls | grep nginx)" ]; then
	echo "nginx image already exists"
else
    echo "downloading nginx image"
	sudo docker pull nginx
fi
#run nginx container
if [ "$(sudo docker ps -a | grep nginxServer)" ]; then
	echo "nginx container is present, no need to create it again"
    if [ "$(sudo docker ps -a | grep nginxServer | grep Exited)" ]; then
        sudo docker start nginxServer
    fi
else
    echo "runing nginx container.."
    sudo docker run --name nginxServer -d -p 9090:80 -v $SHARED_FILES:/usr/share/nginx/html nginx:latest
fi
