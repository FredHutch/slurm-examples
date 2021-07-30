#!/bin/bash

ml Singularity
singularity pull --arch amd64 library://sylabsed/examples/lolcow:latest
singularity run lolcow_latest.sif
