# Read in list of CEFs from CEFList.xls
# Get summary information, prices (NAV and market), calculate daily returns and premium/discount.
# Store data 

# initializeEnvironment ---------------------------------------------------
library(lubridate)
library(readxl)
library(quantmod)
library(fundAnalysis)
library(xml2)
library(rvest)
library(tidyquant)
library(ggplot2)

# getCEFdata --------------------------------------------------------------
cef_list <- read_xlsx(paste0("./data/", "CEFList.xlsx"), sheet="FundList")
# for debugging, quick testing cef_list <- cef_list[1:3,]
cef_prices <- tq_get(cef_list$Ticker, get = "stock.prices", from = "1996-12-31") %>%
    select(c("symbol", "date", "close", "volume", "adjusted")) %>%
    filter(!is.na(adjusted)) %>%
    group_by(symbol) %>%
    tq_mutate(select = adjusted,
              mutate_fun = dailyReturn,
              leading = FALSE) %>%
    rename(return = daily.returns)
NAV_prices <- tq_get(cef_list$NAVTicker, get = "stock.prices", from = "1996-12-31") %>%
    select(c("symbol", "date", "close", "adjusted")) %>%
    filter(!is.na(adjusted)) %>%
    group_by(symbol) %>%
    tq_mutate(select = adjusted,
              mutate_fun = dailyReturn,
              leading = FALSE) %>%
    rename(return = daily.returns)
NAV_prices$Ticker <- sapply(NAV_prices$symbol, function(x) cef_list$Ticker[cef_list$NAVTicker==x])
cef_daily <- left_join(cef_prices, NAV_prices, by = c("symbol"="Ticker", "date"="date"), suffix=c(".mkt",".nav")) %>%
    group_by(symbol) %>%
    mutate(prem = 100 * (close.mkt / close.nav - 1))

# getMFdata ---------------------------------------------------------------
mf_list <- data.frame(
    Name = c("Vanguard Interm Term Tax Exempt Adm Fd", 
             "DFA Muni Bd Port Inst",
             "Vanguard Limited Term Tax Exempt Inv Sh"),
    Ticker = c("VWIUX", "DFMPX", "VMLTX"))

mf_prices <- tq_get(mf_list$Ticker, get = "stock.prices", from = "1996-12-31") %>%
    select(c("symbol", "date", "close", "adjusted")) %>%
    group_by(symbol) %>%
    na.omit

mf_daily <- mf_prices %>% 
    tq_mutate(select = adjusted,
              mutate_fun = dailyReturn,
              leading = FALSE) %>%
    rename(return = daily.returns)


# saveData ----------------------------------------------------------------
save(cef_list, cef_daily, mf_list, mf_daily, file=paste0("./data/","CEF_data.rdata"))