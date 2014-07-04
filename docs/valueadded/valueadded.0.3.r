#
# Calculate changes in value added for GFPM scenarios
#
# Input: scenarios from the GFPM model in a rdata file
# output: Excel files with Value Added
# Author: Paul Rougieux -  European Forest Institute

require(plyr)
require(xlsx)


# Input files
setwd("Y:/Macro/GFPM/R Pelps/")
print(load("./EndData/GFPM_Output_Scenarios_Combined.rdata"))
print(allScenarios$scenarioName)

# Output directory
setwd("./Docs/Value Added/")

########################################################################
# Create a table for summary countries and regions for the last period #
########################################################################
# Select only the Summary countries for the Value Added analysis
GFPMsummary = subset(allScenarios$entity, Summary==TRUE & 
                         Period==max(allScenarios$entity$Period), 
                     select=c(Country, Product, Volume, Element, GFPM_REG, Scenario))

# Select also the aggregaes
GFPMagg = subset(allScenarios$aggregates,  
                 Period==max(allScenarios$aggregates$Period),
                 select=c(Product, Volume, Element, GFPM_REG, Scenario))

GFPMagg$Country = as.character(GFPMagg$GFPM_REG)

# Add aggregates and summary countries in the same table
GFPMsummary = rbind(GFPMsummary, GFPMagg)    

######################################################################
# Sort countries and products in an order suiting GFPM output tables #
######################################################################
# Change Country to an ordered factor - In the order prefered by Buongiorno
# Summary Countries
sc = unique(subset(allScenarios$entity, Summary==TRUE, select=c(Country,GFPM_REG )))
# Add Region with empty country names
sc = rbind(sc,data.frame(Country="", GFPM_REG= as.character(unique(sc$GFPM_REG))))

# Sort by GFPM region and Country
sc = sc[order(sc$GFPM_REG, sc$Country),]

# Add GFPM region Names in the country column (country name) to make the same output table as Joseph
sc$Country[sc$Country==""] = as.character(sc$GFPM_REG[sc$Country==""])

# Change Country to an ordered factor
GFPMsummary$Country = factor(GFPMsummary$Country, levels = sc$Country, ordered=TRUE)

# Product code
pc = unique(subset(allScenarios$entity, Summary==TRUE, select=c(Product,Product_Code )))
pc = pc[order(pc$Product_Code),]

# Change Product to an ordered factor
GFPMsummary$Product = factor(GFPMsummary$Product, levels=pc$Product, ordered=TRUE)



#####################
# Production volume #
#####################
prod = subset(GFPMsummary, Element=="Production")

# Add "WastePaper" and "OthFbrPlp" supply to the production
prod = rbind(prod,
             subset(GFPMsummary, Product %in% c("WastePaper","OthFbrPlp") &
                        Element=="Supply" ))
prod$Element = "Production"


######################
# Consumption Volume #
######################
cons = subset(GFPMsummary, 
              Product %in% c("IndRound", "OthIndRound", "ChemPlp", "MechPlp",
                             "WastePaper", "OthFbrPlp") &
              Element %in% c("Production","Import","Export","Supply"))

# Change export to a negative value
cons$Volume[cons$Element=="Export"] = -cons$Volume[cons$Element=="Export"] 

# Rename all Elements to consumption
cons$Element = "Consumption"

# Calculate consumption by Aggregating Volume for all elements
cons = aggregate(cons[c("Volume")], subset(cons, select=-c(Volume)),sum,na.rm=TRUE)

# Aggregate IndRound and OthIndRound
indr = subset(cons, Product %in% c("IndRound", "OthIndRound"))
indr$Product = "IndRound"
indr = aggregate(indr[c("Volume")], subset(indr, select=-c(Volume)), sum, na.rm=TRUE)

# Put indround back in the main table
cons = rbind(indr, 
             subset(cons, !Product %in% c("IndRound", "OthIndRound")))

# Check for France
stopifnot(subset(cons, Country=="France"& Product=="IndRound"& Scenario=="High", 
                 select=Volume) == 20195.4)

####################
# Add world prices #
####################
# Add World prices
str(allScenarios$worldPrices)
wp = subset(allScenarios$worldPrices, Period == max(allScenarios$worldPrices$Period),
            select=c("Product", "World_Price", "Scenario"))
prod = merge(prod, wp, all.x=TRUE)
cons = merge(cons, wp, all.x=TRUE)

##############################
# Calculate production value #
##############################
# Value in million USD (divided by 1000)
prod$ProdValue = prod$Volume * prod$World_Price/1000

# reshape to be similar to GFPM format
prodwide = reshape(prod, direction="wide",
                 idvar = c("Country", "Product", "GFPM_REG", "Element"), 
                 timevar = "Scenario")

# Sort by the ordered factors Product and Country (see above)
prodwide = prodwide[order(prodwide$Product, prodwide$Country), ]

# Total added value for all products by country 
prodTotal = aggregate(prodwide[c("ProdValue.High", "ProdValue.Base", "ProdValue.Low")],
                     prodwide[c("Country")], 
                     sum, na.rm=TRUE)

###############################
# calculate consumption value #
###############################
# Value in million USD (divided by 1000)
cons$ConsValue = cons$Volume * cons$World_Price/1000

# reshape to be similar to GFPM format
conswide = reshape(cons, direction="wide",
                   idvar = c("Country", "Product", "GFPM_REG", "Element"), 
                   timevar = "Scenario")

# Sort by the ordered factors Product and Country (see above)
conswide = conswide[order(conswide$Product, conswide$Country), ]

# Total added value for all products by country 
consTotal = aggregate(conswide[c("ConsValue.High", "ConsValue.Base", "ConsValue.Low")],
                      conswide[c("Country")], 
                      sum, na.rm=TRUE)

###############################
# calculate total added value #
###############################
va.tot = merge(prodTotal, consTotal)
stopifnot(nrow(va.tot) == (nrow(prodTotal) + nrow(consTotal))/2) # Check 

# Calculated total added value
va.tot$Value.High = va.tot$ProdValue.High - va.tot$ConsValue.High
va.tot$Value.Base = va.tot$ProdValue.Base - va.tot$ConsValue.Base
va.tot$Value.Low = va.tot$ProdValue.Low - va.tot$ConsValue.Low

# Sort by country
va.tot = va.tot[order(va.tot$Country),]

####################################
# Save value added tables to Excel #
####################################
# Create workbook 
wb = createWorkbook()
cs3 <- CellStyle(wb) + Font(wb, isBold=TRUE) + Border()  # header style

# Create a sheet for each product produced 
for (product in unique(prodwide$Product)){
    sheet = createSheet(wb, sheetName = paste(product, "Production", sep=""))
    
    #Add the data frame for this product to an Excel sheet
    addDataFrame(prodwide[prodwide$Product==product,
                          c("Country",   
                            "World_Price.High", "World_Price.Base", "World_Price.Low",
                            "Volume.High", "Volume.Base", "Volume.Low", 
                            "ProdValue.High", "ProdValue.Base", "ProdValue.Low")],
                 sheet, startRow=1, row.names=FALSE, colnamesStyle=cs3)
}

# Create a sheet for each product consumed
for (product in unique(conswide$Product)){
    print(product)
    sheet = createSheet(wb, sheetName = paste(product, "consumption", sep=""))

    #Add the data frame for this product to an Excel sheet
    addDataFrame(conswide[conswide$Product==product,
                          c("Country",   
                            "World_Price.High", "World_Price.Base", "World_Price.Low",
                            "Volume.High", "Volume.Base", "Volume.Low", 
                            "ConsValue.High", "ConsValue.Base", "ConsValue.Low")],
                 sheet, startRow=1, row.names=FALSE, colnamesStyle=cs3)    
}

dtf2sheet = function(dtf, sheetname=""){
    sheet  = createSheet(wb, sheetName = sheetname)
    addDataFrame(dtf, sheet, row.names=FALSE, colnamesStyle=cs3)
}

# Create a sheet for total output value added
dtf2sheet(prodTotal, "OutputValue")

# Create a sheet for total input value added
dtf2sheet(consTotal, "InputCost")

# Create a sheet for total value added
dtf2sheet(va.tot, "ValueAdded")

# Save Excel file and show me the names of the sheets that have been created
saveWorkbook(wb, "Value Added.xlsx")
names(getSheets(wb) )

