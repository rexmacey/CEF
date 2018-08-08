# This should be run after getCEFdata.R is executed
# initializeEnvironment ---------------------------------------------------
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
# loadData ----------------------------------------------------------------
run_getCEFdata.R <- FALSE
if(run_getCEFdata.R) {
    source("getCEFdata.R")
} else {
    load(paste0("./data/","CEF_data.rdata"))
} 

# examineData -------------------------------------------------------------
# want to know the mean and sd of prem by fund
test <- cef_daily %>%
    filter(!is.na(prem)) %>%
    summarise(mean = mean(prem),
              median = median(prem),
              sd = sd(prem),
              num = n())
summary(test)


# Plot mean market returns
plot(cef_daily %>% 
    group_by(week = floor_date(date, "week")) %>% 
    filter(!is.na(return.mkt)) %>%
    summarise(mean = mean(return.mkt)), main = "Mean market return by week")

# plot mean premium
plot(cef_daily %>% 
    group_by(week = floor_date(date, "week")) %>% 
    filter(!is.na(prem)) %>%
    summarise(mean = mean(prem)), 
    main= "Mean premium/discount by week")


# plot for a symbol both prices and premium/discount
sym <- cef_daily$symbol[1]
plot_data <- cef_daily %>%
    filter(symbol == sym) %>% 
    filter(!is.na(prem)) %>% 
    tq_mutate(select = prem,
              mutate_fun = SMA,
              n = 200) %>%
    rename(MAprem = SMA)
plot_data$CumMean <- cummean(plot_data$prem) 
p1 <- ggplot(data = plot_data, aes(x=date, y=close.mkt)) + geom_line(aes(color="Price")) +
    geom_line(aes(y=close.nav, color="NAV")) +
    ggtitle("Price and NAV") + xlab("Date") + ylab("Value") + 
    scale_color_manual(name="", values = c("Price" = "blue", "NAV" = "red")) + 
    theme(legend.position = "top")

p2 <- ggplot(data = plot_data, aes(x=date, y=prem)) + geom_line(aes(color="Prem/Disc")) +
    geom_line(aes(y=CumMean, color="CumMean")) +
    geom_line(aes(y=MAprem, color="MA200")) +
    ggtitle("Premium/Discount") + xlab("Date") + ylab("Value") +
    scale_color_manual(name = "",
                       values = c("Prem/Disc" = "blue", "CumMean" = "red", "MA200" = "green")) + 
    theme(legend.position = "top")

grid.arrange(p1, p2, nrow=2)

# plot scatter of market and NAV return
sym <- cef_list$Ticker[3]
plot_data <- cef_daily %>%
    filter(symbol == sym) %>%
    filter(!is.na(return.mkt)) %>%
    filter(!is.na(return.nav)) %>%
    filter(abs(return.mkt) >= 0.0001)
ggplot(data = plot_data, aes(x = return.nav, y = return.mkt)) + geom_point()
cor(plot_data$return.mkt, plot_data$return.nav)
summary(plot_data[,c("return.mkt","return.nav")])
sd(plot_data$return.mkt)
sd(plot_data$return.nav)
mdl1 <- lm(return.mkt ~ return.nav, data = plot_data)
summary(mdl1)

#  correlations / lm with funds
cef_sym <- cef_list$Ticker[3]
mf_sym <- mf_list$Ticker[1]
cef <- cef_daily %>% 
    filter(symbol == cef_sym) %>%
    filter(!is.na(return.nav)) %>%
    select(symbol, date, return.nav, prem)
mf <- mf_daily %>%
    filter(symbol == mf_sym) %>%
    filter(!is.na(return)) %>%
    select(symbol, date, return)

cumret <- function(data){
    prod(1+data, na.rm = TRUE) - 1
}

comb <- inner_join(cef, mf, by = "date", suffix=c(".cef",".mf")) %>% 
    rename(return.mf = return) %>% 
    tq_mutate(mutate_fun = rollapply,
              select = c(return.nav, return.mf),
              width = 126,
              FUN = cor,
              by.column = FALSE,
              col_rename = c("ok2del1", "cor.daily", "ok2del2", "ok2del3")) %>%
    select(-starts_with("ok2del")) %>% 
    tq_mutate(select = return.nav,
              mutate_fun = rollapply,
              width = 5,
              FUN = cumret,
              by.column = FALSE,
              col_rename = "return.nav.week") %>% 
    tq_mutate(select = return.mf,
              mutate_fun = rollapply,
              width = 5,
              FUN = cumret,
              by.column = FALSE,
              col_rename = "return.mf.week") %>% 
    tq_mutate(mutate_fun = rollapply,
              select = c(return.nav.week, return.mf.week),
              width = 25,
              FUN = cor,
              by.column = FALSE,
              col_rename = c("ok2del1", "cor.week", "ok2del2", "ok2del3")) %>%
    select(-starts_with("ok2del"))

lmcust <- function(data){
    temp <- (lm(return.mf.week ~ return.nav.week, data = timetk::tk_tbl(data, silent=TRUE)))
    return(c(coef(temp), 
             summary(temp)$adj.r.squared, 
             sd(temp$residuals)*sqrt(252/5), 
             mean(abs(temp$residuals))
             ))
}
comb <- comb %>% 
    tq_mutate(select = c(return.mf.week, return.nav.week),
              mutate_fun = rollapply,
              width = 25,
              FUN = lmcust,
              by.column = FALSE,
              col_rename = c("intercept", "slope", "AdjR2", "ResidTE", "ResidMAD"))
tail(comb)

comb <- comb %>%
    mutate(pred.mf.week = lag(intercept) + lag(slope)*return.nav.week,
           err.mf.week = pred.mf.week - return.mf.week)


justweeks <- comb[seq(nrow(comb)%%5, to=nrow(comb), by=5),] %>%
    filter(!is.na(return.nav.week)) %>%
    filter(!is.na(return.mf.week)) %>%
    filter(!is.na(pred.mf.week))

temp <- justweeks %>% 
    tq_mutate(mutate_fun = rollapply,
          select = c(return.nav, return.mf),
          width = 126,
          FUN = cor,
          by.column = FALSE,
          col_rename = c("ok2del1", "cor.week2", "ok2del2", "ok2del3")) %>%
    select(-starts_with("ok2del"))

lm_daily <- lm(return.mf ~ return.nav, data=comb[comb$date>"2018-01-08",])
lm_weekly <- lm(return.mf.week ~ return.nav.week, data=justweeks[justweeks$date>"2018-01-08",])
summary(lm_daily)
summary(lm_weekly)

sd(comb$return.mf[comb$date>"2018-01-08"])
sd(comb$return.nav[comb$date>"2018-01-08"])
sd(comb$return.mf[comb$date>"2018-01-08"]) / sd(comb$return.nav[comb$date>"2018-01-08"])
sd(justweeks$return.mf.week[justweeks$date>"2018-01-08"])
sd(justweeks$return.nav.week[justweeks$date>"2018-01-08"])
sd(justweeks$return.mf.week[justweeks$date>"2018-01-08"]) / sd(justweeks$return.nav.week[justweeks$date>"2018-01-08"])

sd(test2$err.mf.week, na.rm = TRUE)*sqrt(252/5)   
mean(abs(test2$err.mf.week)-mean(test2$err.mf.week, na.rm=TRUE), na.rm = TRUE)