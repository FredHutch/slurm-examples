#!/usr/bin/env Rscript
# pi.R
library('rslurm')

sim.pi <- function(iterations = 1000) {
    # Generate two vectors for random points in unit circle
    x.pos <- runif(iterations, min=-1, max=1)
    y.pos <- runif(iterations, min=-1, max=1)
    # Test if draws are inside the unit circle
    draw.pos <- ifelse(x.pos^2 + y.pos^2 <= 1, TRUE, FALSE)
    draws.in <- length(which(draw.pos == TRUE))
    result <- data.frame(iterations,draws.in)
    return(result)
}


params <- data.frame(iterations = rep(1000,100))

sjob1 <- slurm_apply(
  sim.pi, 
  params,
  jobname="rslurm-pi-example",
  nodes=10,
  cpus_per_node=1
)

print_job_status(sjob1)

res <- get_slurm_out(sjob1, "table")
my_pi <- 4/(sum(res$iterations)/sum(res$draws.in))
cat("\n... done\n")
cat(
  paste0(
    "pi estimated to ", my_pi, " over ", sum(res$iterations), " iterations\n"
  )
)

cat("... cleaning up... \n")
cleanup_files(sjob1)
cat("... done\n")
