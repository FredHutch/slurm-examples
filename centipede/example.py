#! /usr/bin/env python3

import sys, os, argparse, pickle, random
import os.path as op

# get environment variables
MYSCRATCH = os.getenv('MYSCRATCH', '.')
RESULTDIR = os.getenv('RESULTDIR', '.')
STEPSIZE = int(os.getenv('STEPSIZE', 1))
TASKID = int(os.getenv('SLURM_ARRAY_TASK_ID', 0))

def main():

    # number if iterations in a loop, typically the lenth of a list,array or dictionary
    mylistsize=33

    # get the list size #####
    if args.phase == 'listsize':
        print(mylistsize)
		
    # execute prepare job ##########################
    if args.phase == 'prepare':
        inputdata=1000000 # some number
        save(inputdata, op.join(MYSCRATCH,'input.dat'))

    # execute parallel job ############################################
    if args.phase == 'run':
        inputdata = load(op.join(MYSCRATCH,'input.dat'))
        print("id:%s TASKID:%s STEPSIZE:%s" % (args.id, TASKID, STEPSIZE))
        for i in range(args.id+TASKID,args.id+TASKID+STEPSIZE):
            print("i:",i)
            myrnd = random.randint(i, 10000)
            # save to a temp file and then rename it as last action !
            save(myrnd, op.join(MYSCRATCH,'run','%s-run.dat.tmp' % i))
            os.rename(op.join(MYSCRATCH,'run','%s-run.dat.tmp' % i),
                      op.join(MYSCRATCH,'run','%s-run.dat' % i))

    # merge job ########################
    if args.phase == 'merge':
        mysum = load(op.join(MYSCRATCH,'input.dat'))
        print("id:%s TASKID:%s STEPSIZE:%s" % (args.id, TASKID, STEPSIZE))
        for i in range(1,mylistsize):
            print("i:",i)
            outputdata = load(op.join(MYSCRATCH,'run','%s-run.dat' % i))
            mysum = mysum + outputdata
        print("result: ", mysum)
        save(mysum, op.join(RESULTDIR,'result.dat'))
        print("saved result to: ", op.join(RESULTDIR,'result.dat'))

def save(obj, filename):
    with open(filename, 'wb') as f:
        pickle.dump(obj, f, -1)
    return True

def load(filename):
    with open(filename, 'rb') as f:
        return pickle.load(f)

def parse_arguments():
    """
    get command-line arguments.
    """
    parser = argparse.ArgumentParser(prog='example.py',
        description="a little sample script for for running python code  " + \
            "on a HPC cluster. It requires one of the arguments  'listsize', " + \
            "'prepare', 'run <itemsize>', 'merge'.")
    parser.add_argument("phase", help="the phase to run ")
    parser.add_argument( 'id', type=int, default=None, nargs='?',
        help="an id required for the run phase")    
    return parser.parse_args()

if __name__=="__main__":
    args = parse_arguments()
    if args.phase == 'run' and args.id == None:
        print("Not enough arguments. 'run' needs a second argument 'id'")
        sys.exit(1)    
    sys.exit(main())
