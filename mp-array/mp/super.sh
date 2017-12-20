# !/bin/bash

for iteration in {1..3}
do
  echo "0-9 $(pwd)/runscript ${iteration} %o" > mp${iteration}.conf
  srun -n 10 --multi-prog mp${iteration}.conf &
done
