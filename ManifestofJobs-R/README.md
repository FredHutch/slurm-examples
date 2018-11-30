This example assumes you have a csv full of arguments to a task you want to perform independently, and repeatedly, on each set of arguments.


The name of the csv containing your sets of arguments is "taskArgumentManifest.csv".  In each separate job you want to kick off you want Rtask.R to run with input variables from one row of the manifest.

This would run Rtask.R on the first row of the manifest. 
```
Rscript Rtask.R taskArgumentManifest.csv 1
```
