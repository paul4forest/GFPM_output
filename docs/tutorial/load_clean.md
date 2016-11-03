# Loading GFPM data into R and preparing for analysis


This tutorial explains how to load GFPM data into R.
And how to prepare the data for further analysis. 
GFPM simulation results are stored in plain text
format in ".DAT" files under the `C:\PELPS\pelps` folder. 
After each simulation we copy these files for further analysis 
with the R statistical programming software.



Load the package

```r
library(GFPMoutput)
```

# 3 ways to load GFPM data into R 
There are 3 ways to load GFPM data into R. 
If GFPM is running on a virtual machine or on a different computer than R, then you should go with the first method, copying the PELPS folder "by hand" in a zip archive. 
If GFPM is running on the same machine, 2 alternatives are possible below, but if you don't know what to choose from, you should be fine with the zip archive method.

## Copy GFPM data from c:\\PELPS\\pelps by means of a zip archive
Make sure you rename the "PELPS" folder into your scenario name before you compress it to zip.

 1. Rename the folder "C:\\PELPS\\PELPS" to a name of your choice.
 For example "your_scenario_name". 
 2. Compress this PELPS folder as a zip file: "your_scenario_name.zip" 
 3. Copy the zip archive to a \\rawdata folder accessible by R.
 
Now you can convert the content of this zip archive 
to an RDATA object:

```r
savePELPSToRdata("your_scenario_name", "zip")
```

Then prepare the data for further analysis with 

```r
your_scenario_name = clean(fileName = "your_scenario_name.RDATA",
                           scenario_name = "your_scenario_name")
```

If you have 2 scenarios you can clean them and combine them
in a list object with 

```r
scenario1 <- clean("scenario1.RDATA", "scenario1")
scenario2 <- clean("scenario2.RDATA", "scenario2")
all_your_scenarios <- bindScenarios(scenario1, scenario2)
```


Then you can explore the dataset following examples available in the [explore](explore.md) document.


## Import GFPM data directly after a simulation
This command loads GFPM data in the form of a list of
data frames. It saves the list in R data format
under the folder  ./enddata.
Give a scenario name of your choice.

```r
load_and_clean_gfpm_data(scenario_name = "your_scenario_name", 
                         pelps_folder = "C:/PELPS/pelps/") 

# The cleaned data can be loaded with 
load("enddata/your_scenario_name.RDATA")
# It has the form of a large list containing several data frames
# You can see the begining of each data frame with the command
lapply(scenario,head)
```
Now you can skip the rest of this document and jump to tutorial/[explore](explore.md).


## Copy GFPM data from c:\\PELPS\\pelps with a function
If the GFPM simulation and R analysis are on the same computer,
This function can be used to copy the PELPS folder and 
load the data into R. 
After each scenario run, copy this folder into another folder or  archive. Copying the PELPS folder can also be done by hand if R is not installed on that machine (see above).

In this example, we give the name "your_scenario_name" to the scenario

```r
copy_pelps_folder(scenario_name = "your_scenario_name")
```

To save space, data can be compressed

```r
copy_pelps_folder(scenario_name = "your_scenario_name", compression="bzip2")
```

Then save the base scenario from a bzip2 archive to a RDATA file

```r
savePELPSToRdata("your_scenario_name", compressed="bzip2")
```

Then prepare GFPM scenario data with clean()

```r
your_scenario_name = clean(fileName = "your_scenario_name.RDATA",
                           scenario_name = "your_scenario_name")
```
The `your_scenario_name` object is a list of dataframe. 
The command `str(your_scenario_name)` gives details about the structure and content of this data object. 


# More details on the clean() function

This section provides more details
about the various steps performed by the clean() function.
PELPS data is transformed by adding column titles, 
and translating product and country codes into product and country names. 
available for analysis with R.

* Input: Raw data.frames stored in a .RDATA file
* Output: cleaned data.frames stored in a .RDATA file

## Load raw PELPS tables from a .RDATA file

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

## Example using the function splittrade 

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

## Example using the function reshapeLong

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

## Example using the function add product and country

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

## Example using reshapeLong and addProductAndCountry on World price

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


# List available files
List Zip archives available

```r
list.files("rawdata", ".zip", full.names = TRUE) 
```

List Raw RDATA files available

```r
list.files("rawdata", ".RDATA", full.names = TRUE) 
```
