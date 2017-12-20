# !/bin/bash

for i in {1..3}
do
  srun -n 10 --multi-prog mp${i}.conf &
done
