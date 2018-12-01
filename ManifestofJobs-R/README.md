# Array jobs and R using a manifest

`taskArgumentManifest.csv`

This file contains on each row, a set of variables you want to use as input variables in R for a process.  This allows you to use a header in your csv to identify which column contains which variable, and not rely on order of arguments or any other uncertainties for passing variables in an R-friendly way.  

`Rtask.R`
This is the task that you want to do in R, and it takes as arguments the name of the manifest and the index of the array job that tells it which row in the manifest to take as input variables for the process.  Encourages you to have some sort of identifiable feedback to stdout at the end of your R process.  


`arrayjob-kickoff.sh`
This is what kicks off the set of jobs, and currently you have to specify the rows in the manifest that you want to run on this particular job, and the number of jobs you want to have running at once. Silly when you want to just run every row, not so silly if you need to re-run only select jobs. The name of the manifest file is passed to the script using the -J flag for `sbatch`.

To run, use this:
`sbatch -J manifest.csv arrayjob-kickoff.sh`

This will create a stderr and stdout file for each of the jobs, named the same as the manifest, with the jobID and the arrayID as well, so you know what all goes together (the manifest, the output/error files).  Currently to know which module environment the jobs were run in you have to have the version of `arrayjob-kickoff.sh` that you ran for full reproducibility/data provenance.  
