library(shiny)
library(tidyverse)
library(dplyr)
library(readxl)
library(leaflet)



PATH <-"D:/Courses/BIG DATA ANALYTICS/BIG DATA ESSENTIALS/Group Project"
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

import_jTable <- import_quantity_dataset %>% 
  mutate( Unit= coalesce(Unit1,Unit2 ,Unit3 , Unit4,Unit5)) %>%
  select( Country, Product_Code , Unit, Quantity_2013, Quantity_2014,Quantity_2015,Quantity_2016,Quantity_2017) %>% 
  full_join(import_value_dataset,by = c("Country","Product_Code"))  

export_jTable <- export_quantity_dataset %>% 
  mutate( Unit= coalesce(Unit1,Unit2 ,Unit3 , Unit4,Unit5)) %>%
  select( Country, Product_Code , Unit, Quantity_2013, Quantity_2014,Quantity_2015,Quantity_2016,Quantity_2017) %>% 
  full_join(export_value_dataset,by = c("Country","Product_Code"))  

countries <- 
  import_jTable %>% 
  distinct(Country) %>% 
  unlist(.)
names(countries) <- NULL

products <- 
  import_jTable %>% 
  distinct(Product_Label) %>% 
  unlist(.)
names(products) <- NULL


rm("importValues")
rm("importQuant")
q2013<-import_jTable %>% select(Country,Product_Code, Product_Label, Quantity_2013) %>% rename("Quantity"=Quantity_2013) %>% mutate(year="2013")
q2014<-import_jTable %>% select(Country,Product_Code, Product_Label, Quantity_2014) %>% rename("Quantity"=Quantity_2014) %>% mutate(year="2014")
q2015<-import_jTable %>% select(Country,Product_Code, Product_Label, Quantity_2015) %>% rename("Quantity"=Quantity_2015) %>% mutate(year="2015")
q2016<-import_jTable %>% select(Country,Product_Code, Product_Label, Quantity_2016) %>% rename("Quantity"=Quantity_2016) %>% mutate(year="2016") 
q2017<-import_jTable %>% select(Country,Product_Code, Product_Label, Quantity_2017) %>% rename("Quantity"=Quantity_2017) %>% mutate(year="2017")

importQuant <- bind_rows(q2013,q2014,q2015,q2016,q2017)

v2013<-import_jTable %>% select(Country,Product_Code, Product_Label, Value_2013) %>% rename("Values"=Value_2013) %>% mutate(year="2013")
v2014<-import_jTable %>% select(Country,Product_Code, Product_Label, Value_2014) %>% rename("Values"=Value_2014) %>% mutate(year="2014")
v2015<-import_jTable %>% select(Country,Product_Code, Product_Label, Value_2015) %>% rename("Values"=Value_2015) %>% mutate(year="2015")
v2016<-import_jTable %>% select(Country,Product_Code, Product_Label, Value_2016) %>% rename("Values"=Value_2016) %>% mutate(year="2016") 
v2017<-import_jTable %>% select(Country,Product_Code, Product_Label, Value_2017) %>% rename("Values"=Value_2017) %>% mutate(year="2017")

importValues <- bind_rows(v2013,v2014,v2015,v2016,v2017)


View(export_jTableMELTED%>%filter(year=="2013")%>%group_by(Country)%>%arrange(desc(Quantity)))
export_jTableMELTED%>%select(Country,Quantity,PcodeTwo)%>%group_by(Country,PcodeTwo)%>%arrange(desc(Quantity))
export_jTableMELTED%>%mutate(rank,rank(Quantity))%>%select(Country,Quantity,rank)

# Export Values in $ 
ttable=export_jTableMELTED%>%group_by(Country,year)%>%
  summarise(co_total=sum(Values,na.rm = TRUE))%>%
  arrange(desc(co_total,year))

#Export percentage of Countries
pex_table<-ttable%>%filter(year=='2017')%>%
  mutate(perc_count=co_total/sum((ttable%>%filter(year=='2017'))$co_total)*100)%>%
  select(Country,year,co_total,perc_count)

ggplot(pex_table, aes(x="", y=perc_count, fill=Country)) + geom_bar(stat="identity", width=1)+
  coord_polar("y") + geom_text(aes(label = round(perc_count,1), "%"), position = position_stack(vjust = 0.5))+
  labs(x = NULL, y = NULL, fill = NULL, title = "Percentage of Countries in Export in 2017")+theme_classic()+
  theme(axis.text = element_blank(),plot.title = element_text(hjust = 0.5, color = "#666666"))

ggplot(data=ttable, aes(x=Country, y=co_total,fill=year)) +
  geom_bar(stat="identity", position=position_dodge(), colour="black")+ggtitle("Total Export Values in $ to Selected Countries")

#Import Values in $
vtable=import_jTableMELTED%>%group_by(Country,year)%>%summarise(co_total=sum(Values,na.rm = TRUE))%>%arrange(desc(co_total,year))

ggplot(data=vtable, aes(x=Country, y=co_total,fill=year)) +
  geom_bar(stat="identity", position=position_dodge(), colour="black")+
  ggtitle("Total Import Values in $ to Selected Countries")

#Import percentage Values in $

pim_table<-vtable%>%filter(year=='2017')%>%
  mutate(perc_count=co_total/sum((vtable%>%filter(year=='2017'))$co_total)*100)%>%
  select(Country,year,co_total,perc_count)

ggplot(pim_table, aes(x="", y=perc_count, fill=Country)) + geom_bar(stat="identity", width=1)+
  coord_polar("y") + geom_text(aes(label = round(perc_count,1), "%"), position = position_stack(vjust = 0.5))+
  labs(x = NULL, y = NULL, fill = NULL, title = "Percentage of Countries in Import in 2017")+theme_classic()+
  theme(axis.text = element_blank(),plot.title = element_text(hjust = 0.5, color = "#666666"))


