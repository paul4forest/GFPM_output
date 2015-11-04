# Functions to visualise and prepare data tables from GFPM data
#
# Authors: Paul Rougieux and Ahmed Barkaoui
# EFI - Observatory for European Forests
# INRA - Laboratoire d'Economie Forestière
#
library(ggplot2)



#' Plot Summary by GFPM regions  
#'
#' @param scenarios a list of scenarios, output of \code{\link{savePELPSToRdata}()}
#' @param product a vector of product names to select
#' @param sceario a vector of scenario names to select
#' @export
plotprodbyreg = function(scenarios, product, scenario){
    dtf = subset(scenarios$aggregates, Product==product & Scenario==scenario)
    # Plot elements on the same graph using a facet
    p = ggplot(data=dtf) +
        aes(x=Period, y=Volume, colour=GFPM_REG, label = GFPM_REG) +
        geom_line() + 
        #     geom_text(data=GFPMoutput$aggregates) +
        theme(legend.position = "bottom") +
        facet_wrap(Product ~ Element ) 
    print(p)
}


#' Plot by GFPM countries  
#'
#' @param scenarios a list of scenarios, output of \code{\link{savePELPSToRdata}()}
#' @param product a character vector of product names to select
#' @param scenario a character vector of scenario names to select, only one scenario
#' @param country a character vector of countries to select
#' @export
plotprodbycounty <- function(scenarios, product, scenario, country){
    # Select country data
    dtf <- scenarios$entity %>% 
        filter(Product == product & Country %in% country & 
                   Element != "DPrice" & Scenario == scenario)
    p <- ggplot(data=dtf) +
        aes(x=Period, y=Volume, colour=Country, label = Country) +
        geom_line() + 
        theme(legend.position = "bottom") +
        facet_grid(Product ~ Element) 
    plot(p)
}

#######################################################
# If this script is run as stand alone (not imported) #
#######################################################
if(FALSE){ 
    load("enddata/GFPM_Output_TTIP.RDATA")
    plotprodbyreg("Sawnwood", "Base")
    plotprodbyreg("IndRound", "Base")
}
