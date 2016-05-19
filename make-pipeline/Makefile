
# Number of sample files to work with
count = 3

# Call out to the shell to generate the sequence ( 1 2 3 ... )
range = $(shell seq 1 $(count))

# Build input and output filenames from the range
input = $(foreach n, $(range), $(subst NN,$(n),sampleNN.data))
output = $(foreach n, $(range), $(subst NN,$(n),sampleNN.out))

# We expect everything to be in the current working directory
script=$(CURDIR)/myscript

all: $(input) $(output)

$(input): %: %
	touch $@

$(output): %.out: %.data
	sbatch -n 1 -t 10:00 $(script) $< $@

