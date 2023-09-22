#!/bin/bash

# Job Options- must be before *any* executable lines

#SBATCH --job-name="modules"
#SBATCH --output=modules.%J.out

module load fhR
which R
