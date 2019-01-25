#!/bin/bash

#SBATCH --mail-user=fred@fredhutch.org
#SBATCH --mail-type=END
#SBATCH --array=[1-12]
#SBATCH --nodes=1
#SBATCH --output=Rout/par-%J.out
#SBATCH --error=Rout/par-%J.err
#SBATCH --cpus-per-task=1

ml R/3.4.3-foss-2016b-fh2

R CMD BATCH --no-save  R_cluster_example.R Rout/example_v_indep${SLURM_ARRAY_TASK_ID}.Rout
