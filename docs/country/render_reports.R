library(dplyr)
library(knitr)

# Thanks to agstudy I found a quick solution to replace spaces in country names
# so that they can be used as file names
# http://stackoverflow.com/questions/13985215/replace-special-characters-along-with-the-space-in-list-of-strings

#' Saves data as a csv file 
#' 
#' Export data tables containing demand, production and trade scenarios
#' for the GFPM products, for on country or a group of countries
#' @param countries, a vector of countries
#' 
export2csv <- function(countries){
    
}


#' Create reports based on the markdown report template
#' 
#' create report with the render function from the rmarkdown package
#' @country a vector of country names
createreport <- function(countries, outputdir, 
                         inputpath = "docs/country", template = "report.Rmd"){
    for (country in countries){
        tryCatch(render(input = file.path(inputpath, template), 
                        output_format = pdf_document(),
                        output_dir = outputdir,
                        output_file = paste0(gsub('([[:punct:]])|\\s+','_',country),".pdf")), 
                 finally= print("Finally"))
    }
}


if(FALSE){
    # Load gfpm scenarios and historical data
    load("enddata/GFPM_training_scenarios_with_historical.RDATA")
    # Load country names countrycodes should be part of the package namespace
    eu27countries <- GFPMoutput::countrycodes$Country[GFPMoutput::countrycodes$EU27]
    # one country only
    country = "United Kingdom"
    createreport(country, outputdir="reportsbase20102011")
    # create reports for all scenarios for all eu27 countries
    createreport(eu27countries, outputdir="reportsbase20102011")

    
    ######################################################## #
    # Select only the base2011 scenario and historical data  #
    ######################################################## #
    gfpm <- gfpm %>% 
        filter(Scenario %in% c("Base2011","Historical"))    


    # Export data for the UK only #
    country = "United Kingdom"
    write.csv(filter(gfpm, Country==country),
              row.names = FALSE,
              file = paste0("enddata/country/", country,".csv"))
    # Use rmarkdwon to generate a report based on the template
    render("docs/country/report.Rmd", pdf_document(), output_dir="reportsbase2011")
    render("docs/country/report.Rmd", "word_document", output_dir="reportsbase2011")
    # Use a function 
    createreport(country, outputdir="reportsbase2011")


    # Export data for EU27 countries
    for (country in eu27countries){
        write.csv(filter(gfpm, Country==country),
                  row.names = FALSE,
                  file = paste0("enddata/country/", country,".csv"))
    }
    # Create reports for eu27 countries, this time with only one base year scenario
    createreport(eu27countries, outputdir="reportsbase2011")


    # Export data for all gfpm countries
    write.csv(gfpm,
              row.names = FALSE,
              file = "enddata/country/gfpmbase2011.csv")    
    zip("enddata/country/gfpmbase2011.zip",
        files=c("enddata/country/gfpmbase2011.csv"))
    file.remove("enddata/country/gfpmbase2011.csv")
    
    
    # Use functions
    gfpm %>% export2csv("United Kingdom")
    gfpm %>% export2csv(europeancountries)
    gfpm %>% export2csv(othercountries)


    # Compare 2 base scenarios
    
}


