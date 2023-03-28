#!/bin/bash
#SBATCH --job-name=multinode-example
#SBATCH --nodes=4
#SBATCH --ntasks=4
#SBATCH --gpus-per-task=1
#SBATCH --cpus-per-task=4

# shamelessly copied from https://github.com/pytorch/examples/blob/main/distributed/ddp-tutorial-series/slurm/sbatch_run.sh

set -e
module load PyTorch
set -x

nodes=( $( scontrol show hostnames $SLURM_JOB_NODELIST ) )
nodes_array=($nodes)
head_node=${nodes_array[0]}
head_node_ip=$(srun --nodes=1 --ntasks=1 -w "$head_node" hostname --ip-address)

echo Node IP: $head_node_ip
export LOGLEVEL=INFO

srun torchrun --nnodes 4 \
  --nproc_per_node 1 \
  --rdzv_id ${RANDOM} \
  --rdzv_backend c10d \
  --rdzv_endpoint ${head_node_ip}:29500 \
  ./hello.py
