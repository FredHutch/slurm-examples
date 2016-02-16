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
    stop("Not enough arguments. Please start with args 'listsize', 'prepare', 'run <itemsize>', 'merge'")
}

# number if iterations in a loop, typically the lenth of a matrix,array,dataframe or vector
mylistsize<-33


# get the list size #########
if (args[1] == 'listsize') {
    cat(mylistsize)
}

# execute prepare job ##################
if (args[1] == 'prepare') {
    inputdata<-1000000 # some number
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
     
    
    for (i in (id+TASKID):(id+TASKID+STEPSIZE-1)) {
        print(paste(i, Sys.time(), TASKID, STEPSIZE, sep="   "))
        myrnd <- sample(i:10000,1,replace=T)        
        # save to a temp file and then rename it as last action !
        save(myrnd, file=paste0(MYSCRATCH,'/run/',i,"-run.dat.tmp"))
        file.rename(paste0(MYSCRATCH,'/run/',i,"-run.dat.tmp"),
                    paste0(MYSCRATCH,'/run/',i,"-run.dat"))
    }
}

# merge job ###########################
if (args[1] == 'merge') {
    mysum <- get(load(paste0(MYSCRATCH,'/input.dat')))
    for (i in 1:mylistsize) {
        print(paste(i, Sys.time(), sep="   "))
        outputdata <- get(load(paste0(MYSCRATCH,'/run/',i,"-run.dat")))
	mysum <- sum(mysum, outputdata)
    }
    print(paste('result:', mysum))
    save(mysum, file=paste0(RESULTDIR,'/result.dat'))
    print(paste0('saved result to: ', RESULTDIR, '/result.dat'))
}
