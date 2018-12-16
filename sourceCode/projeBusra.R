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



unit_price_import <- import_jTableMELTED %>% select(Country,Product_Label, X__2 ,Product_Label, Product_Label, Unit, Quantity, year, Values) %>% mutate(Unit_Price = Values/Quantity)
unit_price_export <- export_jTableMELTED %>% select(Country,Product_Label, X__2 ,Product_Label, Product_Label, Unit, Quantity, year, Values) %>% mutate(Unit_Price = Values/Quantity)

unit_price_import$year <- as.numeric(as.character(unit_price_import$year))
unit_price_export$year <- as.numeric(as.character(unit_price_import$year))

allMelted <- rbind(unit_price_import,unit_price_export )

print(unit_price_import)
print(unit_price_export)

country <- 
  import_jTableMELTED %>% 
  distinct(Country) %>% 
  unlist(.)

names(country) <- NULL

Product_Label <- 
  import_jTableMELTED %>% 
  distinct(Product_Label) %>% 
  unlist(.)

names(Product_Label) <- NULL

unit_price_import <- unit_price_import %>% mutate(type="Import") 
unit_price_export <- unit_price_export %>% mutate(type="Export") 
allMelted <- rbind(unit_price_import,unit_price_export )
unitDiff <- unit_price_export %>% select(Country,Product_Label, year, Unit_Price) %>% mutate(P_diff = (unit_price_export$Unit_Price)-(unit_price_import$Unit_Price))
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
      selectInput(inputId ="Product_Label",label = "Product Label",choices = c(Product_Label)),
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
    modified_data_imp <- unit_price_import
    print(input$Country)
    modified_data_exp <- unit_price_export
    print(input$Country)
    modified_data_all <- allMelted
    print(input$Country)
    
    if(input$Country[1] != "All"){
      modified_data_imp <- modified_data_imp %>% filter(Country %in% input$Country)
      modified_data_exp <- modified_data_exp %>% filter(Country %in% input$Country)
      modified_data_all <- modified_data_all %>% filter(Country %in% input$Country)
      
    }
    
    modified_data_imp <- modified_data_imp %>% filter(year==input$year )
    modified_data_exp <- modified_data_exp %>% filter(year==input$year )
    modified_data_all     <- modified_data_all %>% filter(year==input$year)
    
    
    modified_data_imp <- modified_data_imp %>% filter(Product_Label==input$Product_Label )
    modified_data_exp <- modified_data_exp %>% filter(Product_Label==input$Product_Label )
    modified_data_all <- modified_data_all  %>% filter(Product_Label==input$Product_Label)
    
    
    print(modified_data_imp)
    print(modified_data_exp)
    print(modified_data_all)
    p1 <-
    ggplot(modified_data_all , aes(x=Country, y= Unit_Price, fill=type)) + 
      geom_bar(stat="identity",position=position_dodge())+
      labs(x="Countries", y="Unit Price", title="Unit Price Analysis", fill=guide_legend(title="Trade Type"))
    
    p1
  })
  
    
}

# Run the application 
shinyApp(ui = ui, server = server)

