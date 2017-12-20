# !/bin/bash
for iteration in {1..3}
do
  sbatch -a 0-9 -o results-${iteration}-%a.out --wrap="./hello.R ${iteration}"
done
