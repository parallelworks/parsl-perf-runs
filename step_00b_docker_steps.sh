#!/bin/bash
#================================
# Example system dependency setup
#================================
# Normally, users will not be able 
# to do this on all systems nor
# will they need all steps. This
# script is provided as-is for examples.

#==========================
# Test non-root user access
#==========================
docker run hello-world

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
# Build container for SLURM cluster
#======================================
git clone https://github.com/giovtorres/slurm-docker-cluster
# Consider adding Parsl and Flux to the container.
cd slurm-docker-cluster
docker build --build-arg SLURM_TAG="slurm-21-08-6-1" -t slurm-docker-cluster:21.08.6 .

echo 'Done with Docker steps.'

