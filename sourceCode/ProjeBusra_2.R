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



unit_price_import <- import_jTableMELTED %>% select(Country,Product_Label, X__2 ,Product_Label, Product_Label, Unit, Quantity, year, Values) %>% 
  mutate(Unit_Price = Values/Quantity)
unit_price_export <- export_jTableMELTED %>% select(Country,Product_Label, X__2 ,Product_Label, Product_Label, Unit, Quantity, year, Values) %>% 
  mutate(Unit_Price = Values/Quantity)

unit_price_import <- unit_price_import %>% mutate(type="Import") 
unit_price_export <- unit_price_export %>% mutate(type="Export")

joint_table <- unit_price_export %>% select(Country,Product_Label,year,Export_Unit_Price=Unit_Price) %>% 
  full_join(unit_price_import, by =c("Country","Product_Label","year")) %>% select(Country,Product_Label,year,Export_Unit_Price,Import_Unit_Price=Unit_Price) %>%
  mutate(Ratio=Import_Unit_Price/Export_Unit_Price)
melted_data <- joint_table %>% melt(id=c("Country","Product_Label","year","Ratio")) %>% rename("type"=variable)

Country <- 
  melted_data %>% 
  distinct(Country) %>% 
  unlist(.)

names(Country) <- NULL

Product_Label <- 
  melted_data %>% 
  distinct(Product_Label) %>% 
  unlist(.)

names(Product_Label) <- NULL


# Set randomness seed
set.seed(61)


# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Unit Price Statistics"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      sliderInput("Ratio",
                  "Ratio (Import Unit Price/Export Unit Price",
                  min = 1,
                  max = 50,
                  step = 0.25,
                  value = 1),
      selectInput(inputId ="year",label = "Year:",choices = c(2013, 2014, 2015, 2016, 2017)),
      selectInput(inputId = "Country", label = "Countries:",choices = c(Country))
      
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
    modified_data <- melted_data
    print(input$Country)
    
    
    #if(input$Country[1] != "" ){
    modified_data <- modified_data%>% filter(Country ==input$Country)
    
    #}
    
    modified_data <- modified_data %>% filter(year==input$year )
    modified_data <- modified_data %>% filter(Ratio>=input$Ratio )
    
    
    p1 <-
      ggplot(modified_data, aes(x=Product_Label, y=value, fill=type)) +
      geom_bar(stat='identity', position=position_dodge())
    p1
    
    
    
  })
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)

