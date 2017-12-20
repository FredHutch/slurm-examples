# !/bin/bash

for i in {1..3}
do
  echo "0-9 $(pwd)/runscript %o ${i}" > mp${i}.conf
  srun -n 10 --multi-prog mp${i}.conf &
done
