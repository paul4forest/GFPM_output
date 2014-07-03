Explore TTIP dataset
=====================



Load a dataset containing GFPM scenarios

```r
library(plyr)
library(xtable)
library(ggplot2)
load("enddata/GFPM_Output_TTIP_with_sensitivity.RDATA")
```



Sensitivity analysis 
---------------------
Plot scenarios changes




```r
product = "Sawnwood"
element = "Demand"
aggregates = subset(allScenarios$aggregates, Scenario != "LowTTIP")
dtf = subset(aggregates, Product == product)


p = ggplot(data = subset(dtf, Element == element)) + aes(x = Period, y = Volume, 
    colour = GFPM_REG, linetype = Scenario) + geom_line() + # geom_point(aes(shape=Scenario)) + geom_point(data = subset(dtf,Element ==
# element&Scenario=='HighTTIP'), shape=15, size=4) +
geom_point(data = subset(dtf, Element == element & Scenario == "HighTTIP"), 
    aes(shape = Scenario), size = 4) + ggtitle(paste(product, element)) + theme(legend.position = "bottom")
print(p)
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3.png) 


### Make a similar  graph for US - EU28 - Rest of the world


Comparison with Felbermayr 2013
-------------------------------
Felbermayr 2013 reports a simulation of US and Germany's export values by 2025 for 3 forest related sectors: "forestry", "wood products" and "paper". 

What are the export products?

```r
unique(allScenarios$entity$Product[allScenarios$entity$Element == "Export"])
```

```
##  [1] "Fuelwood"   "IndRound"   "Sawnwood"   "Plywood"    "ParticleB" 
##  [6] "FiberB"     "MechPlp"    "ChemPlp"    "OthFbrPlp"  "WastePaper"
## [11] "Newsprint"  "PWPaper"    "OthPaper"
```


We will aggregate the products as such:
* __Forestry__ :  IndRound, 
* __Wood Products__ :  "Fuelwood" "Sawnwood"   "Plywood"    "ParticleB"  "FiberB"  
* __Paper Products__ : "MechPlp"  "ChemPlp"    "OthFbrPlp"  "WastePaper" "Newsprint"  "PWPaper"    "OthPaper"  
    
US and Germany's exports in forest products in 2025 (period 4 in our simulation). We are looking at percentage changes in volume between the base and the high scenarios.

```r
USDEexp = subset(allScenarios$entity, Country %in% c("United States of America", 
    "Germany") & Element == "Export" & Period == 4 & Scenario %in% c("Base", 
    "High"), select = c(Scenario, Period, Product, Country, Volume))
USDEexp = reshape(USDEexp, idvar = c("Period", "Product", "Country"), timevar = "Scenario", 
    times = c("Base", "High"), direction = "wide")
USDEexp = transform(USDEexp, expchange = round((Volume.High - Volume.Base)/Volume.Base * 
    100, 2))
```

```
## Error: object 'Volume.High' not found
```

```r
USDEexp = reshape(subset(USDEexp, select = -c(Volume.Base, Volume.High)), idvar = c("Period", 
    "Product"), timevar = "Country", direction = "wide")
```

```
## Error: object 'Volume.High' not found
```

```r
names(USDEexp) = c("Period", "Product", "US exports %", "Germany exports %")
print(xtable(USDEexp, caption = "Percentage change in exports between the \n             base and high scenarios on period 4 (2015)"), 
    type = "html", include.rownames = FALSE)
```

<!-- html table generated in R 3.0.2 by xtable 1.7-1 package -->
<!-- Fri Jan 24 18:42:18 2014 -->
<TABLE border=1>
<CAPTION ALIGN="bottom"> Percentage change in exports between the 
             base and high scenarios on period 4 (2015) </CAPTION>
<TR> <TH> Period </TH> <TH> Product </TH> <TH> US exports % </TH> <TH> Germany exports % </TH>  </TR>
  <TR> <TD align="right">   4 </TD> <TD> Fuelwood </TD> <TD> United States of America </TD> <TD align="right"> 162.90 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> Fuelwood </TD> <TD> Germany </TD> <TD align="right"> 70.30 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> IndRound </TD> <TD> United States of America </TD> <TD align="right"> 22111.40 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> IndRound </TD> <TD> Germany </TD> <TD align="right"> 3833.60 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> Sawnwood </TD> <TD> United States of America </TD> <TD align="right"> 2022.30 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> Sawnwood </TD> <TD> Germany </TD> <TD align="right"> 14754.60 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> Plywood </TD> <TD> United States of America </TD> <TD align="right"> 278.20 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> Plywood </TD> <TD> Germany </TD> <TD align="right"> 187.00 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> ParticleB </TD> <TD> Germany </TD> <TD align="right"> 4423.60 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> ParticleB </TD> <TD> United States of America </TD> <TD align="right"> 169.10 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> FiberB </TD> <TD> United States of America </TD> <TD align="right"> 421.80 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> FiberB </TD> <TD> Germany </TD> <TD align="right"> 3903.40 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> MechPlp </TD> <TD> United States of America </TD> <TD align="right"> 317.40 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> MechPlp </TD> <TD> Germany </TD> <TD align="right"> 7.50 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> ChemPlp </TD> <TD> United States of America </TD> <TD align="right"> 9125.30 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> ChemPlp </TD> <TD> Germany </TD> <TD align="right"> 464.80 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> OthFbrPlp </TD> <TD> United States of America </TD> <TD align="right"> 173.10 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> OthFbrPlp </TD> <TD> Germany </TD> <TD align="right"> 87.40 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> WastePaper </TD> <TD> United States of America </TD> <TD align="right"> 32176.40 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> WastePaper </TD> <TD> Germany </TD> <TD align="right"> 1604.30 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> Newsprint </TD> <TD> United States of America </TD> <TD align="right"> 332.40 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> Newsprint </TD> <TD> Germany </TD> <TD align="right"> 377.40 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> PWPaper </TD> <TD> Germany </TD> <TD align="right"> 8430.70 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> PWPaper </TD> <TD> United States of America </TD> <TD align="right"> 1005.80 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> OthPaper </TD> <TD> United States of America </TD> <TD align="right"> 5471.30 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD> OthPaper </TD> <TD> Germany </TD> <TD align="right"> 5925.70 </TD> </TR>
   </TABLE>

```r
USDEexp$ProductAgg[USDEexp$Product %in% c("Fuelwood", "Sawnwood", "Plywood", 
    "ParticleB", "FiberB")] = "Wood Products"
USDEexp$ProductAgg[USDEexp$Product == "IndRound"] = "Forestry"
# USDEexp$ProductAgg[USDEexp$Product %in% c('MechPlp', 'ChemPlp',
# 'OthFbrPlp', 'WastePaper', 'Newsprint', 'PWPaper', 'OthPaper') = 'Paper
# Products'
```

