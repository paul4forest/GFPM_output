# Functions to visualise and prepare data tables from GFPM data
#
# Authors: Paul Rougieux and Ahmed Barkaoui
# EFI - Observatory for European Forests
# INRA - Laboratoire d'Economie Forestière
#
library(ggplot2)



############################################## #
# import GFPM output data from c:\PELPS\PELPS #
############################################## #
# Copy PELPS Folder this function is not needed
# # copy_pelps_folder <- function()
# scenario_name <- "june2014"
# file_name <- "DEMAND.DAT"
# 
# # The problem is that I cannot write in zip files.
# # con = unz(paste("rawdata/", scenario_name, ".zip", sep=""),
# #             + paste(scenario_name, "/", file_name, sep=""))
# # cat("blibli", file = con)
# #  " unz connections can only be opened for reading "
# 
# con = bzfile(paste0("rawdata/", scenario_name, ".bz"))
# cat("blibli", file = con)
# 
# # Tar compression works, 
tar("rawdata/June2014.tar.bz2", "rawdata/PELPS 105 TFTA High Scenario revision 1",
     compression ="bzip2")
# Create a connection to extract from the created file
con = bzfile("rawdata/June2014.tar.bz2", open="rb" )
# untar(con, list=TRUE) # list files in the archive
# Extract DEMAND.DAT to a folder
untar(con, files="rawdata/PELPS 105 TFTA High Scenario revision 1/DEMAND.DAT", 
      exdir = "rawdata/June2014/")

# Archive the PELPS folder directly
scenario_name <- "July2014"
pelps_folder <- "C:/PELPS/pelps/"
project_dir <- getwd()

message("Copy and archive ", pelps_folder, " in ", project_dir,"/rawdata/...")
setwd(dirname(pelps_folder)) # Move one level up with dirname()
tryCatch(tar(paste0(project_dir,"/rawdata/",scenario_name,".tar.bz2"), "pelps",
             compression ="bzip2"), 
         finally= setwd(project_dir))

# Now read from this archive
temp_dir <- file.path(dirname(tempdir()), basename(tempdir()), scenario_name)
con = bzfile(paste0("rawdata/",scenario_name,".tar.bz2"), open="rb" )
# untar(con, list=TRUE) # list files in the archive
untar(con, files="pelps/DEMAND.DAT", exdir = temp_dir)
list.files(temp_dir, recursive=TRUE)
# Read DEMAND.DAT into a data.frame
dtf2 = read.table(file.path(temp_dir,"pelps/DEMAND.DAT"),
                  header = FALSE, as.is=TRUE)


# Another test

tar("rawdata/July2014.tar.bz2", "C:/PELPS/pelps/", compression ="bzip2")
# Extract to a temporary folder
# Convert the tempdir() path to a UNIX format
temp_dir <- file.path(dirname(tempdir()), basename(tempdir()))
con = bzfile("rawdata/July2014.tar.bz2", open="rb" )
# untar(con, list=TRUE) # list files in the archive
untar(con, files="rawdata/PELPS 105 TFTA High Scenario revision 1/DEMAND.DAT", 
      exdir = temp_dir)
list.files(temp_dir)
# Read DEMAND.DAT into a data.frame
dtf2 = read.table(file.path(temp_dir,"rawdata/PELPS 105 TFTA High Scenario revision 1/DEMAND.DAT"),
                  header = FALSE, as.is=TRUE)

# second tar.bz2 file to be extracted directly where it existed
tar("rawdata/June2014_2.tar.bz2", "rawdata/PELPS 105 TFTA High Scenario revision 1 - Copy - to delete",
    compression ="bzip2")
con = bzfile("rawdata/June2014_2.tar.bz2", open="rb" )
#  untar(con, list=TRUE) 
untar(con, files="rawdata/PELPS 105 TFTA High Scenario revision 1 - Copy - to delete/DEMAND.DAT")
con = bzfile("rawdata/June2014_2.tar.bz2", open="rb" )
untar(con, files="rawdata/PELPS 105 TFTA High Scenario revision 1 - Copy - to delete/PRODOUT.DAT")

#       files="June2014.tar/rawdata/PELPS 105 TFTA High Scenario revision 1/DEMAND.DAT",
#       exdir="rawdata/June2014")
# dtf = read.table(untar(con, files="DEMAND.DAT"), header = FALSE, as.is=TRUE)
# 
# 
# # This function can only be used after load.R and clean.R have been sourced
# convert_gfpm_data <- function(scenario_name, pelps_folder = "C:/PELPS/pelps/"){
# # move and rename the pelps folder   
# #     1. Rename the folder "C:\PELPS\PELPS" to a name of your choice.
# #     For example "my_scenario_name". 
#     
# #     2. Copy the renamed PELPS folder to the \rawdata folder.
# #     Optionally, you can compress this PELPS folder as a zip file: "my_scenario_name.zip"
# #     and copy it to the rawdata folder.
# #     3. Load raw data into R data frames
#     savePELPSToRdata("my_scenario_name", "zip")
#     # Maybe add a time stamp, up to the second to the long scenario name
#     clean(scenario_name, scenario_name)
# }
# 

############################### #
# Plot Summary by GFPM regions  #
############################### #
plotProdByReg = function(product="", scenario=""){
    dtf = subset(allScenarios$aggregates, Product==product & Scenario==scenario)
    # Plot elements on the same graph using a facet
    p = ggplot(data=dtf) +
        aes(x=Period, y=Volume, colour=GFPM_REG, label = GFPM_REG) +
        geom_line() + 
        #     geom_text(data=GFPMoutput$aggregates) +
        theme(legend.position = "bottom") +
        facet_wrap(~ Element ) 
    print(p)
}




#######################################################
# If this script is run as stand alone (not imported) #
#######################################################
if(FALSE){ 
    load("enddata/GFPM_Output_TTIP.RDATA")
    plotProdByReg("Sawnwood", "Base")
    plotProdByReg("IndRound", "Base")
}
