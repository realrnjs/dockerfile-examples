Dockerfile examples
======

Script env.sh reads config.yaml, so you don't need to update this script if you want to change something or to add new Docker image. Usage info:

    USAGE: ./env.sh option key

    Options:
        start
        stop
        restart
        build
        rebuild
        kill
        rm
        rmi

    Keys from config.yaml:

        redis
        mongo
        elasticsearch
        postgres
        mariadb

**NOTE:**
Images values in config.yaml needs to match directory name where Dockerfile is located.

Trusted images
======

Insted of building images on your machine you can get them from trusted image repository on public docker index:
https://index.docker.io/u/komljen/

If you skip build part with env.sh script, images will be automatically pulled from docker index.

Image layers
======

    |-- ubuntu:precise
	    |-- dockerfile/ubuntu
	        |-- dockerfile/redis
	        |-- dockerfile/postgres
	        |-- dockerfile/mariadb
	        |-- dockerfile/mongo
	        |-- dockerfile/jdk-oracle
	        |   |-- dockerfile/elasticsearch

Dependencies
======

Docker 1.3 and above. Installation on Ubuntu 14.04:

    wget -qO- https://get.docker.io/gpg | apt-key add -
    echo "deb http://get.docker.io/ubuntu docker main" > /etc/apt/sources.list.d/docker.list
    apt-get update
    apt-get -y install lxc-docker

Shyaml shell yaml parser:

    apt-get -y install python-pip && pip install shyaml

When all is ready clone this git repository:

    git clone https://github.com/komljen/dockerfile-examples.git && cd dockerfile-examples

Mac OSX
======

Requirements to run docker on Mac OSX:

- VirtualBox
- brew

Install and run boot2docker:

    brew install boot2docker
    boot2docker init
    boot2docker up

Export DOCKER_HOST variable and test if docker client is connected to server:

    docker ps

Tools required for my env.sh script:

    brew install python
    brew install libyaml
    pip install shyaml

Port forwarding example from localhost:8080 to port 80 inside boot2docker-vm:

    VBoxManage controlvm boot2docker-vm natpf1 "web,tcp,127.0.0.1,8080,,80"

When all is ready clone this git repository:

    git clone https://github.com/komljen/dockerfile-examples.git && cd dockerfile-examples
