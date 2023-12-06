# Running Tensorflow

These examples run the "beginner" script from the tensorflow tutorial on our compute systems.  The script `beginner.py` runs the basic example [from the tutorial](https://www.tensorflow.org/tutorials/quickstart/beginner).

Two methods are used- one using modules (`beginner.sh`) the other using Apptainer (`beginner-apptainer.sh`).  Either script can be run in a grabnode job (make sure to request a GPU) or via `sbatch` (the script contains options to request the GPU)
