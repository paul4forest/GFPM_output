# Functions to visualise and prepare data tables from GFPM data
#
# Authors: Paul Rougieux and Ahmed Barkaoui
# EFI - Observatory for European Forests
# INRA - Laboratoire d'Economie Forestière
#
library(ggplot2)



############################### #
# Plot Summary by GFPM regions  #
############################### #
plotProdByReg = function(scenarios, product="", scenario=""){
    dtf = subset(scenarios$aggregates, Product==product & Scenario==scenario)
    # Plot elements on the same graph using a facet
    p = ggplot(data=dtf) +
        aes(x=Period, y=Volume, colour=GFPM_REG, label = GFPM_REG) +
        geom_line() + 
        #     geom_text(data=GFPMoutput$aggregates) +
        theme(legend.position = "bottom") +
        facet_wrap(~ Element ) 
    print(p)
}

######################################################### #
# Load and clean the last run scenario from PELPS folder  #
######################################################### #
# This function has to be run after source("code/load.R") abd source("code/clean.R")
load_and_clean_gfpm_data <- function(scenario_name, compression="none"){
    copy_pelps_folder(scenario_name, compression)
    savePELPSToRdata(scenario_name,  compression)
    scenario = clean(paste0(scenario_name,".RDATA"), scenario_name)
    save(scenario, file = paste0("enddata/", scenario_name,".RDATA"))
    if(file.exists(paste0("enddata/", scenario_name,".RDATA"))) {
        message("Data available in  enddata/", scenario_name,".RDATA")
    }
}


#######################################################
# If this script is run as stand alone (not imported) #
#######################################################
if(FALSE){ 
    load("enddata/GFPM_Output_TTIP.RDATA")
    plotProdByReg("Sawnwood", "Base")
    plotProdByReg("IndRound", "Base")
}
