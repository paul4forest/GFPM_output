library(devtools)

################################################
# Load and save GFPM Country and product codes #
################################################
# Read country and product codes from 2 csv files (copied from World.xls)
productCodes = read.csv("rawdata/GFPM product codes.csv", as.is=TRUE)
countryCodes = read.csv("rawdata/GFPM country codes 4.csv", as.is=TRUE,
                        fileEncoding =  "LATIN1")
# Encoding issue with "C\xf4te d'Ivoire" fixed by using fileEncoding = "LATIN1"
# iconvlist() provides a list of supported encodings
countryCodes$Country[75]


# Convert EU27 and Europe membership to logical values
countryCodes$EU27 = as.logical(countryCodes$EU27)
countryCodes$Europe = as.logical(countryCodes$Europe)

# Load selected countries from a csv file
# Copied from the "Selection" sheet in SummaryChange.xls
# Column names: "Select", "GFPM Code", "Country"
summaryCountries = read.csv("rawdata/summaryCountries.csv", as.is=TRUE)
summaryCountries = subset(summaryCountries, Select == "y")

# Load demand elasticities
elasticities = read.csv("rawdata/Elasticities.csv")
elasticities = merge(elasticities, productCodes)

# Change GFPM_REG to an ordered factor - In the order prefered by Buongiorno
countryCodes$GFPM_REG = factor(countryCodes$GFPM_REG, 
                               levels= c("Africa", "North/Central America", "South America",
                                         "Asia","Oceania", "Europe", "Dummy Region xy"),
                               ordered=TRUE)
# Check if the conversion to a factor introduced NA values
stopifnot(nrow(countryCodes[is.na(countryCodes$GFPM_REG),])==0)

# Save product, country codes and selectedCountries to RDATA
save(productCodes, countryCodes, summaryCountries, elasticities,
     file="rawdata/GFPMcodes.RDATA")

# Change to lowercase preserve the above for backwards compatibility
# Use data as part of the package NAMESPACE
productcodes <- productCodes
countrycodes <- countryCodes
summarycountries <- summaryCountries
use_data(productcodes, countrycodes, summarycountries, elasticities,
         overwrite=TRUE)