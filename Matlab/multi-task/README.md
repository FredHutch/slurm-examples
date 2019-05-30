
# Index of Files

`script.m`

The matlab script itself.  Only sets a variable `task_id` based on the task
index set in Slurm

`run-matlab.sh`

A wrapper to get Matlab to run this script in a non-interactive fashion

`submit.sh`

The script submitted to Slurm.  Uses `srun` to run the wrapper above

# Use

## Four cores on one host

    sbatch -p restart -t 00:10:00 -n 4 -c 1 -N 1 ./submit.sh

## Run on multiple hosts

    sbatch -p restart -t 00:10:00 -n 4 -c 1 ./submit.sh

