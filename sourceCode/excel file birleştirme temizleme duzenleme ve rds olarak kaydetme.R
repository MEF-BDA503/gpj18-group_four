

library(shiny)
library(tidyverse)
library(dplyr)
library(readxl)
library(leaflet)



PATH <-"C:/Users/emrek/Google Drive/BDA/503-EssentialsOfDataAnalytics/GitHub/gpj18-group_four/Raw Data"

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

file = "C:/Users/emrek/Google Drive/BDA/503-EssentialsOfDataAnalytics/GitHub/gpj18-group_four/2digitproductlist.xlsx"
prdCode <- read_excel(file, col_names=FALSE, skip=1)
prdCode$X__1 <- gsub("'", "", prdCode$X__1)

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
import_jTable <- import_jTable %>% mutate(PcodeTwo=substr(Product_Code,1,2))
import_jTable <- left_join(import_jTable,prdCode,by =c("PcodeTwo"="X__1") )
  
export_jTable <- export_quantity_dataset %>% 
  mutate( Unit= coalesce(Unit1,Unit2 ,Unit3 , Unit4,Unit5)) %>%
  select( Country, Product_Code , Unit, Quantity_2013, Quantity_2014,Quantity_2015,Quantity_2016,Quantity_2017) %>% 
  full_join(export_value_dataset,by = c("Country","Product_Code"))  
export_jTable <- export_jTable %>% mutate(PcodeTwo=substr(Product_Code,1,2))
export_jTable <- left_join(export_jTable,prdCode,by =c("PcodeTwo"="X__1") )




export_jTable <- export_jTable %>% filter(!grepl("TOTAL", Product_Code))

import_jTable <- import_jTable %>% filter(!grepl("TOTAL", Product_Code))





q2013<-import_jTable %>% select(Country, PcodeTwo, X__2 ,Product_Code, Product_Label, Unit, Quantity_2013) %>% mutate(year="2013") %>% rename("Quantity"=Quantity_2013)
q2014<-import_jTable %>% select(Country, PcodeTwo, X__2 ,Product_Code, Product_Label, Unit, Quantity_2014) %>% mutate(year="2014") %>% rename("Quantity"=Quantity_2014)
q2015<-import_jTable %>% select(Country, PcodeTwo, X__2 ,Product_Code, Product_Label, Unit, Quantity_2015) %>% mutate(year="2015") %>% rename("Quantity"=Quantity_2015)
q2016<-import_jTable %>% select(Country, PcodeTwo, X__2 ,Product_Code, Product_Label, Unit, Quantity_2016) %>% mutate(year="2016") %>% rename("Quantity"=Quantity_2016) 
q2017<-import_jTable %>% select(Country, PcodeTwo, X__2 ,Product_Code, Product_Label, Unit, Quantity_2017) %>% mutate(year="2017") %>% rename("Quantity"=Quantity_2017)

importQuant <- bind_rows(q2013,q2014,q2015,q2016,q2017)

v2013<-import_jTable %>% select(Country,Product_Code, Value_2013) %>% rename("Values"=Value_2013) %>% mutate(year="2013")
v2014<-import_jTable %>% select(Country,Product_Code, Value_2014) %>% rename("Values"=Value_2014) %>% mutate(year="2014")
v2015<-import_jTable %>% select(Country,Product_Code, Value_2015) %>% rename("Values"=Value_2015) %>% mutate(year="2015")
v2016<-import_jTable %>% select(Country,Product_Code, Value_2016) %>% rename("Values"=Value_2016) %>% mutate(year="2016") 
v2017<-import_jTable %>% select(Country,Product_Code, Value_2017) %>% rename("Values"=Value_2017) %>% mutate(year="2017")

importValues <- bind_rows(v2013,v2014,v2015,v2016,v2017)

import_jTableMELTED <- importQuant %>% left_join(importValues, by=c("Country","Product_Code","year"))



q2013<-export_jTable %>% select(Country, PcodeTwo, X__2 ,Product_Code, Product_Label, Unit, Quantity_2013) %>% mutate(year="2013") %>% rename("Quantity"=Quantity_2013)
q2014<-export_jTable %>% select(Country, PcodeTwo, X__2 ,Product_Code, Product_Label, Unit, Quantity_2014) %>% mutate(year="2014") %>% rename("Quantity"=Quantity_2014)
q2015<-export_jTable %>% select(Country, PcodeTwo, X__2 ,Product_Code, Product_Label, Unit, Quantity_2015) %>% mutate(year="2015") %>% rename("Quantity"=Quantity_2015)
q2016<-export_jTable %>% select(Country, PcodeTwo, X__2 ,Product_Code, Product_Label, Unit, Quantity_2016) %>% mutate(year="2016") %>% rename("Quantity"=Quantity_2016) 
q2017<-export_jTable %>% select(Country, PcodeTwo, X__2 ,Product_Code, Product_Label, Unit, Quantity_2017) %>% mutate(year="2017") %>% rename("Quantity"=Quantity_2017)

exportQuant <- bind_rows(q2013,q2014,q2015,q2016,q2017)

v2013<-export_jTable %>% select(Country,Product_Code, Value_2013) %>% rename("Values"=Value_2013) %>% mutate(year="2013")
v2014<-export_jTable %>% select(Country,Product_Code, Value_2014) %>% rename("Values"=Value_2014) %>% mutate(year="2014")
v2015<-export_jTable %>% select(Country,Product_Code, Value_2015) %>% rename("Values"=Value_2015) %>% mutate(year="2015")
v2016<-export_jTable %>% select(Country,Product_Code, Value_2016) %>% rename("Values"=Value_2016) %>% mutate(year="2016") 
v2017<-export_jTable %>% select(Country,Product_Code, Value_2017) %>% rename("Values"=Value_2017) %>% mutate(year="2017")

exportValues <- bind_rows(v2013,v2014,v2015,v2016,v2017)

export_jTableMELTED <- exportQuant %>% left_join(exportValues, by=c("Country","Product_Code","year"))




saveRDS(export_jTable,file="C:/Users/emrek/Google Drive/BDA/503-EssentialsOfDataAnalytics/GitHub/gpj18-group_four/export_jTable.rds")

saveRDS(import_jTable,file="C:/Users/emrek/Google Drive/BDA/503-EssentialsOfDataAnalytics/GitHub/gpj18-group_four/import_jTable.rds")

saveRDS(export_jTableMELTED,file="C:/Users/emrek/Google Drive/BDA/503-EssentialsOfDataAnalytics/GitHub/gpj18-group_four/export_jTableMELTED.rds")

saveRDS(import_jTableMELTED,file="C:/Users/emrek/Google Drive/BDA/503-EssentialsOfDataAnalytics/GitHub/gpj18-group_four/import_jTableMELTED.rds")

