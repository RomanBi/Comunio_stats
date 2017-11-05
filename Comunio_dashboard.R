

library(shiny)
library(tidyverse)
library(dygraphs)
library(xts)
library(DT)

load(file = "data/data_timeseries.RData")

# Define UI for application that draws a histogram
ui <- fluidPage(
      
      # Application title
      titlePanel("Comunio Data Visualization"),
      
      # Sidebar with input for player marketvalues to visualize 
      sidebarLayout(
            sidebarPanel(
                  selectInput("player", "Wähle einen oder mehrere Spieler aus:", 
                              choices = unique(data_timeseries$Spieler), #ToDo: check for club/player duplicates next year
                              multiple = TRUE,
                              selected = unique(data_timeseries$Spieler)[1]) 
            ),
            
            # Show plot and table of the marketvalues
            mainPanel(
                  tabsetPanel(
                        tabPanel("Visualization", dygraphOutput("marketvalues_plot")),
                        tabPanel("Table", DT::dataTableOutput("marketvalues_table"))
                  )
                  
            )
      )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
      
      selection <- reactive({
            data_timeseries %>% 
                  filter(Spieler %in% input$player) %>% 
                  select(Datum, Spieler, Marktwert) %>% 
                  spread(Spieler, Marktwert)
      })
      
      output$marketvalues_plot <- renderDygraph({
            xts(selection()[, -1, drop = FALSE], order.by = as.POSIXct(selection()$Datum)) %>% 
                  dygraph() %>% 
                  dyOptions(maxNumberWidth = 20)
      })
      
      output$marketvalues_table <- DT::renderDataTable({
            DT::datatable(selection(), options = list(dom = 't'))
      })
}

# Run the application 
shinyApp(ui = ui, server = server)

