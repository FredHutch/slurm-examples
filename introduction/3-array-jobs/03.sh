#!/bin/bash
#SBATCH --array=4-14
# Save output from job into file containing job data in the file name
#SBATCH --output=example_%A_%j_%a.out

echo "Hello- I'm task ${SLURM_ARRAY_TASK_ID} of job ${SLURM_ARRAY_JOB_ID}"
echo "There are ${SLURM_ARRAY_TASK_COUNT} tasks in this array"
