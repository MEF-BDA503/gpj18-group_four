library(shiny)
library(tidyverse)
library(dplyr)
library(readxl)
library(leaflet)
library(reshape2)


githubURL_export <- ("https://github.com/MEF-BDA503/gpj18-group_four/blob/master/export_jTable.rds?raw=true")
githubURL_import <- ("https://github.com/MEF-BDA503/gpj18-group_four/blob/master/import_jTable.rds?raw=true")
githubURL_exportMELTED <- ("https://github.com/MEF-BDA503/gpj18-group_four/blob/master/export_jTableMELTED.rds?raw=true")
githubURL_importMELTED <- ("https://github.com/MEF-BDA503/gpj18-group_four/blob/master/import_jTableMELTED.rds?raw=true")

export_jTable<- readRDS(url(githubURL_export))
import_jTable<- readRDS(url(githubURL_import))
export_jTableMELTED<- readRDS(url(githubURL_exportMELTED))
import_jTableMELTED<- readRDS(url(githubURL_importMELTED))

rm(githubURL_export)
rm(githubURL_import)
rm(githubURL_exportMELTED)
rm(githubURL_importMELTED)
print("=========")
unit_price_import <- import_jTableMELTED %>% select(Country,PcodeTwo, X__2 ,Product_Code, Product_Label, Unit, Quantity, year, Values) %>% mutate(Unit_Price = Values/Quantity)

unit_price_export <- export_jTableMELTED %>% select(Country,PcodeTwo, X__2 ,Product_Code, Product_Label, Unit, Quantity, year, Values) %>% mutate(Unit_Price = Values/Quantity)
unit_price_import$year <- as.numeric(as.character(unit_price_import$year))
print(unit_price_import)

country <- 
  import_jTableMELTED %>% 
  distinct(Country) %>% 
  unlist(.)

names(country) <- NULL

PcodeTwo <- 
  import_jTableMELTED %>% 
  distinct(PcodeTwo) %>% 
  unlist(.)

names(PcodeTwo) <- NULL

# Set randomness seed
set.seed(61)


# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Unit Price Statistics"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      sliderInput("year",
                  "Year:",
                  min = min(unit_price_import$year),
                  max = max(unit_price_import$year),
                  value = min(unit_price_import$year)),
      selectInput(inputId ="PcodeTwo",label = "Product Code",choices = c("All",PcodeTwo)),
      checkboxGroupInput(inputId = "Country", label = "Countries",choices = c("All",country))
      
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output,session) {
  
  output$distPlot <- renderPlot({
    modified_data <- unit_price_import #%>% filter(year == input$year & PcodeTwo == input$PcodeTwo)
    print(input$Country)
    if(input$Country[1] != "All"){
      modified_data <- modified_data %>% filter(Country %in% input$Country)
    }
    print(modified_data)
    p1 <-
    ggplot(modified_data, aes(x=Country, y= Unit_Price)) + geom_bar(stat="identity")
    p1
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

