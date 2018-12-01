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



ggplot(table, aes(x=year)) +
  geom_point(aes(y=value, color=Country, shape=variable), size=4) + 
   labs(title="YoY Total Value Change",
    x="Year",
    y="% Change in  Value",
    shape=c("Trade Type"))



# Canada and Russia significantly deviates. Investigate these countries in detail with traded products

summarytableCanada <- export_jTableMELTED %>%
  filter(Country=="Canada") %>%
  group_by(X__2, year) %>%
  summarise(ExportValue=sum(Values)) %>%
  arrange(X__2, year) %>%
  mutate(ExpPercChngYoY = (ExportValue - lag(ExportValue))/lag(ExportValue)*100) %>%
  mutate(ExpChngYoy=((ExportValue - lag(ExportValue)))) %>%
  filter(year!=2013)


ggplot(summarytableCanada, aes(x=X__2)) +
  geom_point(aes(y=ExpChngYoy, color=year), size=4) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(title="YoY Total Value Change",
       x="Product Group",
       y="Change in Export Value",
       Color=c("Year"))

summarytableCanada2 <- summarytableCanada %>%
  arrange(desc(ExpChngYoy)) %>%
  filter(t


