
#' Add new demand elasticities to the GFPM
#' 
#' @param demandelast a table of demand elasticities 
#' columns should be called "Product", "gdpelastpc" and "priceelastpc".
#' @param gfpmdemand data frame imported from a demand sheet from the GFPM's World.xls file
#' @return a dataframe containing the GFPM demand sheet with 
#' new elasticities. This can be written to a csv and then copied to excel
#' preferable on a windows machine with Excel to keep the structure
#' of World.xlsx
#' @export
adddemandelast <- function(demandelast, gfpmdemand){
    if(any(duplicated(demandelast$Product))){
        stop("Each item should appear only once in demandelast. ",
             "Some are duplicated: ",
             paste(demandelast$Product,collapse=", "), call. = FALSE)
    }
    gfpmdemand2 <- gfpmdemand %>%
        left_join(demandelast, by="Product")
    # Replace those that have a new elasticity by the new value
    gfpmdemand2 <- gfpmdemand2 %>%
        filter(!is.na(gdpelastpc)) %>%
        mutate(gdpelast = gdpelastpc,
               priceelast = priceelastpc) %>%
        # Add back those that didn't have a new elasticity
        rbind(filter(gfpmdemand2,is.na(gdpelastpc))) %>%
        arrange(Country_Code, Product_Code)
    # Did the number of rows stay the same?
    stopifnot(identical(nrow(gfpmdemand),nrow(gfpmdemand2)))
    # Did the order of rows stay the same?
    stopifnot(identical(gfpmdemand[c("Country_Code","Product_Code","basedemand")],
                        gfpmdemand2[c("Country_Code","Product_Code","basedemand")]))
    return(gfpmdemand2)
}
