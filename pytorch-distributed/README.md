# Running Distributed PyTorch

> **WORK IN PROGRESS**

Training ML models with PyTorch is a resource heavy operation.  Our GPU architecture is not great for this application, with one lightweight GPU per node we frequently do not have enough GPU memory for many training operations.

Distributing your operation across multiple nodes _may_ help alleviate this problem.  These examples show one way of accessing GPUs across multiple nodes within our Slurm environment

> NOTE: this example doesn't do any training, but only exists as a POC for distributed GPU operations.  I hope to improve this example in the future

## Use

The submit script contains the necessary options, so `sbatch ./hello.sh` will run the example

## Discussion
