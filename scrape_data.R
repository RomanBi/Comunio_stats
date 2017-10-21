

#data is retrieved from the following URL: http://www.comstats.de/squad/

#https://rud.is/b/2017/09/19/pirating-web-content-responsibly-with-r/
#http://uc-r.github.io/scraping


#It consists of information regarding ...

packages_needed <- c("tidyverse", "V8", "stringi", "httr", "rvest", "robotstxt", "hrbrthemes", "purrrlyr", "rprojroot")

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
data_clubs <- list()
list_enumerator <- 1

for (i in clubs) {
      data_clubs[list_enumerator] <- paste0(baseurl, i) %>% 
            read_html() %>% 
            #html_node(xpath = '//*[@id="inhalt"]/table[2]') %>% 
            html_node("#inhalt > table.rangliste.autoColor.tablesorter.zoomable") %>%
            #html_node(xpath = '//*[@id="inhalt"]/table[2]/tbody[1]/tr[1]/td[1]') %>%
            html_table(header = TRUE, fill = TRUE)
      
      list_enumerator <- list_enumerator + 1
}

# works, but table is looking bad...


# different page ToDo:
read_html("http://www.com-analytics.de/topplayers") %>% 
      html_node("#inhalt > table.rangliste.autoColor.tablesorter.zoomable") %>%
      html_table(header = TRUE, fill = TRUE)

