library(rvest, quietly = TRUE)

extractvalue <- function(data){
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
    out$ticker <- trimws(extractvalue(html_nodes(webpage, "#lblTicker")))
    out$prem_disc <- removelastchar(extractvalue(html_nodes(webpage, "#lblPremDisc")))
    out$inception_date <- as.Date(extractvalue(html_nodes(webpage, "#lblInceptionDate")),"%m/%d/%Y")
    out$leverage <- removelastchar(extractvalue(html_nodes(webpage, "#lblPercentLevAssets")))
    out$expense_ratio <- removelastchar(extractvalue(html_nodes(webpage, "#lblExpenceRatio")))
    out$turnover <- removelastchar(extractvalue(html_nodes(webpage, "#PortfolioTurnover")))
    out$dist_yld <- removelastchar(extractvalue(html_nodes(webpage, "#lblDisYield")))
    out$asset_class <- trimws(extractvalue(html_nodes(webpage, "#lblAssetClass")))
    out$exchange <- trimws(extractvalue(html_nodes(webpage, "#lblExchange")))
    out$total_net_assets <- extractvalue(html_nodes(webpage, "#lblTotalNetAssets"))
    out$description <- trimws(extractvalue(html_nodes(webpage, "#lblDescription")))
    return(out)
}

# Examples
# cefid <- "74590"
# scrapeCEFA(cefid)

# cefid <- "81381"
# scrapeCEFA(cefid)
