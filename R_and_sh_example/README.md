In this example, we provide another way to run simple parallel computing using an R script and a batch file. This involves an R file: `R_cluster_example.R` and an sh file: `example.sh`. First will walk through the `example.sh` file. 

##`example.sh`
This is the batch script that contains the `sbatch` parameters.

>#!/bin/bash<br/>
>#SBATCH --mail-user=<span>fred</span>@fredhutch.org <br/>
>#SBATCH --mail-type=END<br/>
>#SBATCH --array=[1-12]<br/>
>#SBATCH --nodes=1<br/>
>#SBATCH --output=Rout/par-%J.out<br/>
>#SBATCH --error=Rout/par-%J.err<br/>
>#SBATCH --cpus-per-task=1<br/>

>ml R/3.4.3-foss-2016b-fh2<br/>

>R CMD BATCH --no-save  R_cluster_example.R Rout/example_v_indep${SLURM_ARRAY_TASK_ID}.Rout<br/>

These options are explained in more detail elsewhere ([Using Slurm on Hutch Systems](#FredHutch/cluster_rhinoGizmo.md))
