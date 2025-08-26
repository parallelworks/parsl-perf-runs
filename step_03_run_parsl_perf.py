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

try:
    print('Will run parsl-perf based on this config file:')
    print(sys.argv[1])
except:
    print('Must provide name of Parsl config file on command line!')

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
for executor in parsl_config_module.config.executors:
    # Get executor name
    executor_name = str(executor).split('(')[0]
    
    print(executor)

    # Get cores_per_worker for this executor
    # NOTE: FluxExecutor does not have this parameter!
    #       Also, FluxExecutor checkes for the presence of
    #       Flux during the loading of the config.
    # TODO: Extract cores per worker
    #       from the Flux launch_cmd.
    cores_per_worker = executor.cores_per_worker

    # Get the provider name
    provider_name = str(executor.provider).split('(')[0]
    
    # Get Provider parameters

    # Should always be 1 for LocalProvider
    nodes_per_block = 1

    cores_per_node = 1
    

    min_blocks = 1

    # Should always be 1 for LocalProvider?
    max_blocks = 1

    # Handy derived parameters
    max_nodes = nodes_per_block*max_blocks
    max_cores = cores_per_node*max_nodes

#=====================================
# Log parameters to MLFlow
#=====================================

#=====================================
# Run parsl-perf
#=====================================

#=====================================
# Log metrics to MLFlow
#=====================================

