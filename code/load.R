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
library(devtools)

# This may be moved to a script in the data-raw folder
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

# Change to lowercase preserve the above for backwards compatibility
# Use data as part of the package NAMSPACE
productcodes <- productCodes
countrycodes <- countryCodes
summarycountries <- summaryCountries
use_data(productcodes, countrycodes, summarycountries, elasticities,
         overwrite=TRUE)

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

readPELPSTable = function(scenario_name, fileName, compressed){
    if(compressed == "none"){
        return(read.table(paste("rawdata/", scenario_name, "/", fileName, sep=""),
                          header = FALSE, as.is=TRUE))
    }
    if(compressed == "zip"){
        con = unz(paste("rawdata/", scenario_name, ".zip", sep=""),
                  paste(scenario_name, "/", fileName, sep=""))
        dtf = read.table(con, header = FALSE, as.is=TRUE)
        #close(con) # Not a valid connection
        # print(paste("con.isOpen()",con))
        return(dtf)
    }
    
    if(compressed == "bzip2"){
        # Read only one file from the archive
        temp_dir <- file.path(dirname(tempdir()), basename(tempdir()), scenario_name)
        con = bzfile(paste0("rawdata/",scenario_name,".tar.bz2"), open="rb" )
        # untar(con, list=TRUE) # list files in the archive
        untar(con, files=paste0("pelps/",fileName), exdir = temp_dir)
        close(con)
        dtf = read.table(file.path(temp_dir, "pelps", fileName), header = FALSE, as.is=TRUE)
        # list.files(temp_dir, recursive=TRUE)
        unlink(temp_dir,recursive=TRUE)
        closeAllConnections()
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

savePELPSToRdata = function(scenario_name, compressed="none"){
    #Store the number of columns /periods
    numberOfPeriods = ncol(readPELPSTable(scenario_name, "DEMAND.DAT", compressed)) -1

    PELPS = list(scenario_name = scenario_name, 
                 demand = readPELPSTable(scenario_name, "DEMAND.DAT", compressed), 
                 production = readPELPSTable(scenario_name, "PRODUCTT.DAT", compressed), 
                 trade = readPELPSTable(scenario_name, "TRANSHIP.DAT", compressed), 
                 demandprice = readPELPSTable(scenario_name, "DEMPRICE.DAT", compressed),
                 supply = readPELPSTable(scenario_name, "SUPPLY.DAT", compressed), 
                 worldPrice = readPELPSTable(scenario_name, "WDPRICE.DAT", compressed),
                 numberOfPeriods = numberOfPeriods)

    # Save extracted PELPS data in a RDATA file
    save(PELPS, file=paste("rawdata/", scenario_name,".RDATA", sep=""))
}


############################################## #
# Copy GFPM output data from c:\PELPS\PELPS #
############################################## #
# This function is not needed if you copy the folder by hand to rawdata
copy_pelps_folder <- function(scenario_name, compression="none",
                              pelps_folder="C:/PELPS/pelps/"){
    #' @description
    #' @param scenario_name character string giving a folder or archive name under which the scenario will be saved
    #' @param compression character string giving the type of compression to be used (default none).
    #' @para pelps_folder folder unde which the PELPS data is saved defaults "C:/PELPS/pelps/"
    if(compression == "none"){
        if(file.exists(paste0("rawdata/",scenario_name))) {
            warning("The scenario folder  rawdata/", scenario_name, 
                    "  already exists, we can not overwrite.")
            return(FALSE)
        }
        project_dir <- getwd()
        flist <- list.files(pelps_folder, full.names = TRUE)
        dir.create(paste0("rawdata/",scenario_name))
        message("Copy ", pelps_folder, " to ", project_dir,"/rawdata/",scenario_name," ...")
        file.copy(flist, paste0("rawdata/",scenario_name,"/")) #
        cat(length(list.files(paste0("rawdata/",scenario_name))), "files copied")
        return()
    }    
    if(compression == "bzip2"){
        if(file.exists(paste0("rawdata/",scenario_name,".tar.bz2"))){
            warning("The scenario archive  rawdata/", scenario_name, ".tar.bz2", 
                    "  already exists, we can not overwrite.")
            return(FALSE)
        }
        project_dir <- getwd()
        message("Copy and archive ", pelps_folder,
                " in ", project_dir,"/rawdata/",scenario_name,".tar.bz2 ...")
        setwd(dirname(pelps_folder)) # Move one level up with dirname()
        tryCatch(tar(paste0(project_dir,"/rawdata/",scenario_name,".tar.bz2"), "pelps",
                     compression ="bzip2"), 
                 finally= setwd(project_dir))
        cat(length(untar(bzfile(paste0("rawdata/",scenario_name,".tar.bz2"), 
                                  open="rb" ),
                     list=TRUE)),"files copied in the archive")
        return()
    }
    print("Not a valid scenario compression format")
    return(NULL)
}

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
    savePELPSToRdata("PELPS October 2014 Ahmed")
}

if (FALSE) {
    load_main_scenarios()
}

