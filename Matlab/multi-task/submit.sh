#!/bin/bash


# Load the default Matlab module
ml matlab

echo $(which matlab)
# Run tasks
srun ./run-matlab.sh
