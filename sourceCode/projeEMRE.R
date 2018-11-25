library(tidyverse)
library(readxl)
library(dplyr)

PATH <-"C:\Users\emrek\Google Drive\BDA\503-EssentialsOfDataAnalytics\GitHub\gpj18-group_four\Raw Data"
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


import_jTable <- import_quantity_dataset %>% 
  mutate( Unit= coalesce(Unit1,Unit2 ,Unit3 , Unit4,Unit5)) %>%
  select( Country, Product_Code , Unit, Quantity_2013, Quantity_2014,Quantity_2015,Quantity_2016,Quantity_2017) %>% 
  full_join(import_value_dataset,by = c("Country","Product_Code"))  

export_jTable <- export_quantity_dataset %>% 
  mutate( Unit= coalesce(Unit1,Unit2 ,Unit3 , Unit4,Unit5)) %>%
  select( Country, Product_Code , Unit, Quantity_2013, Quantity_2014,Quantity_2015,Quantity_2016,Quantity_2017) %>% 
  full_join(export_value_dataset,by = c("Country","Product_Code"))  
