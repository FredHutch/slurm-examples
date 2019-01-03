#!/bin/bash

ml Singularity

singularity exec --nv \
  docker://tensorflow/tensorflow:latest-gpu \
  python ./models/tutorials/image/mnist/convolutional.py
