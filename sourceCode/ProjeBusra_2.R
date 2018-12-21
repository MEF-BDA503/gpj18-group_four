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
melted_data <- joint_table %>% melt(id=c("Country","Product_Label","year","Ratio")) %>% rename("type"=variable) %>% 
  filter(value  >0 & Ratio >0 & Ratio !=Inf & Ratio <=1000 & value <=10000)  

melted_data <- melted_data %>% mutate(Bins=0)
melted_data$Bins <- cut(melted_data$Ratio, breaks=c(1,10,20,30,40,50,60,70,80,90,100,1000), labels=c("1-10","11-20","21-30","31-40","41-50","51-60","61-70","71-80","81-90","91-100","100+"))
melted_data <- melted_data %>% filter((!is.na(Bins)))

melted_data2 <-melted_data %>% group_by(Country,Bins) %>% summarise(Count=n()) 


#p = ggplot(melted_data2, aes(x = Bins,y=Count)) 
#p=p+ geom_bar(stat='identity') +
#labs(title ="", x = "Bins", y = "Count", size = 15) + 
#geom_bar(colour = "grey19", fill = "purple") +
#facet_grid(~Country,scales = "free", ncol = 2) + 
#theme(axis.text.x = element_text(angle=45,hjust = 1, size = 8)) +
#theme(strip.text = element_text(size = 12))
#p




#ggplot(melted_data2, aes(x = Bins))+ labs(title ="", x = "Bins", y = "Count", size = 15) + 
# geom_bar(colour = "grey19", fill = "purple") +
#facet_wrap(~Country,scales = "free", ncol = 2) + 
#theme(axis.text.x = element_text(angle=45,hjust = 1, size = 8)) +
#theme(strip.text = element_text(size = 12))


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
                  value = c(1,5), sep = ""),
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
server <- function(input, output) {
  
  output$distPlot <- renderPlot({
    modified_data <- melted_data
    print(input$Country)
    
    
    #if(input$Country[1] != "" ){
    modified_data <- modified_data%>% filter(Country ==input$Country)
    
    #}
    
    modified_data <- modified_data %>% filter(year==input$year )
    modified_data <- modified_data %>% filter(Ratio>=input$Ratio[1] & Ratio <= input$Ratio[2] )
    
    
    
    p1 <-
      ggplot(modified_data, aes(x=substr(Product_Label,start=1,stop=30), y=value, fill=type)) + 
      geom_bar(stat='identity', position=position_dodge()) + 
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
    
    p1
    
    #aes(stringr::str_wrap(Product_Label, 15), value,fill=type)
    #aes(x=Product_Label, y=value, fill=type)
  })
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)

