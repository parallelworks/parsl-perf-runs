# parsl-perf-runs
A space to keep track of `parsl-perf` run times 
across different computing resources, including
local machines, actual SLURM clusters, locally 
containerized SLURM clusters, and Kubernetes 
clusters.

The steps for using this repository are:
+ Install system dependencies (only needed if you want to run on Kubernetes or containerized SLURM)
+ Build a Conda environment (installs Parsl and MLFlow)
+ If you will want to contribte public results, create a new branch and check it out.
+ Start local MLFlow server
+ Define a Parsl configuation
+ Run `parsl-perf` and results will be pushed into MLFlow (this can be run any number of times)
+ If you want to contribute public results, use `git` to `add`, `commit`, and `push` the results on your branch and make a pull request.

## 0) System dependencies

If you want to run `parsl-perf` on a Kubernetes 
cluster or a containerized Slurm cluster, you'll
need to install some additional software if you
don't have it already. Many of these steps
require `sudo` priviledges.

## 1) Set up Conda environment

Since `parsl-perf` and `MLFlow` are easily installed
with `pip`, we can use `miniconda` with the `conda-forge`
channel. A typical invocation of the Conda env build
script looks like this:
```
# Build parsl-mlflow environment
step_01_build_conda_env.sh /home/<username>/.miniconda3 parsl-mlflow

# Get access to environment
source /home/<username>/.miniconda3/etc/profile.d/conda.sh
conda activate parsl-mlflow
```

## Define a Parsl configuration

This section is not a numbered step since it requires manually 
selecting one of the Parsl configs provided in the `parsl-configs`
directory or creating your own. You are welcome to include your 
own configurations when pushing results back to this repository. 
Please put these configurations in `parsl-configs` and follow the 
naming convention:
```
TBD
```

## Start local clusters - OPTIONAL

If you plan to run `parsl-perf` tests in a local Kubernetes 
cluster or in a local, containerized SLURM cluster, now 
would be a good time to start those clusters if you have not
done so already. If you are planning on using an existing
cluster (i.e. you have logged into a cluster or you are
testing only on your local machine) you can skip this section.

Example instructions for starting a local Kubernetes cluster
or a local containerized Slurm cluster are provided below. Note
that these instructions may not necessarily work everywhere.

### Local Kubernetes cluster

There are many flavors of Kubernetes; for simplicity here
are instructions for using `kind` (i.e. "Kubernetes in Docker").
`kind` is nice to use in this context because it's very quick
to start and easy to define the number of Kubernetes worker 
nodes as described in [the `kind` docs](https://kind.sigs.k8s.io/docs/user/quick-start/#multi-node-clusters).

An example `kind` cluster configuration with two nodes 
(to match the default two node config in the local 
containerized SLURM cluster) and a `Dockerfile` for the
worker image are provided in the `k8s` directory. The core steps are:
```
# Make certain you have access to kind executables
export PATH=$PATH:$(go env GOPATH)/bin

# The controller node should come up in about a minute.
kind create cluster --name <my_cluster_name> --config <my_cluster_config>

# The name defaults to `kind` which results in the the
# kubectl context of `kind-<my_name>` or `kind-kind`.
# You can use kind to list the available clusters:
kind get clusters

# What's going on with the cluster:
kubectl cluster-info --context kind-kind
kubectl get pods --context kind-kind

# If you want to use a specific container in
# the cluster, you need to load it into the cluster
# (--name is the name of the KIND cluster, and first
# arguement after docker-image is the name of the image
# that is already pulled locally).
kind load docker-image stefanfgary/pythonparsl --name <my_cluster_name>
```

### Local, containerized Slurm cluster

There are at least two public containerized Slurm cluster
frameworks:
+ [rancavil/slurm-cluster](https://github.com/rancavil/slurm-cluster/)
+ [giovtorres/slurm-docker-cluster](https://github.com/giovtorres/slurm-docker-cluster)
The former is described succintly in [this blog post](https://medium.com/analytics-vidhya/slurm-cluster-with-docker-9f242deee601). The latter is used here mostly 
because it seems to be more up to date and provides more options for
configuring the cluster. The core steps for starting the cluster are:
```
# Build/get the cluster container image
# (This is already done in step_00b_docker_steps.sh)

# If on a PW cloud cluster head node, stop
# the SLURM daemon and database services
# because they are listening on port 6819
# which is used by the docker-compose SLURM
# cluster. There's got to be a way around this,
# but just tear things down for now.
sudo systemctl stop slurmctld.service
sudo systemctl stop slurmdbd.service

# Get the repo with the Docker-compose file:
# (Already done in step_00b_docker_steps.sh)
cd slurm-docker-cluster

# Launch the cluster
docker-compose up -d

# Register
./register_cluster.sh

# Easy enough to add more nodes (containers) on the fly.
# Modify slurm.conf in three places - the two lists of nodes in 
# NodeName and PartitionName, and MaxNodes in PartitionName.
# Then run:
./update_slurmfiles.sh slurm.conf slurmdbd.conf
docker compose restart

# Stop
docker compose stop

# Clean up
docker compose down -v
```

## 2) Start local MLFlow server

Use `step_02_start_mlflow.sh` for this step. Some 
MLFlow server configuration options are hard-coded
in the script and explained there.

## 3) Run `parsl-perf` and log results with MLFlow

The wrapper script `run-parsl-perf.py` will start a local
MLFlow server, grab parameters (i.e. inputs) from the Parsl
configuration, run `parsl-perf` with the Parsl configuration,
and log the metrics (i.e. runtime outputs) to MLFlow.
```
run-parsl-perf.py <my_parsl_config.py>
```

