#!/bin/bash
matlab -r \
"try, run('./script.m'), catch, exit(1), end, exit(0);" -nodisplay -nosplash -nodesktop
