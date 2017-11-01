

#data is retrieved from the following URL: http://www.comstats.de/squad/

#https://rud.is/b/2017/09/19/pirating-web-content-responsibly-with-r/
#http://uc-r.github.io/scraping


#It consists of information regarding ...

packages_needed <- c("tidyverse", "V8", "stringi", "httr", "rvest", "robotstxt", "hrbrthemes", "purrrlyr", "rprojroot", "plyr")

for (i in packages_needed) {
      #  require returns TRUE invisibly if it was able to load package
      if (!require(i, character.only = TRUE)) {
            #  If package was not able to be loaded then install
            install.packages(i, dependencies = TRUE)
            #  Load package after installing
            library(i, character.only = TRUE)
      }
}


#library(jwatr) # github/hrbrmstr/jwatr

robotstxt::get_robotstxt("http://www.comstats.de/")


baseurl <- "http://www.comstats.de"

#https://stackoverflow.com/questions/38002547/web-scraping-in-r-with-loop

# For this website, get the links of Bundesliga teams
clubs <- paste0(baseurl, "/squad") %>% 
      read_html() %>% 
      # select <a> nodes that are children of club pic table,
      html_nodes(xpath = '//td[contains(@class, "clubPics")]//a') %>%
      # and get the href (link) attribute of that nodes.
      html_attr("href")


"1-FC+Bayern+München
92-RB+Leipzig
5-Borussia+Dortmund
62-1899+Hoffenheim
13-1.+FC+Köln
7-Hertha+BSC
21-SC+Freiburg
6-SV+Werder+Bremen
3-Borussia+M'gladbach
10-FC+Schalke+04
9-Eintracht+Frankfurt
8-Bayer+04+Leverkusen
68-FC+Augsburg
4-Hamburger+SV
18-1.+FSV+Mainz+05
12-VfL+Wolfsburg
14-VfB+Stuttgart
17-Hannover+96"




# Collect data
# data_clubs <- list()
# list_enumerator <- 1
# 
# for (i in clubs) {
#       data_clubs[[list_enumerator]] <- paste0(baseurl, i) %>% 
#             read_html() %>% 
#             #html_node(xpath = '//*[@id="inhalt"]/table[2]') %>% 
#             html_node("#inhalt > table.rangliste.autoColor.tablesorter.zoomable") %>%
#             #html_node(xpath = '//*[@id="inhalt"]/table[2]/tbody[1]/tr[1]/td[1]') %>%
#             html_table(header = TRUE, fill = TRUE)
#       
#       list_enumerator <- list_enumerator + 1
# }

# works, but table is looking bad...


# solution: try package htmltab (https://cran.r-project.org/web/packages/htmltab/vignettes/htmltab.html)
require(htmltab)

list_enumerator <- 1
data_timeseries <- data.frame()

for (i in clubs) {
      data_clubs <- htmltab(doc = paste0(baseurl, i), which = '//*[@id="inhalt"]/table[2]')
      data_clubs$club <- i
      
      data_timeseries <- bind_rows(data_timeseries, data_clubs)

      list_enumerator <- list_enumerator + 1
}

#format and clean table
Encoding(data_timeseries[,1]) <- "UTF-8"
data_timeseries$club <- gsub("[[:digit:]]|[[:punct:]]|squad", "", data_timeseries$club)

data_timeseries$Pkt. <- as.numeric(data_timeseries$Pkt.)
data_timeseries$Marktwert <- as.numeric(gsub("\\.", "", data_timeseries$Marktwert))

#add date
names(data_timeseries)[names(data_timeseries) == "Pkt."] <- paste0("Points.", Sys.Date())
names(data_timeseries)[names(data_timeseries) == "Marktwert"] <- paste0("Marketvalue.", Sys.Date())

#change order of variables
data_timeseries <- select(data_timeseries, club, everything())

#save to disk
save(data_timeseries, file = "data/data_timeseries.RData")



#######
# ToDo: try different page:
read_html("http://www.com-analytics.de/topplayers") %>% 
      html_node("#topplayerskeeper") %>%
      html_table()

read_html("http://www.com-analytics.de/topplayers") %>% 
      html_node("table") %>%
      .[2] %>% 
      html_table()


#https://gist.github.com/hrbrmstr/dc62bb2b35617e9badc5