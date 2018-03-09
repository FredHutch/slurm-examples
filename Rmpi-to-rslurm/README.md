# Refactor: from `Rmpi` to `rslurm`

Jeff Katcher, Dan Tenenbaum

**Background**: Many researchers at Fred Hutch use `Rmpi` for
paralellizing computations. The use of `Rmpi` has many issues:

* It is overkill for the type of tasks that researchers here use it for.
* It is very difficult to configure and maintain.
* It is not robust to failure; a single failed worker can cause a whole job
  to fail.
* There are better alternatives.
* Rmpi will eventually be deprecated and no longer supported at the Center.

Therefore it is useful to examine how to convert an existing script
from `Rmpi` to `rslurm`.

**Note**: This is NOT a general guide for how to convert a script
that uses `Rmpi` into one that uses `rslurm`. For that, see
(TBA). This is a document about converting a specific script.

## Case Study

We converted the existing script `Analysis_CostEffect_2018_org.R`
from `Rmpi` to `rslurm`. The converted script is called
`Analysis_CostEffect_2018_org_rslurm.R`.

Both scripts are in `/fh/fast/_ADM/SciComp/public/lih-rslurm/`.


## Changes made

### `setwd` anti-pattern

The code had a number of instances of `setwd()` in it.
`setwd()` is a function that changes the current working directory.
This can be confusing for users of that code, who do not expect it.
Also, if there is an error at any point, and one or more of the
`setwd()`'s end up not being run, the user may end up in a directory
they did not expect to be in.

It is better to remove the calls to `setwd()` and instead provide
absolute paths to any function that requires a file path.
We used the platform-independent function `file.path()` to
construct these paths.

Therefore, we set a constant `INPUTDIR` which points to
the directory where input files are to be read from
(output files are written to the current directory).

We placed `INPUTDIR` inside `cost.effective()`, which is the
function that is run by `Rmpi` in the old version and `rslurm`
in the new, because 1) all the `setwd()`'s were in that function
and 2) variables declared outside that function will not be found,
since the function is run by itself on a cluster node.

Note that this change has nothing specifically to do with
the change from `Rmpi` to `rslurm`, it was just done to reduce
surprises and make the code easier to understand.


### Parallelize outer loop using `parallel:mclapply()`

The original code called `cost.effective()` inside a loop which runs 10 times:

```R
for (i in 1: length(var.est.vec)){
  ...
}
```

In the `rslurm` version of the code, we submit the function to `rslurm`,
then call `get_slurm_out()` which blocks until the cluster is finished with
the job. This effectively turns the parallel computation into a serial one.

We can speed up the whole computation by parallelizing this outer loop.
For this we use the function `mclapply()` from the built-in `parallel`
package. Since the outer loop (with the exception of the `cost.effective()`
function which runs on the cluster anyway) is not computationally intensive, we can use multiple cores
on one of the `rhino` machines and still be a good citizen.

`mclapply()` needs a list to apply over, so we create a variable
holding what previously was the loop index `i`:

```R
loopIdx <- 1:10
```

Then we changed the previous outer loop into a function (called `outerLoop()`) taking an `i`
parameter, and call it as follows:

```R
mclapply(loopIdx, outerLoop, mc.cores=detectCores())
```
This speeds up the script from running in ~8 hours to running in less
than one hour.

### Marshal arguments into a data frame

`slurm_apply()` expects to receive a data frame where each column is
named after one of the arguments taken by the function which is to run
on the cluster.

For a trivial example, consider a function that adds two numbers;

```R
 add <- function(a, b) a+b
 ```

We construct the following data frame:

```R
df <- data.frame(a=c(1,2,3), b=c(4,5,6))
```

The first iteration of `slurm_apply()` will add 1 and 4, the second
2 and 5, the third 3 and 6, giving the result:

```R
sjob = slurm_apply(add, df, jobname='testjob')
print_job_status(sjob)
result <- get_slurm_out(sjob, "table")
result
```
output:

```
  V1
1  5
2  7
3  9
```

So in the `rslurm` version of the script, we construct this data
frame as follows:

```R
params <- data.frame(b = 1:B, n = n, var.est = var.est, iter=i)
```



### Run function on slurm cluster

As we see above, `slurm_apply()` will run the function on the cluster,
with the arguments stored in the data frame passed as its second argument.
`get_slurm_out()` will block until the job is complete, and then put
the job results into another data frame.

### Transpose results and massage row names

In comparing the results of the `rslurm` version with the results
of the `Rmpi` version, we see that the result of the `slurm_apply()`
(retrieved with `get_slurm_out()`) is transposed from that of the `Rmpi`
version. So we simply transpose the matrix with the `t()` function.

```R
output1 <- as.data.frame(t(output1))
```


We also noticed that the row names are not quite the same as they were in the
`Rmpi` version. We can make them the same by simply setting them to a numeric
vector:

```R
rownames(output1) <- 1:nrow(output1)
```

The output of the `rslurm` version is now identical to that of
the `Rmpi` version, as verified by `all.equal()`.

### Write plots to separate PDF files for each run

Every time `cost.effective()` runs, it produces plots.
In the `Rmpi` version, all plots are collected in `Rplots.pdf`
which ends up being 520 pages long.

When run with `rslurm`, different instances of `cost.effective()` on
the cluster will overwrite each other's `Rplots.pdf` files, so it ends
up being 0 bytes long.

The solution is to configure `cost.effective()` to write to a unique PDF
file, by putting this code at the beginning of the function:

```R
pdfName <- paste("../Rplots", Sys.getenv("SLURM_ARRAY_JOB_ID"),
                  Sys.getenv("SLURM_ARRAY_TASK_ID"), iter, ".pdf", sep="_")
pdf(file=pdfName)
```

...and this code near the end of the function:

```R
dev.off()
```

This will cause each run to generate a uniquely named PDF file containing
the plots for that run. If you want to merge these PDFs into one,
run the script
`/fh/fast/_ADM/SciComp/public/lih-rslurm/concat_pdfs.py`, run in the directory that contains
all the PDFs. The result of this concatenation will be called `output.pdf`.

### Overview: running the script

Putting it all together and running the script.

#### Choosing the cluster

If you want to run on the `beagle` cluster, which runs in AWS,
there are two options:

1. Start the job from the host `fitzroy`, which is configured to use
   the `beagle` cluster by default.
2. Start the job from one of the `rhino` machines, but set the environment
   variable `SLURM_CLUSTERS` to `beagle` before doing anything else:

```
export SLURM_CLUSTERS=beagle
```

#### Running the script

Go to the directory containing the script. Create an output directory and
`cd` to it:

```
mkdir output
cd output
```

Load up R and invoke it:

```
ml R/3.4.3-foss-2016b-fh1
R
```

Within R, invoke the script, wrapping the call in `system.time()`
to see how long it took:

```R
system.time(source("../Analysis_CostEffect_2018_org.R", echo=TRUE, max=Inf))
```

When the run is complete, your current directory will contain `.csv`
and `.pdf` output. If you want to concatenate all the PDFs into one,
see the previous step.

### Appendix: diff between the scripts

Here is the diff between the original (`Rmpi`) script (in red) and the
`rslurm` version (in green). Not much has changed.

```diff
1,3c1,2
<
< #library('Rmpi')
< #mpi.spawn.Rslaves(nslaves=mpi.universe.size()-1)
---
> library("rslurm")
> library("parallel")
13a13,18
>   INPUTDIR <- "/fh/fast/_ADM/SciComp/public/lih-rslurm/input/"
>   pdfName <- paste("../Rplots", Sys.getenv("SLURM_ARRAY_JOB_ID"),
>                     Sys.getenv("SLURM_ARRAY_TASK_ID"), iter, ".pdf", sep="_")
>   pdf(file=pdfName)
>
>
26d30
<   setwd("/fh/fast/_ADM/SciComp/public/lih-rslurm/input/")
30,32c34,36
<   wm.prox<-read.csv('wm.prox.inc.csv')
<   wm.dist<-read.csv('wm.dist.inc.csv')
<   wm.rect<-read.csv('wm.rect.inc.csv')
---
>   wm.prox <- read.csv(file.path(INPUTDIR, "wm.prox.inc.csv"))
>   wm.dist <- read.csv(file.path(INPUTDIR, "wm.dist.inc.csv"))
>   wm.rect <- read.csv(file.path(INPUTDIR, "wm.rect.inc.csv"))
34,36c38,40
<   wfem.prox<-read.csv('wfem.prox.inc.csv')
<   wfem.dist<-read.csv('wfem.dist.inc.csv')
<   wfem.rect<-read.csv('wfem.rect.inc.csv')
---
>   wfem.prox <- read.csv(file.path(INPUTDIR, "wfem.prox.inc.csv"))
>   wfem.dist <- read.csv(file.path(INPUTDIR, "wfem.dist.inc.csv"))
>   wfem.rect <- read.csv(file.path(INPUTDIR, "wfem.rect.inc.csv"))
49,50c53,54
<   wm.ocd<-read.csv('wm.ocd.csv')
<   wfem.ocd<-read.csv('wfem.ocd.csv')
---
>   wm.ocd <- read.csv(file.path(INPUTDIR, "wm.ocd.csv"))
>   wfem.ocd <- read.csv(file.path(INPUTDIR, "wfem.ocd.csv"))
56c60,61
<   current.age0 = read.csv("2012gender_table1_census copy.csv", header=TRUE, row.names = 1)
---
>   current.age0 = read.csv(file.path(INPUTDIR, "2012gender_table1_census copy.csv"),
>       header = TRUE, row.names = 1)
83d87
<   setwd("/fh/fast/_ADM/SciComp/public/lih-rslurm/output/")
279a284,285
>   dev.off()
>
287d292
< setwd("/fh/fast/_ADM/SciComp/public/lih-rslurm/output/")
292c297,298
< for (i in 1: length(var.est.vec)){
---
>
> outerloop <- function(i) {
300c306,316
<   output1 = mpi.parSapply(1:B, cost.effective, n=n, var.est = var.est)
---
>
>   params <- data.frame(b = 1:B, n = n, var.est = var.est, iter=i)
>   slurm_job <- slurm_apply(cost.effective, params,
>     jobname = paste0("lih-rslurm-example-", i),
>       nodes = 6, cpus_per_node = 8)
> #    print_job_status(slurm_job)
>   output1 <- get_slurm_out(slurm_job, "table")
>   # transpose the matrix
>   output1 <- as.data.frame(t(output1))
>   rownames(output1) <- 1:nrow(output1)
>
304a321,322
>
>   cleanup_files(slurm_job)
306a325
> loopIdx <- 1:10
307a327
> mclapply(loopIdx, outerLoop, mc.cores=detectCores())
391,392d410
<
<

```
