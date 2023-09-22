#!/usr/bin/env python
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--sq", type=int)

args=parser.parse_args()

print(args.sq**2)
