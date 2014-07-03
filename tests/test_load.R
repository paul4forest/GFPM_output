# Test the load script
# Author Paul Rougieux, European Forest Institute

library(testthat)
library(plyr)

setwd("..")


source("code/load.r")


context("In load.r")

test_that("Extraction from zip and folder archives return the same PELPS tables", {
    demanda = readPELPSTable("PELPS 105Base", "DEMAND.DAT", scenarioFormat="zip")
    demandb = readPELPSTable("PELPS 105Base", "DEMAND.DAT", scenarioFormat="folder")
    demandc = demanda[,2:6] - demandb[,2:6]
    expect_that(sum(demandc), equals(0))     
})
