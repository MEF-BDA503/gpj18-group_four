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
library(DT)
library(treemap)
githubURL_importMELTED <- ("https://github.com/MEF-BDA503/gpj18-group_four/blob/master/import_jTableMELTED.rds?raw=true")
import_jTableMELTED<- readRDS(url(githubURL_importMELTED))
rm(githubURL_importMELTED)

githubURL_exportMELTED <- ("https://github.com/MEF-BDA503/gpj18-group_four/blob/master/export_jTableMELTED.rds?raw=true")
export_jTableMELTED<- readRDS(url(githubURL_exportMELTED))
rm(githubURL_exportMELTED)


########
export_Product_Group <- export_jTableMELTED%>%
  group_by(Country,PcodeTwo,X__2,year)%>%
  summarize(Quantity = sum(Quantity), Values = sum(Values))%>%
  rename(Product_Group_Code =PcodeTwo, Product_Group_Name = X__2,Export_Value =Values)

import_Product_Group <- import_jTableMELTED%>%
  group_by(Country,PcodeTwo,X__2,year)%>%
  summarize(Values = sum(Values))%>%
  rename(Product_Group_Code =PcodeTwo, Product_Group_Name = X__2,Import_Value =Values)

Export_Import_JTable <- export_Product_Group %>%
  full_join(import_Product_Group,by=c("Country","Product_Group_Code","Product_Group_Name","year")) %>%
  select(Country,Product_Group_Code,Product_Group_Name,year,Export_Value,Import_Value)


Normalized_Values_By_Country <- Export_Import_JTable %>%
  group_by(Country)%>%
  summarize (Net_Value = mean(Export_Value - Import_Value))%>%
  mutate(normalized_Net_value =  round((Net_Value  - mean(Net_Value))/sd(Net_Value ),2)) %>%
  mutate(value_Net_type =  ifelse(normalized_Net_value < 0, "below", "above"))

Country_type <- Normalized_Values_By_Country%>%
  select( Country, value_Net_type)

import_Product_Group  <- import_Product_Group %>%
  left_join(Country_type,value_Net_type,by = "Country") 

Import_Value_by_product <- import_Product_Group %>%
  filter (value_Net_type == "below" )%>%
  group_by(Country,Product_Group_Code,Product_Group_Name)%>%
  summarize (Average_Import_Value = mean(Import_Value)) 

######


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
  arrange(desc(Country))%>%
  unlist(.)
names(countries) <- NULL



# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Import Anlysis with a Benchmark Rate for most effective Countries"),
   
   
   sidebarLayout(
      sidebarPanel(
   
        selectInput(inputId =  "country", selected = "Germany", label = "Country:", choices = countries),                       
         sliderInput("treshold",
                     "Ratio of Net Value:",
                     min = 50,
                     max = 90,
                     step = 5,
                     value = 50)
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("distPlot"),
         tabsetPanel(
           id = 'dataset',
           tabPanel("Products", DT::dataTableOutput("mytable1"))
         )
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$distPlot <- renderPlot({

     
     
     modified_all  <- Import_Value_by_product
     
     modified_all <- modified_all %>% filter(Country==input$country) 
     
     modified_all <-modified_all %>% filter( Cum_Import_Pct <= input$treshold)
     
     
     # lbls_i <- paste(paste("(P.Code=", modified_all$Product_Group_Code),modified_all$Average_Import_pct,sep=")") 
     # lbls_i <- paste(lbls_i,"%",sep=" ") 
     # 
     # lbls <- substr(modified_all$Product_Group_Name,1,30)
     # 
     # 
     # 
     # pie3D(modified_all$Average_Import_pct,labels= lbls_i ,main = "Product Distribution", explode=0.1, radius=1.50,
     #       labelcex = 1.2, start=0.7) 
     # 
     # 
     # print(modified_all$Average_Import_pct)
     

     
     treemap(modified_all,index = c("Product_Group_Name","Average_Import_pct"),vSize = "Average_Import_pct",vColor = "Average_Import_pct",title="Total Import Percentage on Countries",
             fontsize.title = 17,type="value",palette = "Set1")
     
     
     
        })
   
   output$mytable1 <- DT::renderDataTable({
     modified_all  <- Import_Value_by_product
     
     modified_all <- modified_all %>% filter(Country==input$country) 
     
     modified_all <-modified_all %>% filter( Cum_Import_Pct <= input$treshold) %>%
       select(Country,Product_Group_Code,Product_Group_Name,Average_Import_pct,Cum_Import_Pct) %>%
       arrange(desc(Average_Import_pct)) %>%
       rename("Average_Import_Percentage"=Average_Import_pct,"Cumulative_Import_Percentage"=Cum_Import_Pct)
     
     
     DT::datatable(modified_all[, , drop = FALSE])
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

