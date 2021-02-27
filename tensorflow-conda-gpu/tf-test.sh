#!/bin/bash

set -xe

module load Anaconda3

. /app/software/Anaconda3/2020.02/etc/profile.d/conda.sh

conda activate tfconda

env

./tf-test.py
