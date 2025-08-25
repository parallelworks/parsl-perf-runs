#!/bin/bash
#================================
# Example system dependency setup
#================================
# Normally, users will not be able 
# to do this on all systems nor
# will they need all steps. This
# script is provided as-is for examples.


#=========================
# Add user to Docker group
#=========================

# This group is probably already present
# if you have already installed Docker
#sudo groupadd docker

# Add user to docker group:
sudo usermod -aG docker $USER

# Reset group info. This doesn't run well
# in a script, so really the best way is
# to exit the shell and log back in.
newgrp docker << EOF
EOF

# Start Docker
sudo systemctl start docker

# Test non-root user access:
docker run hello-world

echo 'Done adding user to Docker group'

#===========================
# Other installations
#===========================

# Install Kind to $(go env GOPATH):
go install sigs.k8s.io/kind@v0.29.0
echo 'Successfully installed Kind. To use it,'
echo 'please run: export PATH=$PATH:$(go env GOPATH)/bin'

# Install kubectl
sudo yum -y install kubectl
echo 'Done installing kubectl'

#======================================
# Pull container for Kubernetes cluster
#======================================

# This container will need to be uploaded
# into the kind cluster later. But, you
# first must have a local copy.
# See Dockerfiles directory for how this
# container was built.
docker pull stefanfgary/pythonparsl

#======================================
# Install Docker compose for containerized
# (i.e. local) SLURM cluster
#======================================
sudo yum -y install docker-compose-plugin

#======================================
# Build container for SLURM cluster
#======================================
git clone https://github.com/giovtorres/slurm-docker-cluster
# Consider adding Parsl and Flux to the container.
cd slurm-docker-cluster
docker build --build-arg SLURM_TAG="slurm-21-08-6-1" -t slurm-docker-cluster:21.08.6 .

echo 'Done setting up.'

