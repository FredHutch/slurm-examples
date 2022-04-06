#!/bin/bash
#SBATCH --array=4-14
#SBATCH --output=example_%A_%j_%a.out

# This is a basic array job.  Submit with `sbatch ./01.sh`

echo "Hello- I'm task ${SLURM_ARRAY_TASK_ID} of job ${SLURM_ARRAY_JOB_ID}"
echo "There are ${SLURM_ARRAY_TASK_COUNT} tasks in this array"
