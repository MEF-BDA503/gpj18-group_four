
library(shiny)
library(tidyverse)
library(dplyr)
library(readxl)
library(leaflet)
library(reshape2)
library(ggplot2)


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



export_Product_Group <- export_jTableMELTED%>%
group_by(Country,PcodeTwo,X__2,Unit,year)%>%
summarize(Quantity = sum(Quantity), Values = sum(Values))%>%
rename(Product_Group_Code =PcodeTwo, Product_Group_Name = X__2,Export_Quantity = Quantity,Export_Value =Values)

import_Product_Group <- import_jTableMELTED%>%
group_by(Country,PcodeTwo,X__2,Unit,year)%>%
summarize(Quantity = sum(Quantity), Values = sum(Values))%>%
rename(Product_Group_Code =PcodeTwo, Product_Group_Name = X__2,Import_Quantity = Quantity,Import_Value =Values)

Export_Import_JTable <- export_Product_Group %>%
  full_join(import_Product_Group,by=c("Country","Product_Group_Code","Product_Group_Name","year")) %>%
mutate(Unit= coalesce(Unit.x,Unit.y),Import_Quantity = replace(Import_Quantity, is.na(Import_Quantity),0),
        Export_Quantity = replace(Export_Quantity, is.na(Export_Quantity),0))%>%
select(Country,Product_Group_Code,Product_Group_Name,Unit,year,Export_Quantity,Import_Quantity,Export_Value,Import_Value)

Net_Value_By_Country <- Export_Import_JTable %>%
group_by(Country,year)%>%
summarize (Export_Value = sum(Export_Value), Import_Value = sum(Import_Value), Net_Value = sum(Export_Value - Import_Value)) 

# Total Export Value fiiled with Country on the basis of Year #
ggplot(Net_Value_By_Country, aes(x=year, y=Export_Value)) + 
  geom_bar(stat='identity', aes(fill=Country), width=.6,position = position_stack(reverse = TRUE))  +
  labs(subtitle="## Total Export Value fiiled with Country on the basis of Year ##", title= "Total Export Values") + 
  coord_flip()+
  theme(legend.position = "top")

# Total Import Value fiiled with Country on the basis of Year #
ggplot(Net_Value_By_Country, aes(x=year, y=Import_Value)) + 
  geom_bar(stat='identity', aes(fill=Country), width=.6,position = position_stack(reverse = TRUE))  +
  labs(subtitle="## Total Import Value fiiled with Country on the basis of Year ##", title= "Total Import Values") + 
  coord_flip()+
  theme(legend.position = "top")

# Total Net Value fiiled with Country on the basis of Year #
ggplot(Net_Value_By_Country, aes(x=year, y=Net_Value)) + 
  geom_bar(stat='identity', aes(fill=Country), width=.6,position = position_stack(reverse = TRUE))  +
  labs(subtitle="## Total Net Value fiiled with Country on the basis of Year ##", title= "Total Net Values") + 
  coord_flip()+
  theme(legend.position = "top")

#Normalized Export Value
Normalized_Values_By_Country <- Export_Import_JTable %>%
  filter (year == 2017)%>%
  group_by(Country)%>%
  summarize (Export_Value = sum(Export_Value), Import_Value = sum(Import_Value), Net_Value = sum(Export_Value - Import_Value))%>%
  mutate(normalized_value =  round((Export_Value  - mean(Export_Value))/sd(Export_Value ), 2)) %>%
  mutate(value_type =  ifelse(normalized_value < 0, "below", "above"))


ggplot(Normalized_Values_By_Country, aes(x=Country, y=normalized_value, label=normalized_value)) + 
  geom_bar(stat='identity', aes(fill=value_type), width=.5)  +
  scale_fill_manual(name="Normalised Value", 
                    labels = c("Above Average", "Below Average"), 
                    values = c("above"="seagreen1", "below"="Red")) +  
  labs(subtitle="Normalised Export Value for 2017 by Country'", 
       title= "Diverging Bars") + 
  coord_flip()



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


