# This script is only working on the development machine
# Update needed see 
# 

# Add historical data from FAOSTAT to the GFPM simulations
# 
#  Calculate consumption and net trade for the FAOSTAT data
#  TODO: add historical price in 2010 USD,  
# return A table coutaining both historical and simulated data 
# The table should have these columns:
# Scenario | Country | Product | Year | Element | Volume
#  
# Some countries are not in the GFPM
# not_in_gfpm <- unique(sawnwood$entity[c("FAOST_CODE", "Country")]) %>%
#     merge(transmute(gfpm_countries, 
#                     FAOST_CODE = FAOST_CODE, Country_GFPM=Country),
#           all.x = TRUE) %>% 
#     filter(is.na(Country_GFPM))
#     
# Table 1 from Calibrating GFPM 2013.doc
#     |GFPM names|Item Name FAO|File Name|
#     |:----------|:----------|:----------|
#     |Fuelwood|WOOD FUEL+|Fuelwood.csv|
#     |Chips and Particles|Chips and Particles|Chips.csv|
#     |Industrial Roundwood|INDUSTRIAL ROUNDWOOD+|IndRound.csv|
#     |Other Industrial Roundwood|OTHER INDUST ROUNDWD+|OthIndRound.csv|
#     |Sawnwood|SAWNWOOD+|Sawnwood.csv|
#     |Plywood|Plywood|Plywood.csv|
#     |Veneer Sheets|Veneer Sheets|Veneer.csv|
#     |Particleboard|Particle Board|ParticleB.csv|
#     |Fiberboard|FIBREBOARD+|FiberB.csv|
#     |Mechanic Pulp|Mechanical Wood Pulp|MechPlp.csv|
#     |Chemical Pulp|Chemical Wood Pulp|ChemPlp.csv|
#     |Semi-chemical Pulp|Semi-Chemical Pulp|SemiChemPlp.csv|
#     |Other Fiber Pulp|Other Fibre Pulp|OthFbrPlp.csv|
#     |Newsprint|Newsprint|Newsprint.csv|
#     |Printing and Writing Paper|Printing+Writing Paper|PWPaper.csv|
#     |Other Paper and Paperboard|Other Paper+Paperboard|OthPaper.csv|
#     |Waste Paper|Recovered Paper|WastePaper.csv|
#     |Forest Stock and Area|Forest Stock and Area|Forest.csv|


library(ggplot2)
library(dplyr)
library(reshape2)

if(FALSE){
    
    # Load conversion tables 
    gfpm_countries = read.csv("rawdata/GFPM country codes 4.csv")
    gfpm_products = read.csv("rawdata/GFPM product codes 2.csv")
    
    
    #' Calculate consumption and net trade
    #' Keep this function so that
    #' the change of NA values to 0 only affects this calculation
    #' In other words, NA values for production and trade volumes
    #' are kept in the fao table
    calculateConsumptionNetTrade = function(dtf){
        # Change NA values to 0 - Not recommended 
        # But makes sence at least that import into Finland and Sweden are 0
        dtf[is.na(dtf)] = 0
        
        # Calculate apparent consumption and net trade
        dtf = mutate(dtf, 
                     Demand = Production + Import_Quantity - Export_Quantity)
        #, 
        #                  Net_Trade =  Export_Quantity - Import_Quantity)
        return(dtf)
    }
    
    
    # Load FAOSTAT raw data from another project
    demandprojectpath <- "/home/paul/hubic/work/EFI/Y/forestproductsdemand/rawdata"
    load(file.path(demandprojectpath,"roundwood.Rdata"))
    load(file.path(demandprojectpath,"Paper and paperboard.RData"))
    load(file.path(demandprojectpath,"sawnwood.RData"))
    load(file.path(demandprojectpath,"woodpanels.Rdata"))
    load(file.path(demandprojectpath,"wastepaper.RData"))
    
    
    # Prepare FAO historical data for merger with gfpm data
    fao <- rbind(roundwood$entity, sawnwood$entity, 
                 paperAndPaperboardProducts$entity,
                 woodpanels$entity, wastepaper$entity) %>%
        filter(Year >= 1990) %>%
        calculateConsumptionNetTrade %>%
        # Remove trade values
        select(-Export_Value, -Import_Value) %>%
        rename(Export = Export_Quantity,
               Import = Import_Quantity) %>%
        # Replace Country by GFPM Country
        select(-Country) %>%
        merge(select(gfpm_countries, FAOST_CODE, Country)) %>%
        # Replace Item by GFPM Product
        merge(select(gfpm_products, Item, Product)) %>%
        select(-Item) %>%
        # Reshape the table in long format
        melt(id=c("FAOST_CODE", "Country", "Year", "Product"),
             value.name = "Volume", variable.name = "Element") %>%
        mutate(Scenario = "Historical") %>%
        select(Scenario, Country, Year, Product, Element, Volume)
    
    
    # Check if we lost data
    # Compare total sawnwood production before and after the change
    stopifnot(sawnwood$entity %>% 
                  filter(FAOST_CODE %in% gfpm_countries$FAOST_CODE &
                             Year>=1990 & 
                             Item=="Sawnwood") %>%
                  summarise(Production = sum(Production, na.rm=TRUE)) ==
                  fao %>% 
                  filter(Product == "Sawnwood" &
                             Element == "Production")  %>%
                  summarise(Production = sum(Volume, na.rm=TRUE)))
    
    
    # Load GFPM data
    load("enddata/GFPM_training_scenarios.RDATA")
    
    # Add years to the base scenario
    years <- data.frame(Scenario="Base",
                        Period=seq(1,5), Year=seq(2010,2030,5)) %>%
        rbind(data.frame(Scenario="Base2011",
                         Period=seq(1,5), Year=c(2011,seq(2015,2030,5))))
    
    
    # Add fao historical data to gfpm data
    gfpm <- trainingScenarios$entity %>%
        filter(Scenario %in% c("Base", "Base2011")) %>%
        merge(years) %>%
        select(Scenario, Country, Year, Product, Element, Volume) %>%
        mutate(Volume = 1000 * Volume) %>%
        # Add fao data
        rbind(fao)
    
    
    # Change scenario to an ordered factor so that historical appears first
    gfpm$Scenario <- factor(gfpm$Scenario,
                            levels = unique(c("Historical", gfpm$Scenario)),
                            ordered = TRUE)
    
    # unique(gfpm[c("Year","Scenario")]) %>% arrange(Year)
    unique(gfpm[c("Scenario", "Element")]) %>% arrange(Scenario)
    
    # Save this data
    save(gfpm, file="enddata/GFPM_training_scenarios_with_historical.RDATA")
    
}