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
library(reshape2)
library(plotrix)


githubURL_importMELTED <- ("https://github.com/MEF-BDA503/gpj18-group_four/blob/master/import_jTableMELTED.rds?raw=true")
import_jTableMELTED<- readRDS(url(githubURL_importMELTED))
rm(githubURL_importMELTED)

import_Product_Group <- import_jTableMELTED%>%
  group_by(Country,PcodeTwo,X__2,year)%>%
  summarize( Values = sum(Values))%>%
  rename(Product_Group_Code =PcodeTwo, Product_Group_Name = X__2,Import_Value =Values)

Import_Value_by_product <- import_Product_Group %>%
  filter (Country %in% c("China","Germany","Russian"))%>%
  group_by(Country,Product_Group_Code,Product_Group_Name)%>%
  summarize (Average_Import_Value = mean(Import_Value))


Import_Value_by_product<- Import_Value_by_product %>%
  group_by(Country)%>%
  mutate(Total_Average_Import_Value = sum(Average_Import_Value))

Import_Value_by_product <- Import_Value_by_product %>%
  mutate(Average_Import_pct = round((Average_Import_Value / Total_Average_Import_Value)*100,2))%>% 
  arrange(Country,desc(Average_Import_pct))

Import_Value_by_product<- Import_Value_by_product %>%
  group_by(Country) %>% 
  mutate(Cum_Import_Pct = cumsum(Average_Import_pct)) 
  

countries <- 
  Import_Value_by_product %>% 
  distinct(Country) %>% 
  unlist(.)
names(countries) <- NULL



# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Import Anlysis with a Benchmark Rate for most "),
   
   
   sidebarLayout(
      sidebarPanel(
   
        selectInput(inputId =  "country", label = "Country:", choices = countries),                       
         sliderInput("treshold",
                     "Number of bins:",
                     min = 50,
                     max = 100,
                     step = 5,
                     value = 50)
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("distPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$distPlot <- renderPlot({

     
     
     modified_all  <- Import_Value_by_product
     
     modified_all <- modified_all %>% filter(Country==input$country) 
     
     modified_all <-modified_all %>% filter( Cum_Import_Pct <= input$treshold)
     
     
     lbls_i <- modified_all$Average_Import_pct #paste(substr(modified_all$Product_Group_Name,1,30),modified_all$Average_Import_pct) 
     #lbls_i <- paste(lbls_i,"%",sep="") 
     
     lbls <- substr(modified_all$Product_Group_Name,1,30)
     
     
     
     pie3D(modified_all$Average_Import_pct,labels= lbls_i ,main = "...", explode=0.1, radius=1.50,
           labelcex = 1.2, start=0.7) 
     #+      legend(.9, .1, lbls, cex = 0.7, fill = colors)
     color.legend(11,6,11.8,9,lbls,modified_all$Average_Import_pct,gradient="y")
     
     
        })
}

# Run the application 
shinyApp(ui = ui, server = server)

