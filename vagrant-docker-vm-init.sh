#################################
#  Bash params for building env #
#################################
#get bash params
installDocker=false
startNginxDockerContainer=false
setupNginxUsingDockerCompose=false
stopNginxUsingDockerCompose=false
installMinikube=false
setupMongoEnv=false
for var in "$@"
do
    if [ "$var" = "--installDocker" ];then
        installDocker=true
    fi
    if [ "$var" = "--startNginxDockerContainer" ];then
        startNginxDockerContainer=true
    fi
    if [ "$var" = "--setupNginxUsingDockerCompose" ];then
        setupNginxUsingDockerCompose=true
    fi
    if [ "$var" = "--stopNginxUsingDockerCompose" ];then
        stopNginxUsingDockerCompose=true
    fi
    if [ "$var" = "--installMinikube" ];then
        installMinikube=true
    fi
    if [ "$var" = "--setupMongoEnv" ];then
        setupMongoEnv=true
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
    echo "docker is installed, its version is $(sudo docker --version)"
    #install docker compose
    sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "docker-compose installed, its version is $(sudo docker-compose --version)"

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
if [ "$startNginxDockerContainer" = true ]; then
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
fi

##################################################################
#       nginx Docker container setup using docker-compose        #
##################################################################
#run
if [ "$setupNginxUsingDockerCompose" = true ]; then
    DOCKER_COMPOSE_FILE_PATH=/home/dockerLearn/my-docker-compose.yml
    sudo docker-compose -f $DOCKER_COMPOSE_FILE_PATH up -d
fi

#stop
if [ "$stopNginxUsingDockerCompose" = true ]; then
    DOCKER_COMPOSE_FILE_PATH=/home/dockerLearn/my-docker-compose.yml
    sudo docker-compose -f $DOCKER_COMPOSE_FILE_PATH down
fi

#################################
#      Minikube installation    #
#################################
if [ "$installMinikube" = true ]; then
    #install minkube
    sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
    sudo dpkg -i minikube_latest_amd64.deb

    #install kubectl
    sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \ 
    sudo chmod +x kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl

    #install conntrack needed to start minkube with driver=none 
    sudo apt -y install conntrack
fi

#Add vagrant user to docker group
#sudo usermod -aG docker $USER && newgrp docker

#start minikube 
#minikube start --driver=docker

##################################################################
#      mongodb & mongodb-express setup using k8s installation    #
##################################################################
if [ "$setupMongoEnv" = true ]; then
    #start minikube 
    minikube start --driver=docker

    cd /home/dockerLearn/kubernates

    #create secrete
    kubectl apply -f mongodb-secret.yaml 

    #create config map
    kubectl apply -f mongo-configmap.yaml

    #create mongo deployment & its internal service
    kubectl apply -f mongo-deployment.yaml

    #create mongo-express deployment & its external serice
    kubectl apply -f mongo-express-deployment.yaml

    #start the external service
    minikube service mongo-express-service

fi