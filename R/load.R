# This script reads ASCII output files from the GFPM (Global FOrest Product Model)
# located in the PELPS directory 
#
# Input: .DAT files from PELPS storred in the ./rawdata folder
# Output: A list of dataframes for each .DAT file
# stored in a .RDATA object for further use by clear.r
#
# Author: Paul Rougieux
# European Forest Institute
# bli



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


#' Read .DAT files from folder or compressed zip or bzip2 archives
#' 
#' After running a scenario copy the "C:\\PELPS\\pelps" directory containing .DAT files
#' and rename the directory to a unique name identifying your scenario
#' This function will convert all interesting .DAT files to R data frames
#' It's also possible to compress the folder as .zip format. 
#' @param scenario_name name of a scenario
#' @param fileName file name
#' @param compressed "none" for no compression, "zip" or "bzip2"
#' @export
readPELPSTable = function(scenario_name, fileName, compressed = "none"){
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

#' Load a scenario and save it in a Rdata file 
#' 
#' Wrapper function that calls \code{\link{readPELPSTable}()}
#' to load the interesting .DAT files from the archive.
#' @param scenario_name name of a scenario
#' @param compressed, see \code{\link{readPELPSTable}()}
#' @return A list of scenarios, saved in a RDATA file.
#' @export
savePELPSToRdata = function(scenario_name, compressed="none"){
    if (compressed == "zip"){
        message("For information: the internal folder in the zip ",
                "archive should also be called: ", scenario_name)
    }
    
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
    if (!file.exists("rawdata")){
        dir.create("rawdata")
    }
    save(PELPS, file=paste("rawdata/", scenario_name,".RDATA", sep=""))
}



#' Copy GFPM output data 
#' 
#' This function is not needed if you copy the folder by hand to rawdata
#' @param scenario_name character string giving a folder or archive name under which the scenario will be saved
#' @param pelps_folder folder unde which the PELPS data is saved defaults "C:/PELPS/pelps/"
#' @param compression character string giving the type of compression to be used (default none).
#' @export
copy_pelps_folder <- function(scenario_name, 
                              pelps_folder="C:/PELPS/pelps",
                              compression="none"){
    if (!file.exists(pelps_folder)){
        stop("The folder ",pelps_folder," doesn't exist.")
    }
    if(compression == "none"){
        if(file.exists(paste0("rawdata/",scenario_name))) {
            stop("The scenario folder  rawdata/", scenario_name, 
                 "  already exists, we can not overwrite.",
                 " Change scenario name or delete rawdata/", scenario_name,".")
            return(FALSE)
        }
        project_dir <- getwd()
        flist <- list.files(pelps_folder, full.names = TRUE)
        dir.create(paste0("rawdata/",scenario_name),recursive = TRUE)
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

