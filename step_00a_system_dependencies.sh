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
#newgrp docker << EOF
#EOF
# The above doesn't work, which is why
# there is a step_00b script with the 
# docker steps. Execute 00b after running
# this script, closing the terminal, and
# logging back in.

# Start Docker
sudo systemctl start docker

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
# Install Docker compose for containerized
# (i.e. local) SLURM cluster
#======================================

# Gives you access to docker compose
# (NOTE THE SPACE!!!! Not hyphenated docker-compose.)
sudo yum -y install docker-compose-plugin

# Just in case you need it...
alias docker-compose='docker compose'

# Alternative methods to installing docker-compose
#------------------------
# Never worked for me, but I wasn't particularly
# careful about my Conda env at the time.
# pip install docker-compose
#------------------------
# This did work but more complicated, based on docs:
# https://docs.docker.com/compose/install/linux/#install-the-plugin-manually
#DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
#mkdir -p $DOCKER_CONFIG/cli-plugins
#curl -SL https://github.com/docker/compose/releases/download/v2.39.1/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose

echo 'Done installing system-level dependencies.'

