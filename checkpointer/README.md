
Checkpointer is a collection of shell scripts and wrappers that enable user space checkpointing on a SLurm HPC cluster that has [CRIU](https://criu.org) installed (see https://github.com/checkpoint-restore/criu). The scripts have been tested with Ubuntu 18.04.4 and CRIU 3.13 PPA packages (see https://launchpad.net/~criu/+archive/ubuntu/ppa)  

Besides fault tolerance, checkpointing can increase job throughput. Jobs that are scheduled for shorter run times are getting started sooner on average than jobs for which the user requests long run times. The mechanism that implements this prioritization is called [Backfill](https://www.zedat.fu-berlin.de/HPC/EN/Backfill)


Checkpointer is focusing on increasing throughput but also inproves fault tolerance 

## Installing checkpointer

The shell scripts assume that /app is mounted consistently on all cluster nodes and you have added /app/bin to your PATH and that the shell scripts reside in /app/lib/checkpointer. A symlink /app/bin/checkpointer is pointing to /app/lib/checkpointer/checkpointer. If you have a different folder structure you can change the CHECKPOINTER_LIBDIR environment variable in /app/lib/checkpointer/checkpointer. After install you need to compile a C wrapper that provides addional security for software that runs suid. See this issue for a discussion of checkpointer-suid:  https://github.com/checkpoint-restore/criu/issues/1027 

```
cd /app/lib/checkpointer
sudo make checkpointer-suid
sudo chmod 4755 checkpointer-suid
```

## Using checkpointer

You can activate checkpointing for your job by using the `checkpointer` command in the shell script that starts your job. After checkpointer is launched, it waits in the background until there are only 10 min scheduled time left for your compute job. Then it will kill your compute process and flush it to disk and at the same time it will submit another job with the same parameters as the first one (e.g. number of cpus, partition, wall clock time). When that next job starts it will load all information from disk and continue the computation on a different compute node.

Add the `checkpointer` command to your script and ensure it is executed *before* the actual compute script or bianry is launched.

```
cat runscript.sh

checkpointer 
Rscript /my/folder/..../script.R
```

After this you launch the script with sbatch. If you request 30 min (e.g. `sbatch -t 0-0:30`) your job will be flushed to disk after 20 min and checkpointer will submit another Slurm job with a 30 min time limit and restore your process inside that job.


```
sbatch -t 0-0:30 runscript.sh
```

