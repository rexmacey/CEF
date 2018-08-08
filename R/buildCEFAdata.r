# Build table with CEFA data
source("./R/scrapeCEFA.r")
library(lubridate)
library(readxl)
library(quantmod)
library(fundAnalysis)
library(xml2)
library(rvest)
library(tidyquant)
library(ggplot2)
library(TTR)
library(gridExtra)
run_getCEFdata.R <- FALSE
if(run_getCEFdata.R) {
    source("getCEFdata.R")
} else {
    load(paste0("./data/","CEF_data.rdata"))
}

cefa_data <- build_CEFA_data_frame(cef_list$ID)
save(cefa_data, file=paste0("./data/","CEF_data_", as.character(Sys.Date()), ".rdata"))
