# Centipede Slurm example

scentipede is a command that can make using a slurm cluster much easier. 
This shell script helps submitting many thousand short running jobs to a
slurm cluster. The script goes through 4 phases of a typical HPC pipeline:

1. Data preparation, 2. parallel execution, 3. error correction, 4. merge
of data. 

It assumes that you want to launch another script (e.g. using R
or Python) which is set in the SCRIPT variable below. In this case it
assumes that SCRIPT takes several command line args each of which tell
SCRIPT to execute one of the 4 different phases. 
Arguments for example.R:
 Phase 0: ./example.R listsize  (get array size - not run via slurm)
 Phase 1: ./example.R prepare   (initial data preparation)
 Phase 2: ./example.R run xx    (run listsize # of jobs)
 Phase 3: ./example.R run xx    (only the failed jobs having no outfile) 
 Phase 4: ./example.R merge     (merge the output files) 

This script (submit slurm) can take 2 arguments, SCRIPT and JOBNAME

```
JOBNAME='myJob'            # change for every analysis you run (2nd arg)
MAILDOM='@fredhutch.org'   # your email domain (for receiving error messages)
MAXARRAYSIZE=10          # set to 0 if you are not using slurm job arrays
MYSCRATCH="./scratch/${JOBNAME}"  # location of your persistent scratch dir
PARTITION='boneyard'        # the queue on your cluster that allows short jobs
RESULTDIR="./result/${JOBNAME}"  # This is a folder in permanent storage
SCRIPT='./example.R'       # your code as (R or Python) script (1st arg)
STEPSIZE=2                 # number of consequtive loops in SCRIPT to run in
                           # the same job / node (increase for short jobs)
```

---

# Presentation
- This readme is also a [presentation](http://fredhutch.github.io/slurm-examples)

---

# Configuration
Before and during implementation, we kept the following goals in mind:

---
