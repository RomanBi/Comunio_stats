
#exit immediately if today´s data has already been scraped
if (!file.exists(paste0("data/data_timeseries_", Sys.Date(), ".RData"))) 
{
     
      packages_needed <- c("rvest", "dplyr", "htmltab")
      
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
      
      list_enumerator <- 1
      data_timeseries_new <- data.frame()
      
      for (i in clubs) {
            data_clubs <- htmltab(doc = paste0(baseurl, i), which = '//*[@id="inhalt"]/table[2]')
            data_clubs$club <- i
            
            data_timeseries_new <- bind_rows(data_timeseries_new, data_clubs)
            
            list_enumerator <- list_enumerator + 1
      }
      
      #format and clean table
      Encoding(data_timeseries_new[,1]) <- "UTF-8"
      data_timeseries_new$club <- gsub("[[:digit:]]|[[:punct:]]|squad", "", data_timeseries_new$club)
      
      data_timeseries_new$Pkt. <- as.numeric(data_timeseries_new$Pkt.)
      data_timeseries_new$Marktwert <- as.numeric(gsub("\\.", "", data_timeseries_new$Marktwert))
      
      #add date
      names(data_timeseries_new)[names(data_timeseries_new) == "Pkt."] <- paste0("Points.", Sys.Date())
      names(data_timeseries_new)[names(data_timeseries_new) == "Marktwert"] <- paste0("Marketvalue.", Sys.Date())
      
      #add new data to timeseries
      load(file = "data/data_timeseries.RData")
      
      
      
      if (!paste0("Points.", Sys.Date()) %in% names(data_timeseries)) {
            data_timeseries <- full_join(data_timeseries, select(data_timeseries_new, -Position), by = c("Spieler", "club"))
            
            save(data_timeseries, file = "data/data_timeseries.RData")
            
            #create backup
            save(data_timeseries, file = paste0("data/data_timeseries_", Sys.Date(), ".RData"))
      }
      
}









