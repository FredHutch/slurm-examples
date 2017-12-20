# !/bin/bash

for iteration in {1..3}
do
  echo "0-9 $(pwd)/runscript ${iteration} %o" > mp${iteration}.conf
  sbatch -n 10 --wrap="srun --multi-prog mp${iteration}.conf"
done
