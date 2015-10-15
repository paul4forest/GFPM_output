# Add FAO country names and regions to the list of GFPM country codes and names
#
setwd("Y:/Macro/GFPM/R and macros/Read PELPS")
library(FAOSTAT)

#  2.Read country codes and names 
# I create this csv file with the script below and edited it by hand
# for many countries GFPM names didn't match with the FAO name
countryCodes = read.csv("Draft/GFPM country codes 3.csv", as.is=TRUE)

FAOregions = subset(FAOregionProfile, select=c(FAOST_CODE, UNSD_MACRO_REG, UNSD_SUB_REG))
# Delete those which don't have macro region or FAO code from FAO table
FAOregions = FAOregions[!is.na(FAOregions$UNSD_MACRO_REG),]
FAOregions = FAOregions[!is.na(FAOregions$FAOST_CODE),]

# Merge with GFPM country table to see which country names match
cm = merge(countryCodes, FAOregions, all.x=TRUE, by=c("FAOST_CODE"))
cm$CountryFAO[is.na(cm$FAOST_CODE)]

createGFPMRegion = function(region, subregion){
    GFPMregion = NULL
    if (region %in%  c("Asia", "Europe", "Africa", "Oceania")){
        GFPMregion = region
    } 
    if (subregion=="South America"){
            GFPMregion = "South America" 
    }
    if (subregion%in%c("Caribbean", "Central America", "Northern America")){
            GFPMregion = "North/Central America"
    }
    return(GFPMregion)
}
# cm$GFPMRegion = createGFPMRegion(cm$UNSD_MACRO_REG, cm$UNSD_SUB_REG)
cm$GFPM_REG = mapply(createGFPMRegion, cm$UNSD_MACRO_REG, cm$UNSD_SUB_REG)

head(cm[c("Country_Code","Country","FAOST_CODE", "GFPM_REG", "EU27","Europe")])
write.csv(cm[c("Country_Code","Country","FAOST_CODE", "GFPM_REG", "EU27","Europe")],
    file="GFPM country codes 4.csv",  row.names=FALSE)


#########################################################
# Subregions in each region + Countries in GFPM regions #
#########################################################
x = split(cm,cm$UNSD_MACRO_REG)
lapply(x,function(df) return(unique(df$UNSD_SUB_REG)))

x = split(cm, cm$GFPM_REG)
lapply(x,function(df) return(c(paste("Number of ocuntries:",nrow(df)),df$CountryGFPM)))


#####################
# 1. historic stuff #
#####################
# First match GFPM country names with FAO table names
countryCodes = read.csv("GFPM country codes.csv", as.is=TRUE)

# We need the 5 macro regions
unique(FAOregionProfile$UNSD_MACRO_REG)
# And also 2 subregions present in GFPM graphs: North-Central america and South America
unique(FAOregionProfile$UNSD_SUB_REG)
FAOregions = merge(
    subset(FAOcountryProfile, select=c(FAOST_CODE,  FAO_TABLE_NAME)),
    subset(FAOregionProfile, select=c(FAOST_CODE, UNSD_MACRO_REG, UNSD_SUB_REG))
    )
FAOregions$CountryFAO = FAOregions$ABBR_FAO_NAME

# Delete those which don't have macro region or FAO code from FAO table
FAOregions = FAOregions[!is.na(FAOregions$UNSD_MACRO_REG),]
FAOregions = FAOregions[!is.na(FAOregions$FAOST_CODE),]

# Merge with GFPM country table to see which country names match
cm = merge(countryCodes, FAOregions, all.x=TRUE, by=c("FAOST_CODE"))
cm$CountryFAO[is.na(cm$FAOST_CODE)]

head(cm[c("Code","CountryGFPM","FAOST_CODE", "FAO_TABLE_NAME", "EU27","Europe")])
write.csv(cm[c("Code","CountryGFPM","FAOST_CODE", "FAO_TABLE_NAME", "EU27","Europe")],
    file="GFPM country codes 3.csv")

