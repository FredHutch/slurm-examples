# Using Make to Manage Jobs

The Unix "make" utility is a powerful tool that can be used to marshall your
parallel computations on the cluster.  This document describes one method that
you can use to parallelize your work.

This technique works when you have a computation that iterates through multiple
loops with much of the calculations done inside the loop.  For example:

```python
result = []

for i in 1:100:
  read( sourcefile )
  tmp=hard_computation( sourcefile )
  result.append( tmp )

save( result, outputfile )
```

If done in sequence, this computation will take 100 times the length of
`hard_computation`.  There are clearly benefits to parallelizing this
operation.  MPI is one way, though this document describes another approach.

In this sort of computation, each result is independent.  We can save the
individual results from each iteration into a temporary file and assemble those
when all 100 computations are complete.

So we simplify our looped code into a single run of `hard_computation` that
takes an inputfile and an outputfile as an argument:

```python
sourcefile = argv[1]
outputfile = argv[2]

read( sourcefile )
tmp=hard_computation( sourcefile )

save( tmp, outputfile )
```

Now we submit 100 jobs with this as the command to run.  With `bash` we can
do something like this:

```bash
    for i in {1..100}
    do
        sbatch --wrap "myscript.sh sample${i}.data sample${i}.out"
    done
```

This will submit 100 jobs, each saving to a different file in the current
directory.  However, it is unable to verify that all 100 jobs complete.  If
some jobs should fail, its up to you to determine which and how many failed and
resubmit those jobs.  With 100 jobs, this isn't too much of a problem, though
as the number of iterations increase, the issue becomes problematic.

This is where make helps.  We can give make a rule that ensures that all 100
files are present before proceeding to the next step.  `make` takes a file
as input: this file declares targets, dependencies, and steps for creating
files:

```make
sample1.out: sample1.data
  sbatch --wrap "myscript sample1.data sample1.out"
sample2.out: sample2.data
  sbatch --wrap "myscript sample2.data sample2.out"
sample3.out: sample3.data
  sbatch --wrap "myscript sample3.data sample3.out"

# ...

sample100.out: sample100.data
  sbatch --wrap "myscript sample100.data sample100.out"
```

In this example `sampleN.out` is the target.  `sampleN.data` is the
dependency, and the `sbatch` command is the step for creating the target.  So
the logic goes "if the file `sample1.out` does not exist and `sample1.data`
does exist, use this command to create `sample1.out`".  If `sample1.out`
exists, then nothing needs to be done (i.e. the target is "made" and requires
no action).  Note that if `sample1.data` does not exist, then this will raise
an error.

This is pretty hard to maintain- any change to your arguments requires changing
100 different lines in the make file.  `make` has a number of features that
allow us to shorten this up based on the patterns in the inputs and outputs. As
this isn't a tutorial on `make`, I'll simply refer you to the [Fine Manual](http://www.gnu.org/software/make/manual/html_node/index.html#SEC_Contents) for
further reading, but here is what we'd do to simplify this code:

```make
count = 3
range = $(shell seq 1 $(count))
output = $(foreach n, $(range), $(subst NN,$(n),sampleNN.out))

script=$(CURDIR)/myscript

all: $(output)

$(output): %.out: %.data
	sbatch -n 1 -t 10:00 $(script) $< $@

```

The first three lines create a list for `make` that contains all 100 temporary
file names.  These items become the targets by way of `make's` ["Static Pattern Rules"](http://www.gnu.org/software/make/manual/html_node/Static-Usage.html#Static-Usage).

The end result is that everytime you run make, if it does not find the output
file of any index number, it will re-submit the job for that index.  So if
number 34 is missing, then it will submit a job to replace it with `sbatch
myscript sample34.data sample34.out`

For this reason, we should insert code to ensure that we don't submit multiple
jobs for the same index. This can be done either in your script or in the
makefile.

Now that we have 100 temporary files, it is necessary to assemble them into the
desired format.  This is typically a lightweight task that can be run on any of
the login servers.  Depending on the format, the task can be as simple as
concatenating the files:

    cat sample{1..100}.out > result

