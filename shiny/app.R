#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(dplyr)
library(readxl)
library(leaflet)
library(reshape2)

#PATH <- "C:/Users//Documents/GitHub/gpj18-group_four/gpj18-group_four/"
#githubURL_export <-  paste(PATH , "export_jTable.rds", sep="")             #("https://github.com/MEF-BDA503/gpj18-group_four/blob/master/export_jTable.rds?raw=true")
#githubURL_import <- paste(PATH ,   "import_jTable.rds", sep="")              #("https://github.com/MEF-BDA503/gpj18-group_four/blob/master/import_jTable.rds?raw=true")
#githubURL_exportMELTED <- paste(PATH , "export_jTableMELTED.rds", sep="")    #("https://github.com/MEF-BDA503/gpj18-group_four/blob/master/export_jTableMELTED.rds?raw=true")
#githubURL_importMELTED <- paste(PATH , "import_jTableMELTED.rds", sep="")    #("https://github.com/MEF-BDA503/gpj18-group_four/blob/master/import_jTableMELTED.rds?raw=true")
#export_jTable<- readRDS((githubURL_export))
#import_jTable<- readRDS((githubURL_import))
#export_jTableMELTED<- readRDS((githubURL_exportMELTED))
#import_jTableMELTED<- readRDS((githubURL_importMELTED))


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

rm("countries")
rm("products")
countries <- 
  import_jTable %>% 
  distinct(Country) %>% 
  unlist(.)
names(countries) <- NULL

products <- 
  import_jTable %>% 
  distinct(X__2) %>% 
  unlist(.)
names(products) <- NULL

import_jTableMELTED <- import_jTableMELTED %>% mutate(type="Import") 
export_jTableMELTED <- export_jTableMELTED  %>% mutate(type="Export") 
allMelted <- rbind(import_jTableMELTED,export_jTableMELTED )

tableExport <- export_jTableMELTED %>% 
  group_by(Country, year) %>%
  summarise(totalExpV=sum(Values,na.rm=TRUE)) %>%
  arrange(Country, year) %>%
  mutate(ExpValChng = (totalExpV - lag(totalExpV))/lag(totalExpV)*100)


tableImport <- import_jTableMELTED %>% 
  group_by(Country, year) %>%
  summarise(totalImpV=sum(Values,na.rm=TRUE)) %>%
  arrange(Country, year) %>%
  mutate(ImpValChng = (totalImpV - lag(totalImpV))/lag(totalImpV)*100)

table <- full_join(tableExport,tableImport) %>%
  select(Country, year, Export="ExpValChng", Import = "ImpValChng") %>%
  melt(id=c("Country", "year")) %>%
  filter(year!=2013)




# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Two way trade Analysis about Turkey"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
     sidebarPanel(
       selectInput(inputId =  "country", label = "Country:", choices = c("All", countries)),          
       selectInput(inputId =  "products", label = "Products:", choices = c("All", products)),
       sliderInput( "year", "Year:",min = 2013,max = 2017,value = c(2013,2015),sep = "" )
       
     ),
     
     # Show a plot of the generated distribution
     mainPanel(
       plotOutput("distPlot"),
       plotOutput("distPlot2"),
       plotOutput("distPlot3")
     )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$distPlot <- renderPlot({
     modified_dataImp <- import_jTableMELTED
     modified_dataExp <- export_jTableMELTED
     modified_all  <- allMelted
     if(input$products != "All"){
       modified_dataImp <- modified_dataImp %>% filter(X__2==input$products)
       modified_dataExp <- modified_dataExp %>% filter(X__2==input$products)
       modified_all  <- allMelted %>% filter(X__2==input$products)      
     }
     
     modified_dataImp <- modified_dataImp %>% filter(year>=input$year[1] &  year<=input$year[2])
     modified_dataexp <- modified_dataExp %>% filter(year>=input$year[1] &  year<=input$year[2])
     modified_all     <- modified_all %>% filter(year>=input$year[1] &  year<=input$year[2])
     
     #ggplot(modified_dataImp,aes(x=Country,y=Values)) + geom_bar(stat = "identity")
     ggplot(modified_all,aes(x=Country,y=Values,fill=type))+
       geom_bar(stat="Identity", position=position_dodge())
     
        })
   
   output$distPlot2 <- renderPlot({
     modified_dataImp <- import_jTableMELTED
     modified_dataExp <- export_jTableMELTED
     modified_all  <- allMelted
     
     if(input$country != "All"){
       modified_all <- modified_all %>% filter(Country==input$country)
     }
     if(input$products != "All"){
       modified_all <- modified_all %>% filter(X__2==input$products)
     }
     
     ggplot(modified_all,aes(x=year,y=Values,fill=type)) + geom_bar(stat="Identity", position=position_dodge())
     
     
   })
   
   output$distPlot3 <- renderPlot({
     ggplot(table, aes(x=year)) +
       geom_point(aes(y=value, color=Country, shape=variable), size=4) + 
       labs(title="YoY Total Value Change",
            x="Year",
            y="% Change in  Value",
            shape=c("Trade Type"))
     
     
   })
   
}

# Run the application 
shinyApp(ui = ui, server = server)

