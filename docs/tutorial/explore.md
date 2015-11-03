# Explore GFPM data
Paul Rougieux  



```r
library(GFPMoutput)
library(knitr)
library(plyr)
library(dplyr)
```

```
## 
## Attaching package: 'dplyr'
## 
## The following objects are masked from 'package:plyr':
## 
##     arrange, count, desc, failwith, id, mutate, rename, summarise,
##     summarize
## 
## The following object is masked from 'package:stats':
## 
##     filter
## 
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```r
library(ggplot2)
```




# Load scenario data
Your scenario will reside in the `enddata` folder.
If it was created with the `load_and_clean_gfpm_data()` function, 
the data object will be called `scenario`.
The data object used below for demonstration purposes is called
`trainingScenarios`, because it contains several scenarios.

```r
load("enddata/GFPM_training_scenarios.RDATA")
```

## What is the structure of "trainingScenarios"
The data structure `scenario` and `trainingScenarios` are
lists of data frames:

 * scenario contains the scenario names and file names
 * entity contains the Supply, DPrice, Import, Demand, Export and Production data at the country level
 * aggregates contains the Supply, DPrice, Import, Demand, Export and Production at the regional level
 * worldPrices contains the world prices
 

```r
str(trainingScenarios)
```

```
## List of 4
##  $ scenario   :'data.frame':	4 obs. of  2 variables:
##   ..$ scenario_name: Factor w/ 4 levels "Base","BaseLowElast",..: 1 2 3 4
##   ..$ fileName     : Factor w/ 4 levels "PELPS 105Base.RDATA",..: 1 2 3 4
##  $ entity     :'data.frame':	312492 obs. of  9 variables:
##   ..$ Product_Code: int [1:312492] 80 80 80 80 80 80 80 80 80 80 ...
##   ..$ Product     : chr [1:312492] "Fuelwood" "Fuelwood" "Fuelwood" "Fuelwood" ...
##   ..$ Country_Code: chr [1:312492] "a0" "r6" "i9" "e3" ...
##   ..$ Country     : chr [1:312492] "Algeria" "Tajikistan" "Brunei Darussalam" "Tanzania, United Rep of" ...
##   ..$ GFPM_REG    : Ord.factor w/ 7 levels "Africa"<"North/Central America"<..: 1 4 4 1 4 6 1 4 1 5 ...
##   ..$ Period      : int [1:312492] 5 1 5 1 5 3 1 5 1 4 ...
##   ..$ Volume      : num [1:312492] 6050.8 61 50.8 22831 1.1 ...
##   ..$ Element     : chr [1:312492] "Supply" "DPrice" "DPrice" "Supply" ...
##   ..$ Scenario    : chr [1:312492] "Base" "Base" "Base" "Base" ...
##  $ aggregates :'data.frame':	14652 obs. of  6 variables:
##   ..$ Product : chr [1:14652] "FiberB" "Fuelwood" "Newsprint" "OthIndRound" ...
##   ..$ Element : chr [1:14652] "Demand" "Demand" "Demand" "Demand" ...
##   ..$ GFPM_REG: Ord.factor w/ 7 levels "Africa"<"North/Central America"<..: 1 1 1 1 1 1 1 1 1 1 ...
##   ..$ Period  : int [1:14652] 1 1 1 1 1 1 1 1 1 1 ...
##   ..$ Volume  : num [1:14652] 905 614965 933 28635 4250 ...
##   ..$ Scenario: chr [1:14652] "Base" "Base" "Base" "Base" ...
##  $ worldPrices:'data.frame':	468 obs. of  5 variables:
##   ..$ Product_Code: int [1:468] 80 80 80 80 80 81 81 81 81 81 ...
##   ..$ Product     : chr [1:468] "Fuelwood" "Fuelwood" "Fuelwood" "Fuelwood" ...
##   ..$ Period      : int [1:468] 4 1 2 3 5 3 1 2 4 5 ...
##   ..$ World_Price : num [1:468] 57.6 61 59.9 58.8 56.3 97.2 99 98.1 95.7 94.1 ...
##   ..$ Scenario    : chr [1:468] "Base" "Base" "Base" "Base" ...
```


# Plots
## Base scenario

```r
plotProdByReg(trainingScenarios, "Sawnwood", "Base")
```

![](explore_files/figure-html/sawnwood_base-1.png) 


```r
plotProdByReg(trainingScenarios, "IndRound", "Base")
```

![](explore_files/figure-html/roundwood_base-1.png) 

## Plot by country 

```r
# Sample plot for the base scenario for France and Germany
```


## Compare the base scenario with other scenarios
The other 2 training scenarios, where calculated by changing the demand
elasticities by plus or minus 1 standard error, corresponding to a 
confidence intereval of 70%.

```r
dtf <- subset(trainingScenarios$aggregates, Product=="Sawnwood"& Element=="Demand")
ggplot(data = dtf) +
    aes(x = Period, y = Volume, colour = GFPM_REG, linetype = Scenario) +
    geom_line() + ggtitle("Sawnwood Demand") +
    theme(legend.position = "bottom")
```

![](explore_files/figure-html/sawnwood_demand-1.png) 

Compare for all products

```r
dtf <- subset(trainingScenarios$aggregates, Element=="Demand" & 
                  ! Product %in% c("MechPlp", "ChemPlp", "WastePaper"))
ggplot(data = dtf) +
    aes(x = Period, y = Volume, colour = GFPM_REG, linetype = Scenario) +
    geom_line() + ggtitle("Demand") +
    theme(legend.position = "bottom") + facet_wrap(~Product, scales="free_y")
```

![](explore_files/figure-html/compare_demand_scenarios-1.png) 

# Data summaries
## What products are demanded, supplied, produced or traded ?

```r
whatproducts = function(dtf){unique(dtf$Product)}
dlply(trainingScenarios$entity, .(Element), whatproducts)[-2]
```

```
## $Demand
##  [1] "Fuelwood"    "OthIndRound" "Sawnwood"    "Plywood"     "ParticleB"  
##  [6] "FiberB"      "MechPlp"     "ChemPlp"     "WastePaper"  "Newsprint"  
## [11] "PWPaper"     "OthPaper"    "OthFbrPlp"  
## 
## $Export
##  [1] "Fuelwood"   "IndRound"   "Sawnwood"   "Plywood"    "ParticleB" 
##  [6] "FiberB"     "MechPlp"    "ChemPlp"    "OthFbrPlp"  "WastePaper"
## [11] "Newsprint"  "PWPaper"    "OthPaper"  
## 
## $Import
##  [1] "Fuelwood"   "IndRound"   "Sawnwood"   "Plywood"    "ParticleB" 
##  [6] "FiberB"     "MechPlp"    "ChemPlp"    "OthFbrPlp"  "WastePaper"
## [11] "Newsprint"  "PWPaper"    "OthPaper"  
## 
## $Production
## [1] "Sawnwood"  "Plywood"   "ParticleB" "FiberB"    "MechPlp"   "ChemPlp"  
## [7] "Newsprint" "PWPaper"   "OthPaper" 
## 
## $Supply
## [1] "Fuelwood"    "IndRound"    "OthIndRound" "OthFbrPlp"   "WastePaper" 
## [6] "MechPlp"     "OthPaper"
```
* IndRound is supplied and traded but not demanded, it's a primary product.
* OthFbrPlp and WastePaper are supplied and traded but not demanded, they are primary products.
* Fuelwood is both supplied and demanded it's both a primary and a final product.
* Fuelwood is not the outcome of a production process.

