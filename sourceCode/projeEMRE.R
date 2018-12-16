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
  facet_grid(~variable) +
   labs(title="YoY Total Value Change",
    x="Year",
    y="% Change in  Value",
    shape=c("Trade Type"))
    




# Canada and Russia significantly deviates. Investigate these countries in detail with traded products

# First Canada

# Export Analysis

summarytableCanadaEx <- export_jTableMELTED %>%
  filter(Country=="Canada") %>%
  group_by(X__2, year) %>%
  summarise(ExportValue=sum(Values)) %>%
  arrange(X__2, year) %>%
  mutate(ExpPercChngYoY = (ExportValue - lag(ExportValue))/lag(ExportValue)*100) %>%
  mutate(ExpChngYoy=((ExportValue - lag(ExportValue)))) %>%
  filter(year!=2013) 


mean(summarytableCanadaEx$ExpChngYoy)
median(summarytableCanadaEx$ExpChngYoy)
sd(summarytableCanadaEx$ExpChngYoy)
quantile(summarytableCanadaEx$ExpChngYoy, probs = c(0.25, 0.50, 0.75, 1))
IQR= quantile(summarytableCanadaEx$ExpChngYoy, probs = c(0.75)) - quantile(summarytableCanadaEx$ExpChngYoy, probs = c(0.25))
altsinir=quantile(summarytableCanadaEx$ExpChngYoy, probs = c(0.25)) - IQR
ustsinir=quantile(summarytableCanadaEx$ExpChngYoy, probs = c(0.75)) + IQR


summarytableCanadaEx <- summarytableCanadaEx %>%
  filter(abs(ExpChngYoy)>max(abs(altsinir),ustsinir))


plotCanEx <- ggplot(summarytableCanadaEx, aes(x=substr(X__2, start = 1, stop = 30))) +
  geom_point(aes(y=ExpChngYoy, color=year), size=4) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  facet_grid (~year) +
  facet_grid(rows = vars(year)) +
  labs(title="YoY Total Value Change with Canada - Export",
       x="Product Group",
       y="Change in Export Value",
       Color=c("Year"))



# Import Analysis


summarytableCanadaIm <- import_jTableMELTED %>%
  filter(Country=="Canada") %>%
  group_by(X__2, year) %>%
  summarise(ImportValue=sum(Values)) %>%
  arrange(X__2, year) %>%
  mutate(ImpPercChngYoY = (ImportValue - lag(ImportValue))/lag(ImportValue)*100) %>%
  mutate(ImpChngYoy=((ImportValue - lag(ImportValue)))) %>%
  filter(year!=2013) 


mean(summarytableCanadaIm$ImpChngYoy)
median(summarytableCanadaIm$ImpChngYoy)
sd(summarytableCanadaIm$ImpChngYoy)
quantile(summarytableCanadaIm$ImpChngYoy, probs = c(0.25, 0.50, 0.75, 1))
IQR= quantile(summarytableCanadaIm$ImpChngYoy, probs = c(0.75)) - quantile(summarytableCanadaIm$ImpChngYoy, probs = c(0.25))
altsinir=quantile(summarytableCanadaIm$ImpChngYoy, probs = c(0.25)) - IQR
ustsinir=quantile(summarytableCanadaIm$ImpChngYoy, probs = c(0.75)) + IQR


summarytableCanadaIm <- summarytableCanadaIm %>%
  filter(abs(ImpChngYoy)>max(abs(altsinir),ustsinir))


plotCanIm <- ggplot(summarytableCanadaIm, aes(x=substr(X__2, start = 1, stop = 30))) +
  geom_point(aes(y=ImpChngYoy, color=year), size=4) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  facet_grid (~year) +
  facet_grid(rows = vars(year)) +
  labs(title="YoY Total Value Change Canada - Import",
       x="Product Group",
       y="Change in Import Value",
       Color=c("Year"))



# Second Russia

# Export Analysis

summarytableRussianEx <- export_jTableMELTED %>%
  filter(Country=="Russian") %>%
  group_by(X__2, year) %>%
  summarise(ExportValue=sum(Values)) %>%
  arrange(X__2, year) %>%
  mutate(ExpPercChngYoY = (ExportValue - lag(ExportValue))/lag(ExportValue)*100) %>%
  mutate(ExpChngYoy=((ExportValue - lag(ExportValue)))) %>%
  filter(year!=2013) 


mean(summarytableRussianEx$ExpChngYoy)
median(summarytableRussianEx$ExpChngYoy)
sd(summarytableRussianEx$ExpChngYoy)
quantile(summarytableRussianEx$ExpChngYoy, probs = c(0.25, 0.50, 0.75, 1))
IQR= quantile(summarytableRussianEx$ExpChngYoy, probs = c(0.75)) - quantile(summarytableRussianEx$ExpChngYoy, probs = c(0.25))
altsinir=quantile(summarytableRussianEx$ExpChngYoy, probs = c(0.25)) - IQR
ustsinir=quantile(summarytableRussianEx$ExpChngYoy, probs = c(0.75)) + IQR


summarytableRussianEx <- summarytableRussianEx %>%
  filter(abs(ExpChngYoy)>max(abs(altsinir),ustsinir))


plotRusEx <- ggplot(summarytableRussianEx, aes(x=substr(X__2, start = 1, stop = 30))) +
  geom_point(aes(y=ExpChngYoy, color=year), size=4) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  facet_grid (~year) +
  facet_grid(rows = vars(year)) +
  labs(title="YoY Total Value Change Russia - Export",
       x="Product Group",
       y="Change in Export Value",
       Color=c("Year"))



# Import Analysis


summarytableRussianIm <- import_jTableMELTED %>%
  filter(Country=="Russian") %>%
  group_by(X__2, year) %>%
  summarise(ImportValue=sum(Values)) %>%
  arrange(X__2, year) %>%
  mutate(ImpPercChngYoY = (ImportValue - lag(ImportValue))/lag(ImportValue)*100) %>%
  mutate(ImpChngYoy=((ImportValue - lag(ImportValue)))) %>%
  filter(year!=2013) 


mean(summarytableRussianIm$ImpChngYoy)
median(summarytableRussianIm$ImpChngYoy)
sd(summarytableRussianIm$ImpChngYoy)
quantile(summarytableRussianIm$ImpChngYoy, probs = c(0.25, 0.50, 0.75, 1))
IQR= quantile(summarytableRussianIm$ImpChngYoy, probs = c(0.75)) - quantile(summarytableRussianIm$ImpChngYoy, probs = c(0.25))
altsinir=quantile(summarytableRussianIm$ImpChngYoy, probs = c(0.25)) - IQR
ustsinir=quantile(summarytableRussianIm$ImpChngYoy, probs = c(0.75)) + IQR


summarytableRussianIm <- summarytableRussianIm %>%
  filter(abs(ImpChngYoy)>max(abs(altsinir),ustsinir))


plotRusIm <- ggplot(summarytableRussianIm, aes(x=substr(X__2, start = 1, stop = 30))) +
  geom_point(aes(y=ImpChngYoy, color=year), size=4) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  facet_grid (~year) +
  facet_grid(rows = vars(year)) +
  labs(title="YoY Total Value Change Russia - Import",
       x="Product Group",
       y="Change in Import Value",
       Color=c("Year"))

#install.packages("gridExtra")

library(gridExtra)

grid.arrange(plotCanEx, plotCanIm,  nrow = 1)
grid.arrange(plotRusEx, plotRusIm,  nrow = 2)
