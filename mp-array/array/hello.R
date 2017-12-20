#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

iteration = args[1]
round = Sys.getenv('SLURM_ARRAY_TASK_ID')

print( paste("iteration", iteration, "round", round))
