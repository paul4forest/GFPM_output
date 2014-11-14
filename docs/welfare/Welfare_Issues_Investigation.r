# This is an investigation script, in parallel with the welfare.r scripts, 
# where main calculations are located



########################################
# Issues with different welfare values #
########################################
# Values differ compared to Joephs' caluclations but for certain contries only
# this seems to be due to a very small difference (0.1) in the volume
#
# Example calculation of welfare for particle board consumers in Germany
# Values copied by hand from Excel
-0.5*362.8*7842.1/-0.29

# Calculation with the values form the dataframe
g = subset(wf, Country=="Germany"&Product=="ParticleB"&Scenario=="High")
c(price=g$World_Price , volume=g$Volume , elasticity=g$Elasticity) # These are the values
- 0.5 * g$World_Price * g$Volume / g$Elasticity

# The issue seems to be a 0.1 difference in the consumption volume
-0.5*362.8*7842.1/-0.29
-0.5*362.8*7842/-0.29

# Let's look at the table exported from PELPS
subset(allScenarios$entity, 
       Country=="Germany"& Product=="ParticleB"& Element=="Demand"& Scenario=="High"& Period==5, 
       select=c(1,3,9))

# This is the original PELPS data for the  High scenario: 
# Do585   7747.9   7747.6   7853.7   7897.6   7842.0
# It looks like Joseph's scenario contained a demand volume of 7842.1 for Germany in Period 5



###################################################
#### Issue with Industrial Roundwood Production ### 
###################################################
# There is an issue!

# There is no production of industrial roundwood and other industrial roundwood
subset(allScenarios$entity, Product=="IndRound"& Element=="Production")
subset(allScenarios$entity, Product=="OthIndRound"& Element=="Production")
subset(allScenarios$entity, Volume==666) # Evil press in Egypt :-) ?
# That's normal because these commodities are not actually produced, 
# They are supplied from the forest. 
# The thing is that in an earlier version, I didn't import SUPPLY.DAT in R see below for more.

# IndRound only has import and export values, no production or demand 
unique(subset(allScenarios$entity, Product=="IndRound", select=Element))
# I will later discover that I should import the supply data

# Other industrial roundwood has demand and price values
unique(subset(allScenarios$entity, Product=="OthIndRound", select=Element))

# Check values for Egypt
subset(allScenarios$entity, Product=="IndRound"&Country=="Egypt"&Period==5& Scenario=="High" )
subset(allScenarios$entity, Product=="OthIndRound"&Country=="Egypt"&Period==5& Scenario=="High"  )

# Production of industrial Roundwood = prod IndROund + prod OthIndRound
# Example for Egypt in period 5
# Table 22 Production of Total Industrial Roundwood (thousand CUM). <- 231.8
# Table 23 Production of Industrial Roundwood (thousand CUM).    <- 97.2
# Table 24 Production of Other Industrial Roundwood (thousand CUM).   <-134.6
stopifnot(231.8 == 97.2+134.6)

# In the file Output.xls For Egypt in period 5, Industrial Roundwood production = 97.2
# where is this Industrial Roundwood production of 97.2 in the PELPS data???
# In the Output.xls there is also a Other Industrial Roundwood production of 134.6 
# I can find this volume as a demand in the PELPS data
# I have the 134.6 Other Industrial Roundwood demand volume for Egypt in period 5
subset(allScenarios$entity, 
       Product=="IndRound"&Country=="Egypt"&Period==5& Scenario=="High")
# Demand = Production + Import - Export
97.2 + 331.6 - 1.5 # We should look for a 427.3 value somewhere. 
# No actually not 
# I found the value in SUPPLY.DAT !
# Sb381    134.0    124.1    115.3    106.4     97.2

# Lets try for France
subset(allScenarios$entity, 
       Product=="IndRound"&Country=="France"&Period==5& Scenario=="High")
# Table 23 Production of Industrial Roundwood (thousand CUM). (Continued)  
# 31458 
# This volume is Found also in SUPPLY.DAT, in period 5
# 
