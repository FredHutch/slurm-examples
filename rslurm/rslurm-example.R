#!/usr/bin/env Rscript
library('rslurm')

# Create a data frame of mean/sd values for normal distributions
pars <- data.frame(
  par_m = seq(-10, 10, length.out = 1000),
  par_sd = seq(0.1, 10, length.out = 1000)
)

# Create a function to parallelize
ftest <- function(par_m, par_sd) {
  samp <- rnorm(10^7, par_m, par_sd)
  c(s_m = mean(samp), s_sd = sd(samp))
}

sjob1 <- slurm_apply(
  ftest, 
  pars,
  jobname="rslurm-example",
  nodes=10,
  cpus_per_node=1
)

print_job_status(sjob1)
res <- get_slurm_out(sjob1, "table")
all.equal(pars, res) # Confirm correct output
cleanup_files(sjob1)
