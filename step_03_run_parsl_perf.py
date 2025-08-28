#=====================================
# Python wrapper to run parsl-perf
# and log params and metrics to MLFlow
#=====================================

#=====================================
# Get info from command line
#=====================================
import sys
import os
import importlib.util
import mlflow
from mlflow import MlflowClient
import subprocess

try:
    print('Will run parsl-perf based on this config file:')
    print(sys.argv[1])
except:
    print('Must provide name of Parsl config file on command line!')

try:
    print('Will set run name to input on command line:')
    print(sys.argv[2])
    run_name = sys.argv[2]
except:
    print('No run name detected. Will use randomized name!')
    run_name = None

#=====================================
# Load the Parsl config
#=====================================
#Parameters (i.e. inputs) are in the config
parsl_config_abs_dirname = os.path.dirname(os.path.abspath(sys.argv[1]))

print('Absolute dirname for Parsl config file:')
print(parsl_config_abs_dirname)
sys.path.append(parsl_config_abs_dirname)

parsl_config_filename = os.path.basename(sys.argv[1])
print('Parsl config filename:')
print(parsl_config_filename)

# This does not work for dynamic imports.
# Need to use importlib, below.
#import parsl_config_filename 

spec = importlib.util.spec_from_file_location(parsl_config_filename.split('.')[0], os.path.abspath(sys.argv[1]))
parsl_config_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(parsl_config_module)
print("Loaded Parsl config as a module:")
print(parsl_config_module)

#=====================================
# Grab key information from the config
#=====================================

# NOTE: This code (sort of) allows for multiple 
#       executors in a Parsl config, but since I do
#       not yet fully understand the implications 
#       of multiple executors, I do not know if 
#       this will be helpful for running parsl-perf.
#       Currently, if there are multiple executors,
#       it will simply loop through them and only the
#       parameters of the last executor will be
#       logged to MLFlow.
for executor in parsl_config_module.config.executors:

    #=========================
    # Get executor name
    #=========================
    executor_name = str(executor).split('(')[0]
    print('Found executor: '+executor_name)

    # Get cores_per_worker for this executor
    # NOTE: FluxExecutor does not have this parameter!
    #       Also, FluxExecutor checkes for the presence of
    #       Flux during the loading of the config.
    # TODO: Extract cores per worker
    #       from the Flux launch_cmd.
    cores_per_worker = executor.cores_per_worker
    print('Found cores_per_worker: '+str(cores_per_worker))

    #===========================
    # Get the provider name
    #===========================
    provider_name = str(executor.provider).split('(')[0]
    print('Found provider: '+provider_name)

    #===========================
    # Get Provider parameters
    #===========================

    # Should always be 1 for LocalProvider?
    nodes_per_block = executor.provider.nodes_per_block
    print('Found nodes_per_block: '+str(nodes_per_block))

    # Cannot get cores_per_node for LocalProvider or
    # KubernetesProvider?
    if provider_name == 'LocalProvider':
        cores_per_node = os.cpu_count()
    elif provider_name == 'KubernetesProvider':
        # I don't know if this is strictly correct
        cores_per_node = executor.provider.max_cpu
    else:
        cores_per_node = executor.provider.cores_per_node
    print('Found cores_per_node: '+str(cores_per_node))

    min_blocks = executor.provider.min_blocks
    print('Found min_blocks: '+str(min_blocks))

    # Should always be 1 for LocalProvider?
    max_blocks = executor.provider.max_blocks
    print('Found max_blocks: '+str(max_blocks))

    # Handy derived parameters
    if provider_name == 'LocalProvider':
        max_nodes = 1
    else:
        max_nodes = nodes_per_block*max_blocks
    max_cores = cores_per_node*max_nodes
    print('Calculated max_nodes: '+str(max_nodes))
    print('Calculated max_cores: '+str(max_cores))

#=====================================
# Run parsl-perf and gather metrics
#=====================================

try:
    result = subprocess.run(
            ['parsl-perf', '--config', os.path.abspath(sys.argv[1])], 
            capture_output=True, text=True, check=True)
    print("STDOUT:")
    print(result.stdout)
    print("STDERR:")
    print(result.stderr)
except subprocess.CalledProcessError as e:
    print(f"Command failed with exit code {e.returncode}")
    print(f"Error output: {e.stderr}")

parsl_version = result.stdout.split('\n')[0]

num_iterations = int(len(result.stdout.split('Iteration')) - 1)

# Loop over all iterations, but currently only store
# the results from the last iteration (each successive
# iteration's results overwrites the previous iteration's
# results. This results in excess computations, but provides
# a framework that could be used to store all iteration results
# later, if desired.
#
# Also, the text parsing here will need to be changed if the
# stdout of parsl-perf changes significantly.
for ii in range(1,len(result.stdout.split('Iteration'))):
    num_tasks = int(result.stdout.split('Iteration')[ii].split(' ')[4])
    submission_s = float(result.stdout.split('Iteration')[ii].split(' ')[23])
    submission_tps = float(result.stdout.split('Iteration')[ii].split(' ')[26])
    runtime_s = float(result.stdout.split('Iteration')[ii].split(' ')[29].split('s')[0])
    runtime_tps = float(result.stdout.split('Iteration')[ii].split(' ')[35].split('\n')[0])

#============================================
# Log tags, parameters, and metrics to MLFlow
#============================================

# Assume here that all runs are being associated with
# the same experiment. See README.md for how to create
# experiments.
experiment_name="parsl-perf-exp-01"

# Connect to MLFlow
client = MlflowClient(tracking_uri = "http://127.0.0.1:8081")
mlflow.set_tracking_uri("http://127.0.0.1:8081")
experiment = mlflow.set_experiment(experiment_name)

with mlflow.start_run(
    run_name=run_name,
    tags={
        "Parsl version": parsl_version,
        "Parsl Executor": executor_name, 
        "Parsl Provider": provider_name,
    }):
    mlflow.log_param("cores_per_worker", cores_per_worker)
    mlflow.log_param("nodes_per_block", nodes_per_block)
    mlflow.log_param("cores_per_node", cores_per_node)
    mlflow.log_param("min_blocks", min_blocks)
    mlflow.log_param("max_blocks", max_blocks)
    mlflow.log_param("max_nodes", max_nodes)
    mlflow.log_param("max_cores", max_cores)

    mlflow.log_metric("num_iterations",num_iterations)
    mlflow.log_metric("num_tasks",num_tasks)
    mlflow.log_metric("submission_s",submission_s)
    mlflow.log_metric("submission_tps",submission_tps)
    mlflow.log_metric("runtime_s",runtime_s)
    mlflow.log_metric("runtime_tps",runtime_tps)

#========
# Done!
#========
