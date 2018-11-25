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




#PATH <-"C:/Users/avs1400/Desktop/master/DataAnEssR_503/odev"
PATH <-"C:/Users/avs1400/Documents/GitHub/gpj18-group_four/gpj18-group_four/Raw Data"

setwd(PATH)



getDataSet <- function(pPattern){
  nm <- list.files(path = PATH, pattern = pPattern)  
  if (exists("resultDataset")){
    rm("resultDataset")
  }
  for (file in nm){
    if (!exists("resultDataset")){
      resultDataset <- read_excel(file, col_names=FALSE, skip=1)
    }
    else{
      temp_dataset <-read_excel(file, col_names=FALSE, skip=1)
      resultDataset<-rbind(resultDataset, temp_dataset)
      rm(temp_dataset)
    }
    
  }
  return(resultDataset)
  
}

if (exists("import_quantity_dataset")){
  rm("import_quantity_dataset")    
}  
if (exists("import_value_dataset")){
  rm("import_value_dataset")    
}  
if (exists("import_jTable")){
  rm("import_jTable")
}
if (exists("export_quantity_dataset")){
  rm("export_quantity_dataset")    
}  
if (exists("export_value_dataset")){
  rm("export_value_dataset")    
}  
if (exists("export_jTable")){
  rm("export_jTable")
}

rm("prdCode")
file = "C:/Users/avs1400/Documents/GitHub/gpj18-group_four/gpj18-group_four/2digitproductlist.xlsx"
prdCode <- read_excel(file, col_names=FALSE, skip=1)
colnames(prdCode) <- c("Product_Code","Product_Label")
prdCode$Product_Code <- gsub("'", "", prdCode$Product_Code)

import_quantity_dataset <- getDataSet('*.mport.*uant.*')
import_value_dataset <- getDataSet('*.mport.*alu.*')
export_quantity_dataset <- getDataSet('*.xport.*uant.*')
export_value_dataset <- getDataSet('*.xport.*alu.*')

colnames(import_quantity_dataset) <- c("Country","Product_Code","Product_Label","Quantity_2013","Unit1","Quantity_2014","Unit2","Quantity_2015","Unit3","Quantity_2016","Unit4","Quantity_2017","Unit5")
colnames(import_value_dataset) <- c("Country","Product_Code","Product_Label","Value_2013","Value_2014","Value_2015","Value_2016","Value_2017")
colnames(export_quantity_dataset) <- c("Country","Product_Code","Product_Label","Quantity_2013","Unit1","Quantity_2014","Unit2","Quantity_2015","Unit3","Quantity_2016","Unit4","Quantity_2017","Unit5")
colnames(export_value_dataset) <- c("Country","Product_Code","Product_Label","Value_2013","Value_2014","Value_2015","Value_2016","Value_2017")

import_quantity_dataset$Product_Code<- gsub("'", "", import_quantity_dataset$Product_Code)
import_value_dataset$Product_Code<- gsub("'", "",import_value_dataset$Product_Code)
export_quantity_dataset$Product_Code<- gsub("'", "",export_quantity_dataset$Product_Code)
export_value_dataset$Product_Code<- gsub("'", "",export_value_dataset$Product_Code)

rm("import_jTable")
import_jTable <- import_quantity_dataset %>% 
  mutate( Unit= coalesce(Unit1,Unit2 ,Unit3 , Unit4,Unit5)) %>%
  select( Country, Product_Code , Unit, Quantity_2013, Quantity_2014,Quantity_2015,Quantity_2016,Quantity_2017) %>% 
  full_join(import_value_dataset,by = c("Country","Product_Code"))  
#import_jTable <- import_jTable %>% filter(Country!= ) 
import_jTable <- import_jTable %>% mutate(PcodeTwo=substr(Product_Code,1,2))
import_jTable <- left_join(import_jTable,prdCode,by =c("PcodeTwo"="Product_Code") )
import_jTable <- import_jTable %>% filter(Value_2013>0 | Value_2014>0 | Value_2015>0 | Value_2016>0 | Value_2017>0) 

import_jTable <- import_jTable %>% group_by(Country,Unit,PcodeTwo,Product_Label.y) %>% summarise(Quantity_2013=sum(Quantity_2013), Quantity_2014=sum(Quantity_2014), 
                                                   Quantity_2015=sum(Quantity_2015), Quantity_2016=sum(Quantity_2016), 
                                                   Quantity_2017=sum(Quantity_2017), Value_2013=sum(Value_2013), 
                                                   Value_2014=sum(Value_2014), Value_2015 = sum(Value_2015),
                                                   Value_2016=sum(Value_2016), Value_2017=sum(Value_2017))

  
export_jTable <- export_quantity_dataset %>% 
  mutate( Unit= coalesce(Unit1,Unit2 ,Unit3 , Unit4,Unit5)) %>%
  select( Country, Product_Code , Unit, Quantity_2013, Quantity_2014,Quantity_2015,Quantity_2016,Quantity_2017) %>% 
  full_join(export_value_dataset,by = c("Country","Product_Code"))  
export_jTable <- export_jTable %>% mutate(PcodeTwo=substr(Product_Code,1,2))
export_jTable <- left_join(export_jTable,prdCode,by =c("PcodeTwo"="Product_Code") )
export_jTable <- export_jTable %>% group_by(Country,Unit,PcodeTwo,Product_Label.y) %>% summarise(Quantity_2013=sum(Quantity_2013), Quantity_2014=sum(Quantity_2014), 
                                                                                        Quantity_2015=sum(Quantity_2015), Quantity_2016=sum(Quantity_2016), 
                                                                                        Quantity_2017=sum(Quantity_2017), Value_2013=sum(Value_2013), 
                                                                                        Value_2014=sum(Value_2014), Value_2015 = sum(Value_2015),
                                                                                        Value_2016=sum(Value_2016), Value_2017=sum(Value_2017))


rm("countries")
rm("products")
countries <- 
  import_jTable %>% 
  distinct(Country) %>% 
  unlist(.)
names(countries) <- NULL

products <- 
  import_jTable %>% 
  distinct(Product_Label.y) %>% 
  unlist(.)
names(products) <- NULL


rm("importValues")
rm("importQuant")
q2013<-import_jTable %>% select(Country,PcodeTwo, Product_Label.y, Quantity_2013) %>% rename("Quantity"=Quantity_2013) %>% mutate(year="2013")
q2014<-import_jTable %>% select(Country,PcodeTwo, Product_Label.y, Quantity_2014) %>% rename("Quantity"=Quantity_2014) %>% mutate(year="2014")
q2015<-import_jTable %>% select(Country,PcodeTwo, Product_Label.y, Quantity_2015) %>% rename("Quantity"=Quantity_2015) %>% mutate(year="2015")
q2016<-import_jTable %>% select(Country,PcodeTwo, Product_Label.y, Quantity_2016) %>% rename("Quantity"=Quantity_2016) %>% mutate(year="2016") 
q2017<-import_jTable %>% select(Country,PcodeTwo, Product_Label.y, Quantity_2017) %>% rename("Quantity"=Quantity_2017) %>% mutate(year="2017")

importQuant <- bind_rows(q2013,q2014,q2015,q2016,q2017)

v2013<-import_jTable %>% select(Country,PcodeTwo, Product_Label.y, Value_2013) %>% rename("Values"=Value_2013) %>% mutate(year="2013")
v2014<-import_jTable %>% select(Country,PcodeTwo, Product_Label.y, Value_2014) %>% rename("Values"=Value_2014) %>% mutate(year="2014")
v2015<-import_jTable %>% select(Country,PcodeTwo, Product_Label.y, Value_2015) %>% rename("Values"=Value_2015) %>% mutate(year="2015")
v2016<-import_jTable %>% select(Country,PcodeTwo, Product_Label.y, Value_2016) %>% rename("Values"=Value_2016) %>% mutate(year="2016") 
v2017<-import_jTable %>% select(Country,PcodeTwo, Product_Label.y, Value_2017) %>% rename("Values"=Value_2017) %>% mutate(year="2017")
rm("importValues")
importValues <- bind_rows(v2013,v2014,v2015,v2016,v2017)

#productCodeNonZero <- 
#  importValues %>% filter(Values>0) %>%
#  distinct(Product_Code,Product_Label) %>% 
#  unlist(.)
#names(productCodeNonZero) <- NULL
#rm("productCodeNonZero")
#productCodeNonZero <- 
#  import_jTable %>% filter(Value_2013>0 | Value_2014>0 | Value_2015>0 | Value_2016>0 | Value_2017>0) %>%
#  gather(key = "Product_Code",value="Product_Label") 

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Import Analysis to Turkey"),
   
   #sliderInput("years",
  #                   "Years",
  #                   min = 2013,
  #                   max = 2017,
  #                   value = c(2014,2016),sep = ""),'''   
  
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        selectInput(inputId =  "country", label = "Country:", choices = c("All", countries)),          
        selectInput(inputId =  "products", label = "Products:", choices = c("All", products)),
        sliderInput( "year", "Year:",min = 2013,max = 2017,value = 2015 )
        
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
      # generate bins based on input$bins from ui.R
      #x    <- faithful[, 2] 
      #bins <- seq(min(x), max(x), length.out = input$bins + 1)
      
      # draw the histogram with the specified number of bins
      #hist(x, breaks = bins, col = 'darkgray', border = 'white')
     
#     modified_data <- importValues %>% filter(year >= input$years[1] & year <= input$years[2] )
     modified_data <- importValues #%>% filter(year >= input$years[1] & year <= input$years[2] )     
     if(input$country != "All"){
       modified_data <- modified_data %>% filter(Country==input$country)
     }
     if(input$products != "All"){
       modified_data <- modified_data %>% filter(Product_Label.y==input$products)
     }
     
     modified_data <- modified_data %>% filter(year==input$year)
     
     ggplot(modified_data,aes(x=year,y=Values)) + geom_bar(stat = "identity")
     ggplot(modified_data,aes(x=Country,y=Values)) + geom_bar(stat = "identity")
     
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

