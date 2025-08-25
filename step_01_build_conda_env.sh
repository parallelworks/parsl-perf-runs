#!/bin/bash
#===========================
# Download Miniconda, install,
# and create a tiny new environment.
#
# Specify the Conda install location
# and environment name, e.g.:
#
# ./create_conda_env.sh ${HOME}/.miniconda3 tiny
#
# With a fast internet connection
# (i.e. download time minimal)
# this process takes < 5 min.
#
# It is possible to put a
# miniconda directory in a tarball
# but the paths will need to be
# adjusted.  The download and
# decompression time can be long.
# As an alternative, consider:
# conda list -e > requirements.txt
# to export a list of the req's
# and then:
# conda create --name <env> --file requirements.txt
# to build another env elsewhere.
# This second step runs faster
# than this script because
# Conda does not stop to solve
# the environment.  Rather, it
# just pulls all the listed
# packages assuming everything
# is compatible.
#
# Another alternative is to export
# a Conda env to a .yaml file:
# conda env export --name my_env > requirements.yaml
# and then build an environment from
# this .yaml:
# conda env update --name my_new_env -f requirements.yaml
#
# Using a .txt or .yaml is often
# much faster than explicitly listing
# several conda install commands in
# a script. This is because the
# dependencies are already resolved
# in the .txt and .yaml files (i.e.
# they come from already working
# Conda envs) whereas the solving
# process needs to be started over
# from scratch when explicitly listing
# conda install commands.
#===========================

echo Starting $0

# Miniconda install location
# The `source` command somehow
# doesn't always work with "~", so best
# to put an absolute path here
# if putting Miniconda in $HOME.
miniconda_loc=$1

# Download current version of
# Miniconda installer
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

# Run Miniconda installer
chmod u+x ./Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh -b -p $miniconda_loc

# Clean up
rm ./Miniconda3-latest-Linux-x86_64.sh

# Define environment name
my_env=$2

# Define specific versions here
# or leave blank to use whatever
# is automatically selected.
# Example for Python 3.7
python_version="=3.7"
# Example for whatever version of Python is
# the default in Miniconda latest.
python_version=""

# Start conda and remove default channels
# and add conda-forge.
source ${miniconda_loc}/etc/profile.d/conda.sh
conda config --add channels conda-forge
conda config --remove channels defaults
conda config --add channels nodefaults

# Create new environment while also being extra careful
# to avoid the default channels.
# (if you want to run a Jupter notebook in this env,
# include ipython here)
conda create -y --name $my_env -c conda-forge --override-channels python${python_version}

# Jump into new environment
conda activate $my_env

# Install optional packages if needed.
#conda install -y -c conda-forge dask

# Pip packages last
pip install parsl[monitoring,kubernetes]
pip install mlflow

echo Finished $0

