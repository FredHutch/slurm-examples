The `rslurm` library allows you to parallelise work on a Slurm cluster. From
the documentation, `rslurm` provides:

> Functions that simplify submitting R scripts to a Slurm
> workload manager, in part by automating the division of embarrassingly
> parallel calculations across cluster nodes

# `rslurm-example.R`
This example (from the `rslurm` documentation with some minor changes) is an
example of one way of running a parallel algorithm.  Note that this does not
need to be run within a Slurm job: it can be run on a login host.

# `pi.R`

This example uses the "throwing darts" approach to estimating π.


