#! /usr/bin/env Rscript

# get environment variables
MYSCRATCH <- Sys.getenv('MYSCRATCH')
RESULTDIR <- Sys.getenv('RESULTDIR')
STEPSIZE <- as.numeric(Sys.getenv('STEPSIZE'))
TASKID <- as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID'))

# set defaults if nothing comes from environment variables
MYSCRATCH[is.na(MYSCRATCH)] <- '.'
RESULTDIR[is.na(RESULTDIR)] <- '.'
STEPSIZE[is.na(STEPSIZE)] <- 1
TASKID[is.na(TASKID)] <- 0

# get command lines arguments
args <- commandArgs(trailingOnly = TRUE)
if(length(args) < 1){
    stop("Not enough arguments. Please use args 'listsize', 'prepare', 'run <itemsize>' or 'merge'")
}

# number if iterations in a loop, typically the lenth of a matrix,array,dataframe or vector
mylistsize<-33
expectsum<-1000 # 1+2+3+4...+ 33 = 561 + inputdata

# get the list size #########
if (args[1] == 'listsize') {
    cat(mylistsize)
}

# execute prepare job ##################
if (args[1] == 'prepare') {
    inputdata<-439 # some number, e.g. 1000-561=439
    save(inputdata, file=paste0(MYSCRATCH,'/input.dat'))
    print(paste0('initial value saved to: ', MYSCRATCH, '/input.dat'))
}

# execute parallel job #################################################
if (args[1] == 'run') {
    if (length(args) < 2) {
        stop("Not enough arguments. 'run' needs a second argument 'id'")
    }
    id<-as.numeric(args[2])
    inputdata <- get(load(paste0(MYSCRATCH,'/input.dat')))
    print(paste(Sys.time(), "arrid:" , id, "TASKID:",
		TASKID, "STEPSIZE:", STEPSIZE))
    for (i in (id+TASKID):(id+TASKID+STEPSIZE-1)) {
        print(paste(Sys.time(), "i:" , i))
        # save to a temp file and then rename it as last action !
        save(i, file=paste0(MYSCRATCH,'/run/',i,"-run.dat.tmp"))
        file.rename(paste0(MYSCRATCH,'/run/',i,"-run.dat.tmp"),
                    paste0(MYSCRATCH,'/run/',i,"-run.dat"))
    }
}

# merge job ###########################
if (args[1] == 'merge') {
    mysum <- 0
    for (i in 1:mylistsize) {
        print(paste(Sys.time(), "i:" , i))
        outputdata <- get(load(paste0(MYSCRATCH,'/run/',i,"-run.dat")))
	mysum <- sum(mysum, outputdata)
    }
    mysum <- sum(mysum, get(load(paste0(MYSCRATCH,'/input.dat'))))
    print(paste('result:', mysum, 'expected:', expectsum))
    save(mysum, file=paste0(RESULTDIR,'/result.dat'))
    print(paste0('saved result to: ', RESULTDIR, '/result.dat'))
}
