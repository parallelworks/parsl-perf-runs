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

Also, if you plan to run `parsl-perf` tests in a Kubernetes 
cluster or in a local, containerized SLURM cluster, now 
would be a good time to start those clusters if you have not
done so already. Example instructions for starting each of 
these different types of resources are provided below.

### Kubernetes cluster

There are many flavors of Kubernetes; for simplicity here
are instructions for using `kind` (i.e. "Kubernetes in Docker").
`kind` is nice to use in this context because it's very quick
to start and easy to define the number of Kubernetes worker 
nodes as described in [the `kind` docs](https://kind.sigs.k8s.io/docs/user/quick-start/#multi-node-clusters). The core steps are:
```
TBD
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
TBD
```

## 2) Run `parsl-perf` and log results with MLFlow

The wrapper script `run-parsl-perf.py` will start a local
MLFlow server, grab parameters (i.e. inputs) from the Parsl
configuration, run `parsl-perf` with the Parsl configuration,
and log the metrics (i.e. runtime outputs) to MLFlow.
```
run-parsl-perf.py <my_parsl_config.py>
```

