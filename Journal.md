\name{Journal}
\alias{Journal}

\title{CEF Journal}

## CEF Project Journal

### Questions
**Premium/Discounts (PD):** Since the foundation of this research depends upon the ability to identify PD that will shrink, we need to examine the distribution of PD.  Do premiums/discounts mean revert?   How fast?  Are they independent or do they move together as a group?  If they move together as a group, does the PD of a single CEF out of synch tend to shrink more quickly.  Also, I'd like to avoid look ahead bias when figuring out reversion.

**Borrowing Costs:**  Is there a relationship between the borrowing cost and the PD?  It could also be related to liquidity / market cap.  There may be other variables namely liquidity, volume and yield.  However, the main question is whether the borrowing cost and the PD are related because if we can't borrow at a reasonable price, we won't be able to take advantage of PD.
Perhaps the lending incomeis related to the borrowing rate.  If so, that may help for our long positions.


### Next Steps
Address questions.
Can we screen scrape liquidity, volume? 

### Log
July 4, 2018 Setup project.    
July 2018 - Have a universe of CEFs, mainly muni bond.  Have found NAV by pre-pending and appending "X" to the symbols.    
Aug 2018 - Found estimates of borrowing costs from Interactive Brokers.  So far this is manual. There may be a facility through an API.     
Aug 6, 2018 - (RM) Added an articles folder for academic/industry research. Also, proposed: We need to be explicit and in agreement about certain series and calculations for the CEFs. We need (unadjusted) close / (unadjusted) nav to calculate the premium / discount.  The premium/discount should not use adjusted values (maybe it won’t matter).   We need the adjusted market to calculate market returns to include dividends and split.  So we need 3 series for a fund: close.mkt, close.adj, and close.nav.  There’s a fourth available (adjusted.nav) but I don’t see a use for this.  Of course, we may decide we want the open as well in case we want to simulate trading at the open the following day.    
Aug 7, 2018 - (RPM) Played around creading pd.rmd to look at tendency of premiums and discounts to shrink.
