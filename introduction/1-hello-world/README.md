# Lets start at the very beginning

A job script is just a script submitted to Slurm.  01.sh is a very basic example:

```
#!/bin/bash

echo "Hello, World"
```

The hash-bang line ensures you get the shell you intend (`bash` is the default).  Everything that follows is executed within the job.  Submit this with:

```
sbatch 01.sh
```

Once this is run, you will have a file named something like `slurm-1234356.out` in this directory- the output should be:

```
Hello, World
```

Any other errors you can use to diagnose problems.

# More Options for Job Submission

One distinguishing feature of a Slurm batch job is that the script can contain options for the `sbatch` command.  The `sbatch` command has a bunch of different options to control the job and its execution- while you can use these on the command line, having these options within the script ensures consistent execution.  In the script `02.sh` we add a couple `sbatch` options:

```
#!/bin/bash

# Job Options- must be before *any* executable lines

#SBATCH --job-name="HelloWorld"
#SBATCH --output=HelloWorld.%j.out

echo "Hello, World"
```

Run this as above, using the command `sbatch 02.sh`.

This script adds two options for `sbatch`, one to set a job name for Slurm, the other to change the name of the output file.  The `%j` interpolates the job's identifier into the output name- including the job ID in the output is helpful when diagnosing execution problems.

These lines have the form `#SBATCH` followed by `sbatch` options as you'd put them on the command line.  Any options you add on the command line override options in the script.  For example, if you ran this script with the following command:

```
sbatch --output=foo-%j.out 02.sh
```

The output file would be named something like `foo-123456.out` (the number would be different, reflecting the job ID assigned by Slurm).

# Self awareness

There are a few mechanisms by which a job can know something of it's operation.  There are a number of environment variables set when the job executes on a node- these are all prefixed with `SLURM_` and contain different job attributes.

Script `03.sh` contains an example- the environment variable `SLURM_JOB_ID` contains the job ID assigned by Slurm.  We can use this in our script.  Submit the script `03.sh` with `sbatch 03.sh` and look in the output:

```
#!/bin/bash

# Job Options- must be before *any* executable lines

#SBATCH --job-name="HelloWorld"
#SBATCH --output=HelloWorld.%J.out

echo "Hello, World from job ${SLURM_JOB_ID}"
```

The output will contain the job's ID:

```
Hello, World from job 123456
```

The full list of environment variables is available in the manpage for `sbatch`
