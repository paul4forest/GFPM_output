# This script prepares PELPS data for ploting and making summary tables
# PELPS files are the output of the Global FOrest Product Model GFPM
#
# See also README.txt and example of functions use.
# Input: RDATA files containing one data frame for each .DAT file in PELPS
# Output: RDATA file containing a big dataframe of all countries, products and flows
#
# Goals: (1) better plots for European countries output. 
# (2) reading raw ASCII output directly from the PELPS directory remove the need for running 
# lengthy "get output", "get summary", "summery change" in Excel. 
#
# Authors: Paul Rougieux and Ahmed Barkaoui
# European Forest Institute - Observatory for European Forests
# INRA - Laboratoire d'Economie Forestière
#

# Suggested functionalities: 
# put load and clean functions in the .func script


# Merge selected countries to the countrycodes table
# summaryCountries$Summary = summaryCountries$Select %in% c("y", TRUE)
# n = nrow(countryCodes)
# countryCodes = merge(countryCodes, summaryCountries[c("Summary","Country_Code")], all.x=TRUE)
# stopifnot(nrow(countryCodes)==n) # Check if we lost some rows during the merge



###############################
# Functions to clean the data #
###############################
# Functions are tested one by one in the example at the bottom of this script
#

# Split trade in 2 dataframes for import and export #
splittrade = function(P){
    # Find import region and remove zz from the code
    P$import = P$trade[substr(P$trade$V1, 2, 3) == "zz",]
    P$import$V1 = paste("E", substr(P$import$V1, 4, 5),
                            substr(P$import$V1, 6,7), sep="")
    
    # Find export region and remove zz from the code
    P$export = P$trade[substr(P$trade$V1, 4, 5) == "zz",]
    P$export$V1 = paste("I", substr(P$export$V1, 2, 3),
                            substr(P$export$V1, 6, 7), sep="")
    
    # Check if we lost data
    stopifnot(nrow(P$import)+nrow(P$export) == nrow(P$trade))
    return (P)
}


# Reshape PELPS tables and extract code in a truly Long format #
reshapeLong = function(df.PELPS, elementName=""){
    df.PELPS = reshape(df.PELPS, 
                       idvar=c("V1"), varying=list(names(df.PELPS[-1])), 
                       timevar="Period", v.names="Volume",
                       direction="long" )
    df.PELPS$Element = elementName
    df.PELPS$Code = substr(df.PELPS$V1, 2, 5)
    df.PELPS$V1 = NULL
    return(df.PELPS)    
}


# Add products, country and regions names #
addProductAndCountry = function(df){
    # Extract region and Product codes from code
    df$Country_Code = substr(df$Code, 1, 2)
    df$Product_Code = substr(df$Code, 3, 4)
    
    # Add region and Product names
    n = nrow(df)
    df = merge(countryCodes[c("Country_Code","Country", "GFPM_REG")], #, "EU27", "Summary")],
                   df, by = "Country_Code", all.y=TRUE)
    df = merge(productCodes[c("Product_Code","Product")],
                   df, by = "Product_Code", all.y=TRUE)
    
    # Remove code column
    df$Code = NULL
    # Check if we lost data in the merge
    stopifnot(nrow(df)==n)
    return(df)
}



# Aggregate by GFPM regions #
aggregateByGFPMRegions = function(otpt){
    # Remove price from aggregate
    output2 = otpt[otpt$Element!="DPrice",]
    
    # Add info about the dummy region
    output2$GFPM_REG[output2$Country_Code=="zy"] = "Dummy Region xy"
    
    # Aggregate Long
    outputagg = aggregate(output2["Volume"],
                          output2[c("Product", "Element", "GFPM_REG", "Period")], sum)
    
    # Calculate net trade
    imp = subset(outputagg, Element=="Import")
    exp = subset(outputagg, Element=="Export")
    netTrade = merge(imp, exp, by=c("Product", "GFPM_REG", "Period"), 
                     suffixes = c(".Import",".Export"), all=TRUE)
    netTrade$Element = "NetTrade"
    
    # Remove NA values
    netTrade[is.na(netTrade)] = 0
    netTrade$Volume = netTrade$Volume.Export - netTrade$Volume.Import
    
    # Remove unused columns
    netTrade = subset(netTrade, select=c("Product", "Element", "GFPM_REG", "Period", "Volume" ))
    
    # Add to aggregate
    outputagg = rbind(outputagg, netTrade)
    return(outputagg)
}


#########
# Clean # 
#########
# calls functions defined above
# - Input loads a PELPS data frame from the file "scenario_name" for a scenario
# - Ouput is a list of tables for that scenario
clean = function(fileName, scenario_name, path="rawdata/"){
    load(paste(path, fileName, sep=""))
    P = splittrade(PELPS)
    demand = reshapeLong(P$demand, "Demand")
    dPrice = reshapeLong(P$demandprice, "DPrice")
    export = reshapeLong(P$export, "Export")
    import = reshapeLong(P$import, "Import")
    production = reshapeLong(P$production, "Production")
    supply = reshapeLong(P$supply, "Supply")
    
    # Combine all elements in one table
    output = rbind(demand, dPrice, export, import, production, supply)
    
    # Add products and country names
    output = addProductAndCountry(output)
    
    # Calculate aggregates
    agg = aggregateByGFPMRegions(output)
    
    # Extract World price
    wp = reshapeLong(P$worldPrice, "World_Price")
    wp = addProductAndCountry(wp)
    wp$World_Price = wp$Volume
    wp = wp[,c("Product_Code", "Product", "Period", "World_Price")]
    
    # Add scenario name to the output, aggregate and price tables
    output$Scenario = scenario_name
    agg$Scenario = scenario_name
    wp$Scenario = scenario_name
    # print(names(output))
    
    # Put data.frames in a list
    GFPMoutput = list(scenario = data.frame(scenario_name, fileName), 
                      entity = output, aggregates = agg, worldPrices = wp)
    return(GFPMoutput)
}


############################################################
# # Bind scenarios together and save an alternative output #
############################################################
# The output above is fine for analysing scenarios one by one
# It turns out that I prefer to have all scenarios in one data frame
# Its practical when comparing scenarios
bindScenarios = function(dtf1,dtf2){
    list(scenario = rbind(dtf1$scenario, dtf2$scenario),
         entity = rbind(dtf1$entity, dtf2$entity),
         aggregates = rbind(dtf1$aggregates,dtf2$aggregates), 
         worldPrices = rbind(dtf1$worldPrices, dtf2$worldPrices))
}

#################################
# Save scenarios alone as RDATA #
#################################
# Save scenarios alone
# baseScenario = clean("PELPS 105Base", "Base")
# highScenario = clean("PELPS 105 TFTA High Scenario revision 1", "HighTTIP")
# lowScenario = clean("PELPS 105 TFTA Low scenario revision 1", "LowTTIP")
# save(baseScenario, highScenario, lowScenario, countryCodes,
#      file="enddata/GFPM_Output.rdata")


##############################################################
# Load, clean and save GFPM scenarios to the end data folder #
##############################################################
clean_main_scenarios = function() {
    message("Cleaning main PELPS data for scenarios ...")
    baseScenario = clean(fileName = "PELPS 105Base.RDATA", scenario_name = "Base")
    highScenario = clean("PELPS 105 TFTA High Scenario revision 1.RDATA", "HighTTIP")
    lowScenario = clean("PELPS 105 TFTA Low scenario revision 1.RDATA", "LowTTIP")
    
    # Combine TTIP scenarios
    allScenarios = bindScenarios(baseScenario, highScenario)
    allScenarios = bindScenarios(allScenarios, lowScenario)
    
    # Save the list of combined scenarios in a RDATA object
    save(allScenarios, file="enddata/GFPM_Output_TTIP.RDATA")
    
    # Add sensitivity scenarios
    baselowelast = clean("World105LowGDPelast.RDATA", "BaseLowElast")
    basehighelast = clean("World105NoTTIPHighGDPelast.RDATA", "BaseHighElast")
    allScenarios = bindScenarios(allScenarios, baselowelast)
    allScenarios = bindScenarios(allScenarios, basehighelast)
    
    # Add base2011 scenario from a simulation with Ahmed on October 2014
    base2011 = clean("PELPS October 2014 Ahmed.RDATA", "Base2011")
    
    #  Save all scenarios
    message(paste("*",unique(allScenarios$entity$Scenario),"*"))
    save(allScenarios, file="enddata/GFPM_Output_TTIP_with_sensitivity.RDATA")
    
    # Save training dataset with only base scenario and sensitivity scenario
    trainingScenarios = bindScenarios(baseScenario, baselowelast)
    trainingScenarios = bindScenarios(trainingScenarios, basehighelast)
    trainingScenarios = bindScenarios(trainingScenarios, base2011)
    save(trainingScenarios, file="enddata/GFPM_training_scenarios.RDATA")
}

if (FALSE){
    clean_main_scenarios()
}
