#!/bin/bash
#=========================
# Stop all processes from
# the local MLFlow server
#=========================

echo 'List all MLFlow processes...'
# Need to filter out the grep process and
# the parent process (i.e. this running 
# script) with grep -v.
ps -u $USER -HF | grep mlflow | grep -v grep | grep -v step_04_stop_mlflow

echo 'Stopping all MLFlow processes...'
kill `ps -u $USER -HF | grep mlflow | grep -v grep | grep -v step_04_stop_mlflow | awk '{print $2}'`
echo 'Done stopping MLFlow.'

