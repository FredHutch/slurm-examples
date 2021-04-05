In this example, we provide another way to run simple parallel computing using an R script and a batch file. This involves an R file: `R_cluster_example.R` and an sh file: `example.sh`. First will walk through the `example.sh` file. 

## `example.sh`

This is the batch script that contains the `sbatch` parameters.
```
#!/bin/bash

#SBATCH --array=[1-12]
#SBATCH --nodes=1
#SBATCH --output=Rout/par-%J.out
#SBATCH --error=Rout/par-%J.err
#SBATCH --cpus-per-task=1

ml fhR/4.0.4-foss-2020b

R CMD BATCH --no-save  R_cluster_example.R Rout/example_slurm${SLURM_ARRAY_TASK_ID}.Rout
```

These options are explained in more detail elsewhere ([Using Slurm on Hutch Systems](https://sciwiki.fredhutch.org/computing/cluster_usingSlurm/)). 

Note that the output directory for `--error` and `--output`- in this case `Rout`- must exist before you submit the job (e.g. `mkdir Rout`).

```
#SBATCH --array=[1-15]
```

This tells the system that we are running 15 jobs. This can be changed to other options as well. 
```
R CMD BATCH --no-save  R_cluster_example.R
```
This tells the system to run `R_cluster_example.R` non-interactively. Given the `SBATCH --array=[1-15]` option above it will run it non-interactively 15 times, with each job having a different `TASK_ID.` This part is key as we will use this in our `R_cluster_example.R` file. 


## `R_cluster_example.R`

This file has the actual R code which runs the simulations that we want to perform. While in this example it is simply simulations, it can easily be changed to refer to files or any other parallel jobs want to perform. The key line in it is

```
touse<-as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID'))
```

This picks which of the 15 jobs are being run. For example it will know that is currently performing job 1, or job 13. Then to make it so that each R run is different we can create a conditional table of all the scenariors that we want to run:

```r
#######
#Create table of simulation scenarios
#######
TabTabTabby<-expand.grid(c(0,0.5,1), #effect estimates
                          seq(200,1000,by=200))# sample size

#######
#Grab what parameters using for this run
#######
BetaUse<-TabTabTabby[touse,1]
N<-TabTabTabby[touse,2]
```

And then more things are done further on in the script `R_cluster_example.R`. The second most important bit of code is the R object `TabTabTabby`. In this scenario it has information on the simulation parameters but it could be a vector of file locations that are then read in by R. Also, notice `TabTabTabby` is a 15 by 2 data.frame with each row representing a different simulation scenario we want to evaluate. Therefore each `'SLURM_ARRAY_TASK_ID'` refers to a different simulation we want to run.

Now, while this code is set up for a simulation example, we could easily be referencing a manifest file where each line in that file is different parameter settings we are interesting in running. For an example of this, see [Manifest of Jobs and R](/ManifestofJobs-R/).

## Finally running the code

When you are ready to go. You simply run on the command line:

```
mkdir -p Rout Output
sbatch example.sh
```

This is just one example of how to run parallel R jobs within slurm. More examples on how to run parallel jobs can be found in this repository ([slurm example](https://github.com/FredHutch/slurm-examples)). 
