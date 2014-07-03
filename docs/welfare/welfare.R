#
# calculates changes in welfare for GFPM scenarios
#
# Input: scenarios from the GFPM model in a rdata file
# output: Excel files with welfare calculations
# Author: Paul Rougieux -  European Forest Institute
#
# For issues investigated while writting this script, such as missing supply data 
# See also the script Welfare_Issues_Investigation.r

#
# Change log 
# (see also on the command line git log docs/welfare/welfare.R)
# git log --graph --decorate --all --pretty=oneline docs/welfare/welfare.R
#
# January 2014 - Take into account all scenarios in the welfare calculation
# Welfare calculation were done in a general way until recently

require(plyr)
require(xlsx)
options(width = 98)

# Input files
print(load("rawdata/GFPMcodes.RDATA"))
print(load("enddata/GFPM_Output_TTIP_with_sensitivity.RDATA"))
print(allScenarios$scenario)

#########################################################
# Prepare table of demand and supply volumes for summary countries #
#########################################################
# Select only the Summary countries for the welfare analysis
dmd = subset(allScenarios$entity, Element=="Demand" & Country %in% summaryCountries$Country &
                 Period==max(allScenarios$entity$Period) ,
             select=c(Country, Product, Volume, Element, GFPM_REG, Scenario))

sup = subset(allScenarios$entity, Element=="Supply" & Country %in% summaryCountries$Country & 
                 Period==max(allScenarios$entity$Period) & 
                 Product%in% c("Fuelwood", "IndRound", "OthIndRound"),
             select=c(Country, Product, Volume, Element, GFPM_REG, Scenario))

# Select also the aggregates as they are present in Buongiorno's table
dmdagg = subset(allScenarios$aggregates,  Element=="Demand" &
                    Period==max(allScenarios$aggregates$Period),
                select=c(Product, Volume, Element, GFPM_REG, Scenario))
dmdagg$Country = as.character(dmdagg$GFPM_REG)

supagg = subset(allScenarios$aggregates, 
             Period==max(allScenarios$aggregates$Period) & Element=="Supply"&
                 Product%in% c("Fuelwood", "IndRound", "OthIndRound"),
             select=c(Product, Volume, Element, GFPM_REG, Scenario))
supagg$Country = as.character(supagg$GFPM_REG)


# Add Regional values to the country values
wf = rbind(dmd, sup, dmdagg, supagg)
rm(dmd, sup, dmdagg, supagg)
n = nrow(wf) # To check later if the number of row changes when we merge data

# Aggregate othIndRound and IndRound Volumes
wfIndRound = subset(wf, Product %in% c("IndRound", "OthIndRound"),
                    select=c("Country", "Volume", "Element", "GFPM_REG", "Scenario"))

wfIndRound = aggregate(wfIndRound[c("Volume")], 
                       wfIndRound[c("Country", "Element", "GFPM_REG", "Scenario")],
                       sum, na.rm=TRUE )
wfIndRound$Product = "IndRound"

# Add back into wf
wf = rbind(wf[!wf$Product %in% c("IndRound", "OthIndRound"),],
           wfIndRound)

# Add elasticities
wf = merge(wf, elasticities[c("Product", "Element", "Elasticity")], all.x=TRUE )
# stopifnot(n == nrow(wf)) # That test was before we aggregated volumes of indround

# Add world prices 
wp = subset(allScenarios$worldPrices, Period == max(allScenarios$worldPrices$Period),
            select=c("Product", "World_Price", "Scenario"))
wf = merge(wf, wp, all.x=TRUE)
# stopifnot(n == nrow(wf))

# Remove other industrial roundwood and chemichal pulp 
wf = wf[!wf$Product%in%c("OthIndRound", "ChemPlp"),]

######################################################################
# Sort countries and products in an order suiting GFPM output tables #
######################################################################
# Change Country to an ordered factor - In the order prefered by Buongiorno
# Summary Countries
sc = unique(subset(allScenarios$entity, Country %in% summaryCountries$Country,
                   select=c(Country,GFPM_REG )))
# Add Region with empty country names
sc = rbind(sc, data.frame(Country="", GFPM_REG = as.character(unique(allScenarios$aggregates$GFPM_REG))))

# Sort by GFPM region and Country
sc = sc[order(sc$GFPM_REG, sc$Country),]

# Add GFPM region Names in the country column (country name) to make the same output table as Joseph
sc$Country[sc$Country==""] = as.character(sc$GFPM_REG[sc$Country==""])

# Change Country to an orderd factor
wf$Country = factor(wf$Country, levels= sc$Country, ordered=TRUE)

# Product code
pc = unique(subset(allScenarios$entity, Country %in% summaryCountries$Country,
                   select=c(Product,Product_Code )))
pc = pc[order(pc$Product_Code),]

# Change Product to an ordered factor
wf$Product = factor(wf$Product, levels=pc$Product, ordered=TRUE)

#####################
# Calculate Welfare #
#####################
# For the new calculation see below "a simpler way"
# This is Joseph's calculation of welfare with slope and intercept
# It remains for information purposes, lines are commented and will not be calculated
# wf$Slope = wf$World_Price / (wf$Elasticity * wf$Volume)
# wf$Intercept = wf$World_Price - wf$Slope * wf$Volume # worldprice - worldprice/elasticity
# wf$WelfareJoseph = wf$Intercept * wf$Volume + 0.5*wf$Slope * wf$Volume ^2 -
#     wf$Volume * wf$World_Price

# Welfare calculation a simpler way
wf$Welfare = -0.5 * wf$World_Price * wf$Volume / wf$Elasticity

# Producer welfare is opposite to consumer welfare
wf$Welfare[wf$Element=="Supply"] = - wf$Welfare[wf$Element=="Supply"]

#################################################################
# calculate welfare difference between Base and other scenarios #
#################################################################
# Add base year as a new column for comparison
wfbase <- subset(wf, Scenario=="Base", select=c(Product, Element, Country, Welfare))
names(wfbase)[names(wfbase) == 'Welfare'] <- 'Welfare_Base'
wf <- merge(wf, wfbase, all.x=TRUE)

# Calculate the difference 
wf <- mutate(wf, 
            Diff = Welfare - Welfare_Base, 
            Diff_percent = Diff/Welfare_Base* 100)

###########################
# Calculate total welfare #
###########################
wfTotal <- aggregate(wf[c("Welfare")], 
                    by = wf[c("Country", "Scenario", "Element")], 
                    FUN = sum, na.rm=TRUE )

# Calculate the difference in total welfare
# Add base year as a new column for comparison
wfTotalBase <- subset(wfTotal, Scenario=="Base", select=c(Country,Element,Welfare))
names(wfTotalBase)[names(wfTotalBase)=="Welfare"] <- "Welfare_Base"
wfTotal <- merge(wfTotal, wfTotalBase, all.x=TRUE)
wfTotal <- mutate(wfTotal, 
                  Diff = Welfare - Welfare_Base,
                  Diff.Percent = round(Diff/Welfare_Base, 2))


# View total welfacre for the HighTTIP scenario
subset(wfTotal, Scenario=="HighTTIP")

# Calculate total welfare and add it to the total table
wfTotal2 <- aggregate(wfTotal[c("Welfare", "Welfare_Base", "Diff")], 
                      by = wfTotal[c("Country", "Scenario")],
                      FUN = sum, na.rm = TRUE)
wfTotal2 <- mutate(wfTotal2, Element = "Total",
                   Diff.Percent = round(Diff/Welfare_Base, 2))
wfTotal <- rbind(wfTotal, wfTotal2)
wfTotal <- arrange(wfTotal, Element, Country)


###################################################################
# View differences in welfare as in Joseph's publication table 10 #
###################################################################
wfTotal$Diff = round(wfTotal$Diff / 1000)
# View reshaped difference for High scenario
wfHighTTIP <- reshape(subset(wfTotal, Scenario=="HighTTIP", 
                             select=c(Country, Element, Diff, Diff.Percent)), 
                      direction = "wide",
                      idvar = c("Country"), 
                      timevar = "Element")

# View reshaped difference for Low scenario
wfLowTTIP <- reshape(subset(wfTotal, Scenario=="LowTTIP", 
                            select=c(Country, Element, Diff, Diff.Percent)), 
                     direction = "wide",
                     idvar = c("Country"), 
                     timevar = "Element")


###########################################
###########################################
# Old Welfare calculations in wide format #
###########################################
###########################################
# --> January 2014 comment: 
# Post this on my blog with the new version in long format to compare
# Reshape to have one column per scenario as in Joseph's Excel file
wfwide = reshape(wf, direction = "wide",
                 idvar = c("Country","Product", "GFPM_REG", "Element"), 
                 timevar = "Scenario")

# Calculate the difference between alternative scenarios and the base scenario 
wfwide$diffHigh = wfwide$Welfare.High - wfwide$Welfare.Base
wfwide$diffHighPercent = round(wfwide$diffHigh/wfwide$Welfare.Base * 100 )
wfwide$diffLow = wfwide$Welfare.Low - wfwide$Welfare.Base

# Sort by the ordered factor Product and Country (see above)
wfwide = wfwide[order(wfwide$Product,wfwide$Country),]

# Separate Consumer and producer welfare
cwf = subset(wfwide, Element=="Demand")
pwf = subset(wfwide, Element=="Supply")

# Where did I loose the sensitivity scenarios?
# OK it's to calculate the difference from the base scenario.
names(wfwide)


####################################
# Calculate total Consumer welfare #
####################################
# No need to reshape, you could use a 

# Total consumers welfare for all products by country
cwfTotal = aggregate(cwf[c("Welfare.Base", "Welfare.HighTTIP","Welfare.LowTTIP" )], 
                    cwf[c("Country")], 
                    sum, na.rm=TRUE )

# Difference in consumer welfare in 2030 due to the High TFTA impact
wfHDiffP = reshape(cwf[c("Country","Product","diffHigh")],
                      direction="wide",
                      idvar = c("Country"), timevar="Product")

# Divide by 1000 to have values in million$ of 2010 as in Joseph's table
wfHDiffP[-1] = wfHDiffP[-1]/1000

# Difference in consumer welfare in 2030 due to the Low TFTA impact
wfLDiffP = reshape(cwf[c("Country","Product","diffLow")],
                      direction="wide",
                      idvar = c("Country"), timevar="Product")

# Divide by 1000 to have values in million$ of 2010 as in Joseph's table
wfLDiffP[-1] = wfLDiffP[-1]/1000

# Compare new Total welfare table and old wide table
names(wfTotal)[names(wfTotal) == 'Welfare'] <- 'Welfare_Total'
wfcomp = reshape(wfTotal, direction = "wide",
                 idvar = c("Country", "Element"), 
                 timevar = "Scenario")

wfcomp = merge(subset(wfcomp, Element=="Demand"), cwfTotal)
mutate(wfcomp, checkWfBase = Welfare_Total.Base - Welfare.Base,
       checkWfHighTTIP = Welfare_Total.HighTTIP - Welfare.HighTTIP,
       checkWfLowTTIP = Welfare_Total.LowTTIP - Welfare.LowTTIP)


####################################
# Calculate total Producer welfare #
####################################
# Total producers welfare for all products by country
pwfTotal = aggregate(pwf[c("Welfare.Base", "Welfare.HighTTIP","Welfare.LowTTIP" )], 
                     pwf[c("Country")], 
                     sum, na.rm=TRUE )


##########################################
##########################################


###########################
# Calculate total welfare #
###########################
twf = merge (cwfTotal, pwfTotal, by="Country", suffixes = c(".Consumers",".Producers"))
twf$TotalWelfareBase = twf$Welfare.Base.Consumers + twf$Welfare.Base.Producers
twf$TotalWelfareHigh = twf$Welfare.HighTTIP.Consumers + twf$Welfare.HighTTIP.Producers
twf$TotalWelfareLow = twf$Welfare.LowTTIP.Consumers + twf$Welfare.LowTTIP.Producers
twf$DiffHigh = twf$TotalWelfareHigh - twf$TotalWelfareBase
twf$DiffLow = twf$TotalWelfareLow - twf$TotalWelfareBase
twf = twf[order(twf$Country),]


################################
# Save welfare tables to Excel #
################################
# Create workbook 
wb = createWorkbook()
cs3 <- CellStyle(wb) + Font(wb, isBold=TRUE) + Border()  # header style

addWelfareTable = function (dtf, sheet){
    # Add the data frame for a particular product to an Excel sheet
    addDataFrame(dtf[c("Product", "Country", "Volume.Base", "Welfare.Base",
                       "Volume.HighTTIP", "Welfare.HighTTIP", 
                       "Volume.LowTTIP", "Welfare.LowTTIP")],
                 sheet, startRow=4, row.names=FALSE, colnamesStyle=cs3)
    
    # Add info on elasticities and World price on top of sheet
    rows = createRow(sheet, rowIndex=1:2)
    cells = createCell(rows, colIndex=1:8)
    setCellValue(cells[[1,2]],"Elasticity")
    setCellValue(cells[[1,4]],unique(dtf$Elasticity.Base))
    setCellValue(cells[[2,2]],"World Price Base")
    setCellValue(cells[[2,4]],unique(dtf$World_Price.Base))
    setCellValue(cells[[1,6]],"World Price High")
    setCellValue(cells[[1,8]],unique(dtf$World_Price.High))
    setCellValue(cells[[2,6]],"World Price Low")
    setCellValue(cells[[2,8]],unique(dtf$World_Price.Low))    
}


# Create a sheet for each Consumer products
for (product in unique(cwf$Product)){
    addWelfareTable(dtf = cwf[cwf$Product==product,],
                    sheet  = createSheet(wb, sheetName=paste(product,"Consumers", sep="")))
}

# Add total consumer sheet 
sheet  = createSheet(wb, sheetName="TotalConsumersWelfare")
addDataFrame(cwfTotal, sheet, row.names=FALSE, colnamesStyle=cs3)

# Add a table of diff per product High scenario - base scenario  
addDataFrame(wfHDiffP, sheet, startRow=nrow(cwfTotal)+7, row.names=FALSE, colnamesStyle=cs3)
# Add diff low scenario - base scenario
addDataFrame(wfLDiffP, sheet, startRow=nrow(cwfTotal)+nrow(wfHDiffP) + 10, row.names=FALSE, colnamesStyle=cs3)

# Create a sheet for each produced product
for (product in unique(pwf$Product)){
    addWelfareTable(dtf = pwf[pwf$Product==product,],
                    sheet  = createSheet(wb, sheetName=paste(product,"Producers", sep="")))
}

# Add total producers welfare sheet 
sheet  = createSheet(wb, sheetName="TotalProducersWelfare")
addDataFrame(pwfTotal, sheet, row.names=FALSE, colnamesStyle=cs3)

# Add total Welfare sheet 
sheet  = createSheet(wb, sheetName="TotalWelfare")
addDataFrame(twf[c("Country","TotalWelfareBase", "TotalWelfareHigh", "TotalWelfareLow",
                   "DiffHigh", "DiffLow")],
             sheet, row.names=FALSE, colnamesStyle=cs3)

# Save Excel file and show me the names of the sheets that have been created
saveWorkbook(wb, paste("docs/Welfare/Welfare ", allScenarios$scenarioName$high,".xlsx", sep=""))
names(getSheets(wb) )


###########################
# Plot changes in welfare #
###########################
library(ggplot2)
ggplot(data=subset(wf, Scenario=="HighTTIP")) +
    aes(x=Product, y=Diff, color=Country, label=Country) +
    geom_point() + 
    geom_text(data=subset(wf, Diff>1000000))

# The issue is that regions are mixed, keep continents only.
wfContinent = subset(wf, Scenario!="Base" &  as.character(Country)==as.character(GFPM_REG))

ggplot(data=wfContinent) +
    aes(x=Product, y=Diff, color=Country, label=Country) +
    geom_point() + 
    geom_text(data=subset(wfContinent, Diff>1000000 | Diff< -1000000)) +
    facet_wrap(~Scenario)
