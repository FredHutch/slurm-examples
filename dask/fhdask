#! /bin/bash

#SBATCH --error=%J.dask.err
#SBATCH --output=%J.dask.out
#SBATCH --share
#SBATCH --parsable

# create a Dask cluster inside SLURM

pythonmodule="Python/3.6.4-foss-2016b-fh1"
baseport=$(shuf -i 8786-60000 -n 1)
scriptn=${0##*/}
touser=$(/app/bin/fhrealuser)
debugto="petersen"
domain=$(hostname -d)

if [[ "$scriptn" == "slurm_script" ]]; then
  scriptn="fhdask-test"
fi

if [[ -z $SLURM_CPUS_PER_TASK ]]; then
  SLURM_CPUS_PER_TASK="1"
fi

freeport(){
  local myport=$(( $1 + 1 ))
  while netstat -atwn | grep "^.*:${myport}.*:\*\s*LISTEN\s*$" > /dev/null; do
    myport=$(( ${myport} + 1 ))
  done
  echo "${myport}"
}
echoerr(){
  # echo to stderr instead of stdout
  echo -e "$@" 1>&2
}

# load the latest python if dask cannot be found
if ! hash dask-scheduler 2>/dev/null; then
  source /app/bin/fhmodulecheck
  echoerr "No dask environment found, wrong python "
  echoerr "Please execute first: ml $pythonmodule"
  exit 1
fi

# get the next free ports 
port=$(freeport $baseport)
bokehport=$(freeport $port)

echo "*** Dask ***"
echo "SCHEDULER ${SLURMD_NODENAME}:${port}"
echo "BOKEH ${SLURMD_NODENAME}:${bokehport}"


# starting a dask scheduler / controller
dask-scheduler --port ${port} --bokeh-port ${bokehport} --host $SLURMD_NODENAME --pid-file dask-scheduler.pid &

mytasks=$SLURM_NTASKS
numnodes=$(($mytasks/$SLURM_CPUS_PER_TASK))

#if [[ $mytasks -gt 4 ]]; then
#  # reduce workers by one as a workaround for this error:
#  # srun: error: Unable to create job step: More processors requested than permitted
#  mytasks=$(($mytasks-1))
#fi

#--nodes ${numnodes}

# launch the script passed as argument to fhdask
if [[ -n $1 ]]; then
  # starting as many dask workers as tasks allocated (background)
  echoerr "starting ${mytasks} dask workers with ${SLURM_CPUS_PER_TASK} cores each in the background"
  srun --ntasks ${mytasks} --cpus-per-task ${SLURM_CPUS_PER_TASK} dask-worker --nthreads ${SLURM_CPUS_PER_TASK} --memory-limit auto ${SLURMD_NODENAME}:${port} &
  if [[ -f $1 ]]; then
    echoerr "launching script file $1 ${SLURMD_NODENAME}:${port} as fhdask argument"
    $1 ${SLURMD_NODENAME}:${port} $2 $3 $4
  else
    echoerr "Error: script file $1 in fhdask argument not found."
  fi
  # terminate dask cluster after script has run
  sleep 15
  rm dask-scheduler.pid
  mpack -s "${scriptn}: run by ${touser}" ${SLURM_JOB_ID}.dask.err "${debugto}@${domain}"
else
  # starting as many dask workers as tasks allocated (foreground)
  echoerr "starting ${mytasks} dask workers on ${numnodes} nodes with ${SLURM_CPUS_PER_TASK} cores each in the foreground"
  echoerr "use scancel ${SLURM_JOB_ID} to end this Dask job"
  # --nodes ${numnodes}
  srun --ntasks ${mytasks} --cpus-per-task ${SLURM_CPUS_PER_TASK} dask-worker --nthreads ${SLURM_CPUS_PER_TASK} ${SLURMD_NODENAME}:${port}
fi

exit 0

