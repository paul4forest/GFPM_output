# This script reads ASCII output files from the GFPM (Global FOrest Product Model)
# located in the PELPS directory 
#
# Input: .DAT files from PELPS storred in the ./rawdata folder
# Output: A list of dataframes for each .DAT file
# stored in a .RDATA object for further use by clear.r
#
# Author: Paul Rougieux
# European Forest Institute
#


################################################
# Load and save GFPM Country and product codes #
################################################
# Read country and product codes from 2 csv files (copied from World.xls)
productCodes = read.csv("rawdata/GFPM product codes.csv", as.is=TRUE)
countryCodes = read.csv("rawdata/GFPM country codes 4.csv", as.is=TRUE)

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

# Save product, country codes and selectedCountries to RDATA
save(productCodes, countryCodes, summaryCountries, elasticities,
     file="rawdata/GFPMcodes.RDATA")

#########################################
# Main ASCII output files from the GFPM #
#########################################
# From Table 3 in "GFPM software design"
# AREA    Forest area of in each country
# CAPACITT	Capacity of each produced commodity in each country
# CAPPRICE	Shadow price of each produced commodity in each country
# DEMAND	Demand of each final commodity in each country
# DEMPRICE	Price of each final commodity in each country
# MANUCOST	Manufacture cost of each produced commodity in each country
# OTHPRICE	Price of pulp in each country
# PRODUCTT	Production of each produced commodity in each country
# PROPRICE	Price of each produced commodity in each country
# STOCK	Forest stock in each country
# SUPPLY	Supply of each raw material in each country
# SUPPRICE	Price of each raw material in each country
# TRANCOST	Transportation cost of each traded commodity in each country
# TRANSHIP	Import and export of each traded commodity in each country
# WDPRICE	World price of each commodity


###############################################
# Read .DAT files from folder or .zip archive #
###############################################
# After running a scenario copy the "C:\PELPS\pelps" directory containing .DAT files
# and rename the directory to a unique name identifying your scenario
# This function will convert all interesting .DAT files to R data frames
# It's also possible to compress the folder as .zip format. 

readPELPSTable = function(scenarioName, fileName, scenarioFormat){
    if(scenarioFormat == "folder"){
        return(read.table(paste("rawdata/", scenarioName, "/", fileName, sep=""),
                          header = FALSE, as.is=TRUE))
    }
    if(scenarioFormat == "zip"){
        con = unz(paste("rawdata/", scenarioName, ".zip", sep=""),
                  paste(scenarioName, "/", fileName, sep=""))
        dtf = read.table(con, header = FALSE, as.is=TRUE)
        #close(con) # Not a valid connection
        # print(paste("con.isOpen()",con))
        return(dtf)
    }
    print("Not a valid scenario archive format")
    return(NULL)
}

###############################################
# Load a scenario and save it in a Rdata file #
###############################################
# Wrapper function that calls the function above 
# To load the interesting .DAT files from the archive.

savePELPSToRdata = function(scenarioName, format="folder"){
    #Store the number of columns /periods
    numberOfPeriods = ncol(readPELPSTable(scenarioName, "DEMAND.DAT", format)) -1

    PELPS = list(scenarioName = scenarioName, 
                 demand = readPELPSTable(scenarioName, "DEMAND.DAT", format), 
                 production = readPELPSTable(scenarioName, "PRODUCTT.DAT", format), 
                 trade = readPELPSTable(scenarioName, "TRANSHIP.DAT", format), 
                 demandprice = readPELPSTable(scenarioName, "DEMPRICE.DAT", format),
                 supply = readPELPSTable(scenarioName, "SUPPLY.DAT", format), 
                 worldPrice = readPELPSTable(scenarioName, "WDPRICE.DAT", format),
                 numberOfPeriods = numberOfPeriods)

    # Save extracted PELPS data in a RDATA file
    save(PELPS, file=paste("rawdata/", scenarioName,".RDATA", sep=""))}


########################################
# Load and save all scenarios to RDATA #
########################################
load_main_scenarios = function() {
    message("Loading main PELPS data ...")    
    savePELPSToRdata("PELPS 105Base", "zip")
    savePELPSToRdata("PELPS 105 TFTA High Scenario revision 1", "zip")
    savePELPSToRdata("PELPS 105 TFTA Low scenario revision 1", "zip")
    savePELPSToRdata("World105LowGDPelast", "zip")
    savePELPSToRdata("World105NoTTIPHighGDPelast", "zip")
}

if (FALSE) {
    load_main_scenarios()
}

