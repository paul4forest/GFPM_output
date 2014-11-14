# Investigations for the calculation of value added
# Author Paul Rougieux
# See the script valueadded.r for more details
# 
# This script should work on the same data frame imported in valueadded.r
#
##############
# Production #
##############
# Check if I find the same values as Joseph's calculations 
#
# 1    SawnwoodProduction --> OK
# 2     PlywoodProduction --> OK
# 3   ParticleBProduction --> OK
# 4      FiberBProduction --> OK
# 5     MechPlpProduction --> OK 
# 6     ChemPlpProduction --> OK
#          Otherfibrepulp --> Not present in production volume
#                             --> OK with supply volume
#    WastePaperProduction --> Not present in production volume
#                             --> OK with supply volume
# 7   NewsprintProduction --> OK
# 8     PWPaperProduction --> OK
# 9    OthPaperProduction --> OK
# 10          OutputValue --> OK --> I find the same total values

###############
# Consumption #
###############
# "Fuelwood"--> Not in Joseph's value added calculation
# "IndRound"    "OthIndRound"  --> Maybe the 2 should be summed-up  ? 
# "OthFbrPlp"  --> OK, present in the supply
# "WastePaper" --> OK, present in the supply
# mechpulp, chempulp --> Not present in the supply, Where do I get these volumes ? 


# Products that are supplied
unique(allScenarios$entity$Product[allScenarios$entity$Element=="Supply"])
# Products that are demanded 
unique(allScenarios$entity$Product[allScenarios$entity$Element=="Demand"])
# Products that are traded
unique(allScenarios$entity$Product[allScenarios$entity$Element%in%c("Import", "Export")])

########################################
# Industrial Roundwood and othindround #
########################################
# in the high scenario
# Industrial roundwood consumption volume for France 20195 = 31458.0 +  1005.4 -  12583.9 
subset(allScenarios$entity, Country=="France" & Product=="IndRound" & Period==5 &
           Scenario=="High", select=c(Element, Volume))
subset(allScenarios$entity, Country=="France" & Product=="OthIndRound" & Period==5 &
           Scenario=="High")
31458.0 +  1005.4 -  12583.9 + 315.9
# IndROund is the sum of the 2
# Calculate Industrial roundwood Consumption


######################
# Mech and Chem pulp #
######################
# MechPulp Consumption volume for France 703.3 in the high scenario
subset(allScenarios$entity, Country=="France" & Product=="MechPlp" & Period==5 &
           Scenario=="High", select=c(Element, Volume))
504.4+198.9
# ChemPulp Consumption volume for France 2713 = 1809.9 + 1066.8 - 163.8 
chemplp = subset(allScenarios$entity, Country=="France" & Product=="ChemPlp" & Period==5 &
                     Scenario=="High")

# Change export to a negative value
chemplp$Volume[chemplp$Element=="Export"] = -chemplp$Volume[chemplp$Element=="Export"]

# Rename all Elements to consumption
chemplp$Element = "Consumption"

# Calculate consumption by Aggregating Volume for all elements
aggregate(chemplp[c("Volume")], subset(chemplp, select=-c(Volume)), sum, na.rm=TRUE)


###############
# Waste paper #
###############
subset(allScenarios$entity, Country=="France" & Product=="WastePaper" & Period==5 &
           Scenario=="High", select=c(Element, Volume))


# trying xlsx
wb = createWorkbook()

# Create a first sheet
sheet  = createSheet(wb, sheetName="NewSheet.1")
rows = createRow(sheet, rowIndex=1:2)
cells = createCell(rows, colIndex=1:8)
setCellValue(cells[[1,1]],"Text")
setCellValue(cells[[1,2]],-0.1)
setCellValue(cells[[1,3]],"=B1+1")

# Create another sheet
sheet  = createSheet(wb, sheetName="NewSheet.2")
rows = createRow(sheet, rowIndex=1:2)
cells = createCell(rows, colIndex=1:8)
setCellValue(cells[[1,1]],"Text")

# Save Excel file and show me the names of the sheets that have been created
saveWorkbook(wb, "trying out.xlsx")
names(getSheets(wb) )

