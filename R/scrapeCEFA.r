library(rvest, quietly = TRUE)
library(lucr)

# In the scrapeCEFA function sometimes the data is "--" for total net assets.  This produces a near zero value.
# We may want to edit to produce NA.


extractvalue <- function(data){
    if(length(data)<1) return(NA)
    out <- as.character(data)
    startpos <- gregexpr(pattern = ">", out)[[1]][1] + 1
    endpos   <- gregexpr(pattern = "<", out)[[1]][2] - 1
    out <- substr(out, startpos, endpos)
    return(out)
}

removelastchar <- function(data){
    return(as.numeric(substr(data, 1, nchar(data) - 1)))
}

scrapeCEFA <- function(cefid){
    url <- paste0("https://www.cefa.com/FundSelector/FundDetail.fs?ID=", cefid)
    webpage <- read_html(url)
    out<-list()
    out$fund_name <- extractvalue(html_nodes(webpage, "#lblFundName"))
    if(is.na(out$fund_name)) return(out)
    out$ticker <- trimws(extractvalue(html_nodes(webpage, "#lblTicker")))
    out$prem_disc <- removelastchar(extractvalue(html_nodes(webpage, "#lblPremDisc")))
    out$inception_date <- as.Date(extractvalue(html_nodes(webpage, "#lblInceptionDate")),"%m/%d/%Y")
    out$leverage <- removelastchar(extractvalue(html_nodes(webpage, "#lblPercentLevAssets")))
    out$expense_ratio <- removelastchar(extractvalue(html_nodes(webpage, "#lblExpenceRatio")))
    out$turnover <- removelastchar(extractvalue(html_nodes(webpage, "#PortfolioTurnover")))
    out$dist_yld <- removelastchar(extractvalue(html_nodes(webpage, "#lblDisYield")))
    out$asset_class <- trimws(extractvalue(html_nodes(webpage, "#lblAssetClass")))
    out$exchange <- trimws(extractvalue(html_nodes(webpage, "#lblExchange")))
    out$total_net_assets <- lucr::from_currency(extractvalue(html_nodes(webpage, "#lblTotalNetAssets")))
    out$description <- trimws(extractvalue(html_nodes(webpage, "#lblDescription")))
    return(out)
}

# Note ID below is the CEFA.com id, not a ticker.
build_CEFA_data_frame <- function(ID_list){
    scrape_list <- lapply(ID_list, scrapeCEFA)
    return(data.frame(do.call(rbind, scrape_list)))
}

# Examples
# cefid <- "74590"
# scrapeCEFA(cefid)
# cefid <- "81381"
# scrapeCEFA(cefid)

# invalid
#cefid <- "11111"
#scrapeCEFA(cefid)