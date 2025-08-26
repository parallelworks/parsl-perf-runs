#!/bin/bash
#=============================
# Start MLFlow server
#=============================

# Use pwd so we can define the absolute 
# path for the ./parsl-perf-archive.
#
# Log locally all server stdout and stderr
# Git is setup to ignore these logs - they
# are generally only for debugging.
#
# This server is running on the localhost
# (127.0.0.1) and its GUI can be accessed
# with a local browser at localhost:8081.
#
# If you have other web apps running
# (i.e. parsl-visualize) you'll need to 
# ensure that they aren't using the same
# local port as MLFlow.
#mlflow server --host 127.0.0.1 --port 8081 --backend-store-uri ${PWD}/parsl-perf-archive > mlflow.main.stdout.log 2> mlflow.main.stderr.log &
mlflow server --host 127.0.0.1 --port 8081 --backend-store-uri /home/sfgary/mlflow-explore/archive > mlflow.main.stdout.log 2> mlflow.main.stderr.log &
mlflow_pid=$!

echo "MLFlow started!"
echo "To stop MLFlow, kill process $mlflow_pid"
