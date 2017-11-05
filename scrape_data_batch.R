
#exit immediately if today´s data has already been scraped
if (!file.exists(paste0("data/data_timeseries_", Sys.Date(), ".RData"))) 
{
     
      packages_needed <- c("rvest", "dplyr", "tidyr", "htmltab")
      
      for (i in packages_needed) {
            #  require returns TRUE invisibly if it was able to load package
            if (!require(i, character.only = TRUE)) {
                  #  If package was not able to be loaded then install
                  install.packages(i, dependencies = TRUE)
                  #  Load package after installing
                  library(i, character.only = TRUE)
            }
      }
      
      baseurl <- "http://www.comstats.de"
      
      clubs <- paste0(baseurl, "/squad") %>% 
            read_html() %>% 
            html_nodes(xpath = '//td[contains(@class, "clubPics")]//a') %>%
            html_attr("href")
      
      data_timeseries_new <- data.frame()
      
      for (i in clubs) {
            data_clubs <- htmltab(doc = paste0(baseurl, i), which = '//*[@id="inhalt"]/table[2]')
            data_clubs$club <- i
            
            data_timeseries_new <- bind_rows(data_timeseries_new, data_clubs)
      }
      
      #format and clean table
      Encoding(data_timeseries_new[,1]) <- "UTF-8"
      
      data_timeseries_new$Verein <- gsub(".*-", "", data_timeseries_new$club)
      data_timeseries_new$Verein <- gsub("\\+", " ", data_timeseries_new$Verein)
      
      data_timeseries_new$Punkte <- as.numeric(data_timeseries_new$Pkt.)
      data_timeseries_new$Marktwert <- as.numeric(gsub("\\.", "", data_timeseries_new$Marktwert))
      
      #add date
      data_timeseries_new$Datum <- Sys.Date()
      
      
      #add new data to timeseries
      load(file = "data/data_timeseries.RData")
      
      if (!unique(data_timeseries_new$Datum) %in% data_timeseries$Datum) {
            
            data_timeseries <- data_timeseries %>% rbind(select(data_timeseries_new, -Pkt., -club)) %>% 
                  arrange(Verein, Spieler, Datum)

            save(data_timeseries, file = "data/data_timeseries.RData")
            
            #create backup
            save(data_timeseries, file = paste0("data/data_timeseries_", Sys.Date(), ".RData"))
      }
      
}









