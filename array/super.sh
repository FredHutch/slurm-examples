# !/bin/bash

for i in {1..10}
do
  srun -n 10 --multi-prog mp.conf &
done
