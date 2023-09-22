# Array Jobs

## Overview

An array job allows you to submit and manage many related jobs as a unit.  A submitted array job will have a "master" job ID with each task within the job having both its own job ID and a task ID.

## How to Submit an Array Job

Add the `--array` option and a sequence of numbers to use for indices:

```
sbatch --array=1-10 ... other sbatch options ...
```

This will submit an array of 10 jobs- each task within this job array will have a task ID ranging from 1 to 10.

# Index of Examples

> All of the contained examples have default arguments in the scripts- so these
> can be run just with `sbatch <script_name>`.  Any arguments you use in the
> command line will override those built into the script

## 01.sh - Accessing Task Details

Task details are available in the job's environment:

 - SLURM_ARRAY_TASK_ID: the task "rank"
 - SLURM_ARRAY_JOB_ID: the ID of the master job.
 - SLURM_ARRAY_TASK_COUNT: the number of tasks in the job array

The example `01.sh` contains examples of how these can be accessed in the submitted job.

## 02.sh - Using Task ID for Input Arguments

The value of those environment variables can be used as input arguments to other tools.  Example script `02.sh` contains a sample of how array task IDs can be used as input for another script.

## 03.sh - Array Job Output

There are additional values that can be interpolated into the jobs output.  In addition to `%j` there is `%A` which contains the master job ID and `%a` which contains the task ID.

Example script `03.sh` produces output files containing the master job ID, the "raw" or "real" job ID assigned when the job is allocated, and the task ID.  The output file names appear similar to `example_53257376_53257386_12.out`
