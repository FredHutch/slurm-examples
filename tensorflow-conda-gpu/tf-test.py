#!/usr/bin/env python3
import tensorflow
from tensorflow.python.client import device_lib
print(tensorflow.__version__)
print(tensorflow.__path__)
print(device_lib.list_local_devices())
