# Base R Example

## Converting Docker Container Images

Build the base R image with

```ShellSession
$ singularity build r-base-latest.sif docker://r-base
```

## Building Custom Containers

The two `.def` files can be used to rebuild that container image:

 - `r-base-with-libraries.def` adds additional libraries to the R in the image
 - `r-base-with-mount.def` adds a directory for binding local data

Build these with:

```ShellSession
singularity build --remote r-base-latest.sif r-base-with-libraries.def
```

## Running scripts

```ShellSession
$ singularity exec my_r_container.sif Rscript ./list_installed.R
```

will list the R libraries installed in the container
