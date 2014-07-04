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

In this example, we give the name "dummy" to the scenario

```r
copy_pelps_folder(scenario_name = "dummy")
```


To save space, data can be compressed

```r
copy_pelps_folder(scenario_name = "dummy", compression="bzip2")
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
* Input: Raw PELPS text files (.DAT) stored in a folder or .zip archive
* Output: Raw data.frames stored in a .RDATA file 

Save the base scenario without compression to a RDATA file

```r
savePELPSToRdata("base")
```

```
## Warning: cannot open file 'rawdata/base/DEMAND.DAT': No such file or
## directory
```

```
## Error: cannot open the connection
```


Save the base scenario from a bzip2 archive to a RDATA file

```r
savePELPSToRdata("base", compressed="bzip2")
```

```
## Warning: cannot open bzip2-ed file 'rawdata/base.tar.bz2', probable reason
## 'No such file or directory'
```

```
## Error: cannot open the connection
```



Save the base scenario from a zip archive to a RDATA file

```r
savePELPSToRdata("PELPS 105Base", "zip")
```


List Zip archives available

```r
list.files("rawdata", ".zip", full.names = TRUE) 
```

```
## [1] "rawdata/PELPS 105 TFTA High Scenario revision 1.zip"
## [2] "rawdata/PELPS 105 TFTA Low scenario revision 1.zip" 
## [3] "rawdata/PELPS 105Base.zip"                          
## [4] "rawdata/World105LowGDPelast.zip"                    
## [5] "rawdata/World105NoTTIPHighGDPelast.zip"
```



List Raw RDATA files available

```r
list.files("rawdata", ".RDATA", full.names = TRUE) 
```

```
## [1] "rawdata/base.RDATA"                                   
## [2] "rawdata/GFPMcodes.RDATA"                              
## [3] "rawdata/PELPS 105 TFTA High Scenario revision 1.RDATA"
## [4] "rawdata/PELPS 105 TFTA Low scenario revision 1.RDATA" 
## [5] "rawdata/PELPS 105Base.RDATA"                          
## [6] "rawdata/World105LowGDPelast.RDATA"                    
## [7] "rawdata/World105NoTTIPHighGDPelast.RDATA"
```


Clean a scenario
----------------
The archive is transformed by adding column titles, 
and translating product and country codes into product and country names. 
available for analysis with R.
* Input: Raw data.frames stored in a .RDATA file
* Output: cleaned data.frames stored in a .RDATA file


```r
source("code/clean.R")
baseScenario = clean("PELPS 105Base.RDATA", "Base")
```

The `baseScenario` object is a list of dataframe. 
The command `str(baseScenario)` gives details about the structure and content of this data object. 
Now you can explore the dataset in various ways. See the ./docs folder.


Working examples of clean functions
-----------------------------------
### Load raw PELPS tables from a .RDATA file

```r
print(load("rawdata/PELPS 105Base.RDATA"))
```

```
## [1] "PELPS"
```

```r
llply(PELPS,head)
```

```
## $scenario_name
## [1] "PELPS 105Base"
## 
## $demand
##      V1   V2     V3     V4     V5     V6
## 1 Da080 8165 8024.0 7802.9 7376.6 6050.8
## 2 Da082   52   49.3   45.4   38.5   22.9
## 3 Da083 1622 1662.1 1703.3 1720.8 1730.2
## 4 Da084  109  110.9  112.7  111.6  109.7
## 5 Da085   79   83.3   87.6   89.2   89.8
## 6 Da086   58   59.1   60.1   60.0   59.5
## 
## $production
##      V1   V2   V3   V4   V5   V6
## 1 Ya083 13.0  8.1  2.4  0.3  0.1
## 2 Ya084 25.0 23.1 21.0 17.7 12.9
## 3 Ya085 23.0 17.2 11.2  4.9  1.0
## 4 Ya086 38.0 33.0 28.6 22.6 14.5
## 5 Ya088  3.7  3.2  2.5  1.6  0.7
## 6 Ya091  2.0  3.1  6.6 15.2 26.1
## 
## $trade
##        V1 V2   V3   V4   V5   V6
## 1 Ta0zz84  1  0.8  0.6  0.5  0.4
## 2 Ta0zz86  3  2.3  1.8  1.4  1.1
## 3 Ta0zz90 23 26.9 30.5 31.7 32.5
## 4 Ta0zz91 14 10.8  8.4  6.5  5.1
## 5 Ta0zz92  2  1.5  1.2  0.9  0.7
## 6 Ta0zz93  6  4.6  3.6  2.8  2.2
## 
## $demandprice
##      V1    V2    V3    V4    V5    V6
## 1 Da080  61.0  77.1 105.3 168.9 479.5
## 2 Da082  99.0 121.6 158.7 232.1 493.1
## 3 Da083 319.1 318.5 317.5 315.7 313.6
## 4 Da084 662.6 696.1 732.4 767.5 802.2
## 5 Da085 338.5 358.9 382.0 404.4 426.4
## 6 Da086 505.9 546.9 593.0 638.1 683.1
## 
## $supply
##      V1     V2     V3     V4     V5     V6
## 1 Sa080 8165.0 8024.0 7802.9 7376.6 6050.8
## 2 Sa081   95.7   74.0   51.5   29.5    8.0
## 3 Sa082   52.0   49.3   45.4   38.5   22.9
## 4 Sa089    2.0    2.1    2.3    2.4    2.5
## 5 Sa090   32.0   36.5   41.5   45.7   50.2
## 6 Sa180 4009.0 4062.5 4116.6 4162.2 4197.3
## 
## $worldPrice
##      V1    V2    V3     V4     V5     V6
## 1 Czz84 554.0 587.5  618.8  649.2  679.3
## 2 Czz86 423.0 463.8  503.7  543.0  581.9
## 3 Czz90 171.0 177.4  184.1  190.4  199.0
## 4 Czz91 622.0 631.9  639.8  644.9  648.3
## 5 Czz92 967.9 974.2  973.7  970.6  967.3
## 6 Czz93 951.0 990.3 1025.9 1057.4 1090.3
## 
## $numberOfPeriods
## [1] 5
```


### Example using the function splittrade 

```r
PELPS2 = splittrade(PELPS)
lapply(PELPS[c("trade")],nrow) #number of rows in PELPS
```

```
## $trade
## [1] 3361
```

```r
lapply(PELPS2[c("trade", "import", "export")],nrow) #number of rows in PELPS2
```

```
## $trade
## [1] 3361
## 
## $import
## [1] 2351
## 
## $export
## [1] 1010
```


### Example using the function reshapeLong

```r
head(PELPS$demand)
```

```
##      V1   V2     V3     V4     V5     V6
## 1 Da080 8165 8024.0 7802.9 7376.6 6050.8
## 2 Da082   52   49.3   45.4   38.5   22.9
## 3 Da083 1622 1662.1 1703.3 1720.8 1730.2
## 4 Da084  109  110.9  112.7  111.6  109.7
## 5 Da085   79   83.3   87.6   89.2   89.8
## 6 Da086   58   59.1   60.1   60.0   59.5
```

```r
demand = reshapeLong(PELPS$demand, "Demand")
head(demand)
```

```
##         Period Volume Element Code
## Da080.1      1   8165  Demand a080
## Da082.1      1     52  Demand a082
## Da083.1      1   1622  Demand a083
## Da084.1      1    109  Demand a084
## Da085.1      1     79  Demand a085
## Da086.1      1     58  Demand a086
```


### Example using the function add product and country

```r
demand = addProductAndCountry(demand)
head(demand)
```

```
##   Product_Code  Product Country_Code              Country      GFPM_REG
## 1           80 Fuelwood           m1 United Arab Emirates          Asia
## 2           80 Fuelwood           a0              Algeria        Africa
## 3           80 Fuelwood           p3          Netherlands        Europe
## 4           80 Fuelwood           i1                 Peru South America
## 5           80 Fuelwood           n7              Belgium        Europe
## 6           80 Fuelwood           j7                 Iraq          Asia
##   Period Volume Element
## 1      3   16.5  Demand
## 2      4 7376.6  Demand
## 3      4  296.1  Demand
## 4      2 7514.0  Demand
## 5      3  876.1  Demand
## 6      2  120.9  Demand
```


### Example using reshapeLong and addProductAndCountry on World price

```r
wp = reshapeLong(PELPS$worldPrice, "World_Price")
head(wp)
```

```
##         Period Volume     Element Code
## Czz84.1      1  554.0 World_Price zz84
## Czz86.1      1  423.0 World_Price zz86
## Czz90.1      1  171.0 World_Price zz90
## Czz91.1      1  622.0 World_Price zz91
## Czz92.1      1  967.9 World_Price zz92
## Czz93.1      1  951.0 World_Price zz93
```

```r
wp = addProductAndCountry(wp)
wp$World_Price = wp$Volume
wp = wp[,c("Product_Code", "Product", "Period", "World_Price")]
head(wp)
```

```
##   Product_Code  Product Period World_Price
## 1           80 Fuelwood      4        57.6
## 2           80 Fuelwood      1        61.0
## 3           80 Fuelwood      2        59.9
## 4           80 Fuelwood      3        58.8
## 5           80 Fuelwood      5        56.3
## 6           81 IndRound      3        97.2
```

