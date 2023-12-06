#!/bin/bash
#SBATCH -c 1
#SBATCH --gpus=1

set -e

MODULE="Apptainer/1.1.6"
me=$(basename $0)
rootpath=$(dirname $0)

echo "${me}: Running beginner example with ${MODULE}"
ml ${MODULE}
set -x
apptainer exec --nv docker://tensorflow/tensorflow:latest-gpu python ${rootpath}/beginner.py
set +x
echo "${me}: Script exited with code $?"
