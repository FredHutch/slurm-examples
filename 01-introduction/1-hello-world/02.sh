#!/bin/bash

# Job Options- must be before *any* executable lines

#SBATCH --job-name="HelloWorld"
#SBATCH --output=HelloWorld.%j.out

echo "Hello, World"
