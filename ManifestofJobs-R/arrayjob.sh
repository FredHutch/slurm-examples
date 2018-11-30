#!/bin/bash
#SBATCH --job-name=18-11-30-consensusVariantCalling
#SBATCH --output=18-11-30-consensusVariantCalling_%A_%a.out
#SBATCH --error=18-11-30-consensusVariantCalling_%A_%a.err
#SBATCH --array=1-452%20 # kicks off 453 jobs but only 20 can run at a time.

ml R/3.5.1-foss-2016b-fh1
Rscript consensusVariantCalling.R 18-11-30-forConsensusProcessing-corrected.csv
