#!/bin/bash
# use:  sbatch -J manifest.csv arrayjob-kickoff.sh
#SBATCH --output=%x_%A_%a.out
#SBATCH --error=%x_%A_%a.err
#SBATCH --array=1-2  # 1-452%20 # kicks off 453 jobs but only 20 can run at a time.

ml R/3.5.1-foss-2016b-fh1
Rscript consensusVariantCalling.R $SLURM_JOB_NAME
