Tutorial explaining how to load and clean GFPM data
===================================




Call the load.R, clean.R and func.R scripts

```r
source("code/load.R")
source("code/clean.R")
source("code/func.R")
```

```
## Warning: package 'ggplot2' was built under R version 3.0.3
```



### Import GFPM data the fast way
This command loads and cleans GFPM data, saves it in ./enddata:

```r
load_and_clean_gfpm_data(scenario_name = "base5") # Give it a scenario name of your choice
load_and_clean_gfpm_data(scenario_name = "base5", compression="bzip2") # Give it a scenario name of your choice
```

If you are not interested in the internal workings of load.R and clean.R, 
and if you only want to analyse results from one scenario,
you can skip the rest of this document and jump to tutorial/explore.

However if you want to analyse several scenarios combined, keep on reading.
Below we demonstrate the use of the functions `savePELPSToRdata()` and `clean()`
to read PELPS data tables.


### Copy GFPM data in c:\PELPS\pelps with a function
GFPM simulation results are stored in plain text
format ".DAT" in the `C:\PELPS\pelps` folder. 
After each scenario has run, we will copy this folder in an archive.

In this example, we give the name "base" scenario to the dataset.

```r
copy_pelps_folder(scenario_name = "base")
```


To save space, data can be compressed

```r
copy_pelps_folder(scenario_name = "base", compression="bzip2")
```

```
## Warning: The scenario archive rawdata/base.tar.bz2 already exists, we can
## not overwrite.
```

```
## [1] FALSE
```


Unfortunately zip compression is not available in writting, it can only be read by R.
To use zip compression, follow the method "by hand"" below.

### Copy GFPM data in c:\PELPS\pelps by hand
 1. Rename the folder "C:\PELPS\PELPS" to a name of your choice.
 For example "my_scenario_name". 
 2. Copy the renamed PELPS folder to the \rawdata folder.
   Optionally, you can compress this PELPS folder as a zip file: "my_scenario_name.zip"
   and copy it to the rawdata folder.


Load a scenario in R and save it to .RDATA
-----------------------------------------
* load.r
 * Input: Raw PELPS text files (.DAT) stored in a folder or .zip archive
 * Output: Raw data.frames stored in a .RDATA file 

Save the base scenario without compression to a RDATA file

```r
savePELPSToRdata("base")
```


Save the base scenario from a bzip2 archive to a RDATA file




















