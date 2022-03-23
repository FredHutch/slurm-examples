#!/bin/bash

#SBATCH --array=1-12
#SBATCH --nodes=1
#SBATCH --output=Rout/par-%J.out
#SBATCH --error=Rout/par-%J.err
#SBATCH --cpus-per-task=1

ml fhR/4.0.4-foss-2020b

R CMD BATCH --no-save  R_cluster_example.R Rout/example_slurm${SLURM_ARRAY_TASK_ID}.Rout
