#!/bin/bash
#SBATCH --array=1-5

# This demonstrates the use of job environment variables as arguments to
# a script.  This can be used as a replacement for loops- instead of:

# for NUM in {1..5}
# do
#   sbatch bin/square.py --sq=${NUM}
# end

# Just submit this as an array job:

bin/square.py --sq=${SLURM_ARRAY_TASK_ID}
