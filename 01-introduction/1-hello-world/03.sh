#!/bin/bash

# Job Options- must be before *any* executable lines

#SBATCH --job-name="HelloWorld"
#SBATCH --output=HelloWorld.%J.out

echo "Hello, World from job ${SLURM_JOB_ID}"
