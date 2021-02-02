help:
	@echo "Run tensorflow in a singularity container"
	@echo
	@echo "With thanks to the tensorflow and singularity communities"
	@echo "See \"CREDITS.md\""
	@echo
	@echo "Run \`make setup\` to clone the examples in then"
	@echo "run \`make run\` to submit the job"
	@echo
	@echo "Check out the sample code in scripts/mnist-convolutional.sh"

all: help

setup: models/tutorials/image/mnist/convolutional.py
models/tutorials/image/mnist/convolutional.py:
	git clone https://github.com/tensorflow/models.git

run: out.txt
out.txt: models/tutorials/image/mnist/convolutional.py
	sbatch -o out.txt \
		--gres=gpu:1 ./scripts/mnist-convolutional.sh

clean:
	-rm -f out.txt

distclean: clean
	-rm -rf data
	-rm -fr models

.PHONY: clean distclean
