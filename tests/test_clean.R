# Test the clean script
# Author Paul Rougieux, European Forest Institute

library(testthat)
library(plyr)

setwd("..")

# Source the clean script 

source("code/clean.R")



context("In clean.r")

test_that("Number of rows in each scenarios equals the number of rows in the combined list", {
    # Clean TTIP scenarios
    baseScenario = clean("PELPS 105Base.RDATA", "Base")
    highScenario = clean("PELPS 105 TFTA High Scenario revision 1.RDATA", "High")
    lowScenario = clean("PELPS 105 TFTA Low scenario revision 1.RDATA", "Low")
    
    # Combine TTIP scenarios
    allScenarios = bindScenarios(baseScenario, highScenario)
    allScenarios = bindScenarios(allScenarios, lowScenario)
    
    nbase = ldply(baseScenario, function(x) c(numberOfRows=nrow(x)))
    nhigh = ldply(highScenario, function(x) c(numberOfRows=nrow(x)))
    nlow = ldply(lowScenario, function(x) c(numberOfRows=nrow(x)))
    ntotal = ldply(allScenarios, function(x) c(numberOfRows=nrow(x)))
    expect_that(nbase[2] + nhigh[2] + nlow[2], equals( ntotal[2]))     
})


