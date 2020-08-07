library(shiny)
library(shinydashboard)
library(leaflet)
library(readxl)
library(dplyr)
library(ggplot2)
library(DT)
# Lazy Setup - this should be loaded in from another file
importdata = read_excel("demoData.xlsx", sheet = "exportedData")
ourData = data.frame(importdata)
ourData$saleRatio = signif(ourData$market / ourData$sl_price, 4)

# Define the UI
ui = dashboardPage(
  #Setup the header
  dashboardHeader(title = "Dashboard with Map"),
  #Setup the sidebar with a neighborhood selector and a submit button
  dashboardSidebar(selectInput("nbhdName", "Select a neighborhood", choices = c(ourData$nbhd_name), multiple = T),
                   actionButton("submit", "Search")
                   ),
  #Define the main content for the page, with positioning
  dashboardBody(
  #Top row of the page, containing 1 left box with our map and 1 right box that holds two value boxes (min and max sale price):
    fluidRow(
      #First box, on the left (map)
      box(
        leafletOutput("countyMap"), 
        height = 425
        ),
      #Second box, on the right (show two boxes with values of our min and max sale price)
      box(
          valueBoxOutput("minSalePrice"),
          valueBoxOutput("maxSalePrice"),
          valueBoxOutput("saleRatio"), 
          height = 425
          )
    ),
  #Bottom row of the page, containing one box with our data table 
    fluidRow(
      #Third box, on the bottom of our page, that stretches the full width (12) and displays a data table (like Excel!)
      box(
        dataTableOutput("table"),
        width = 12, height = 500
        )
    )
  )
)

#Server logic
server = function(input, output, session) {
#Render our widgets within the boxes only after the sidebar's submit button is pressed
observeEvent(input$submit, {
  req(input$nbhdName)  #Make sure we have a neighborhoodselected
  ourData = ourData %>% filter(nbhd_name %in% input$nbhdName)  #Filter data by the neighborhood name the user selects
  
  #Create the map
  output$countyMap <- renderLeaflet({
    leaflet(ourData) %>%
      addTiles() %>% 
      addCircleMarkers(color = 'black', fillColor = "black", radius = 2, lng = ~lng, lat = ~lat, label = ~geo_id)
  })
  
  #Create the min sale price box
  output$minSalePrice <- renderValueBox({
    valueBox(
      value = min(ourData$sl_price, na.rm=T),
      subtitle = "Minimum Sale Price",
      color = "green",
      icon = icon("dollar-sign", lib = "font-awesome")
    )
    })
  
  #Create the max sale price box
  output$maxSalePrice <- renderValueBox({
    valueBox(
      value = max(ourData$sl_price, na.rm=T),
      subtitle = "Maximum Sale Price",
      color = "green",
      icon = icon("dollar-sign", lib = "font-awesome")
    )
  })
  
  #Create the sale ratio box
  output$saleRatio <- renderValueBox({
    valueBox(
      value = median(ourData$saleRatio, na.rm=T),
      subtitle = "Median Sale Ratio",
      color = "aqua"
    )
  })
  
  #Create the data table 
  output$table <- DT::renderDataTable({
    DT::datatable(ourData[,c("geo_id", "nbhd_cd", "nbhd_name", "market", "sl_price", "sl_dt", "saleRatio")], 
                  extensions = 'Buttons',
                  options = list(
                  dom = 'Bfrtip',
                  buttons = c('copy', 'csv', 'excel', 'pdf', 'print')
    ))
  })
  
})
}

#Run this application!
shinyApp(ui, server)
