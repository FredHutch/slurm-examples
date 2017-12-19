#!/bin/bash
batch=$(($1+1 + ($2-1)*10))
bs=10
for Beta in .5
do
  for n in 500
  do
    for e in 0
    do
      R -q --vanilla --args $bs $batch $n $model $e $Beta \
        < chngpt_linear_sim_alg2.R \
        >logs/chngpt_linear_sim_alg2.out 2>logs/chngpt_linear_sim_alg2.err
    done
  done
done
