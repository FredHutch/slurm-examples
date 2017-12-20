# Converting multi-prog to array

The example here shows how a simple multi-prog job can be converted to an array
job.  The advantage with an array job is that sbatch is used instead of srun
and that there are fewer files to maintain.

The goal of these two examples is to call an R script which prints out the iteration and round.  Each runs three iterations which has nine "rounds".  The output is saved into a file with a name like `result-<iteration>-<round>.out`.

`mp` contains the original multi-prog scripts.  `super.sh` runs a loop that
creates the multi-prog configuration file that runs `runscript` with a pair of
arguments, the iteration and round

`mp-sbatch` modifies the original multi-prog job submission to use sbatch to submit the job steps   `super.sh` runs a loop that
creates the multi-prog configuration file that runs `runscript` with a pair of
arguments, the iteration and round

`array` contains the array-based scripts required.  The R script is called with a single argument- the iteration.  The round is gleaned from the `SLURM_ARRAY_INDEX` environment variable.
