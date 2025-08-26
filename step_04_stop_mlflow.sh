#!/bin/bash
#=========================
# Stop all processes from
# the local MLFlow server
#=========================

echo $USER

echo 'Stopping all MLFlow processes...'
kill `ps -u $USER -HF | grep mlflow | grep -v grep | awk '{print $2}'`
echo 'Done stopping MLFlow.'

