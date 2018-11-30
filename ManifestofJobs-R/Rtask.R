#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

# Test if there is not one argument: if not, return an error
if (length(args) != 1) {
  stop("One argument must be supplied, the manifest file name.n", call.=FALSE)
}

# Read in the specific manifest you indicated, then select the 
# row you want to use as arguments.
# Doing it this way rather than using "skip" and "nrows in the 
# read.csv preserves any column names you might have in the csv. 
manifest <- read.csv(args[1] , stringsAsFactors = F) 
thisRun <- manifest[Sys.getenv('SLURM_ARRAY_TASK_ID'),]

# Assign this run's arguments
thisVariable <- thisRun$thisVariable
thatVariable <- thisRun$thatVariable
thisOtherOne <- thisRun$thisOtherOne
thisToo <- thisRun$thisToo
########## Guts go here, decide what you want to return as stdout
theArguments <- paste(thisVariable, thatVariable, thisOtherOne, thisOtherOne, sep = ", ")
output <- c("Magic happened for this set of arguments:  ", theArguments)
##########
write(output, stdout())


