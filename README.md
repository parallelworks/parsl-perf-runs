# parsl-perf-runs
A space to keep track of `parsl-perf` run times 
across different computing resources, including
local machines, actual SLURM clusters, locally 
containerized SLURM clusters, and Kubernetes 
clusters.

The process for using 

## 1) Set up Conda environment

Since `parsl-perf` and `MLFlow` are easily installed
with `pip`, we can use `miniconda` with the `conda-forge`
channel. A typical invocation of the Conda env build
script looks like this:
```
step_01_build_conda_env.sh 
```

