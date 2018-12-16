library(shiny)
library(tidyverse)
library(dplyr)
library(readxl)
library(lubridate)
library(reshape2)



usdR <- read_excel("C:/Users/avs1400/Desktop/master/DataAnEssR_503/project/EVDS.xlsx", col_names=FALSE, skip=1)
#usdR <- read_excel("D:/OMER/master/BDA-503/EVDS.xlsx", col_names=FALSE, skip=1)

colnames(usdR) <- c("DateR","ExchangeRate")
usd <- na.omit(usdR)
remove(usdR)

usdN<-usd %>% mutate(Date=dmy(DateR))
usdM<- usdN %>% group_by(year=year(Date)) %>% summarise(Rate=mean(ExchangeRate)*10000000)


#bist100R <- read_excel("D:/OMER/master/BDA-503/BIST100.xlsx", col_names=FALSE, skip=1)
bist100R <- read_excel("C:/Users/avs1400/Desktop/master/DataAnEssR_503/project/BIST100.xlsx", col_names=FALSE, skip=1)

colnames(bist100R) <- c("Date",	"Year","Value",	"Açılış",	"Yüksek",	"Düşük",	"Hac.",	"Fark %")
bist100 <- bist100R  %>% select(Date,Year,Value) %>% 
  group_by(Year) %>% 
  summarise(Value = mean(Value)*1000)



githubURL_export <- ("https://github.com/MEF-BDA503/gpj18-group_four/blob/master/export_jTable.rds?raw=true")
githubURL_import <- ("https://github.com/MEF-BDA503/gpj18-group_four/blob/master/import_jTable.rds?raw=true")

export_jTable<- readRDS(url(githubURL_export))
import_jTable<- readRDS(url(githubURL_import))

sumImport<- import_jTable %>% group_by(Country) %>% summarise(Value_2013=sum(Value_2013),Value_2014=sum(Value_2014),Value_2015=sum(Value_2015),Value_2016=sum(Value_2016),Value_2017=sum(Value_2017))
sumExport<- export_jTable %>% group_by(Country) %>% summarise(Value_2013=sum(Value_2013),Value_2014=sum(Value_2014),Value_2015=sum(Value_2015),Value_2016=sum(Value_2016),Value_2017=sum(Value_2017))
joinedTableDeficit<-sumExport %>%  inner_join(sumImport,by="Country") %>%
  mutate(Value_2013=Value_2013.y-Value_2013.x,Value_2014=Value_2014.y-Value_2014.x, Value_2015=Value_2015.y-Value_2015.x, Value_2016=Value_2016.y-Value_2016.x,
         Value_2017=Value_2017.y-Value_2017.x) %>%
  select(Country, Value_2013, Value_2014, Value_2015, Value_2016, Value_2017)

joinedTableDeficitMelt <- melt(joinedTableDeficit, id = c("Country"))
deficitPerCountry<-joinedTableDeficitMelt %>% mutate(year = case_when( variable == "Value_2013" ~ 2013,
                                                                       variable == "Value_2014" ~ 2014,
                                                                       variable == "Value_2015" ~ 2015,
                                                                       variable == "Value_2016" ~ 2016,
                                                                       variable == "Value_2017" ~ 2017)) %>%
  select(Country,year,value)

deficitPerYear <- deficitPerCountry %>%
  group_by(year) %>% summarise(value=sum(value))


p<-ggplot() + 
  geom_line(data=usdM,aes(x=year, y=Rate,group = 1),color="red")+
  geom_line(data=deficitPerYear,aes(x=year, y=value,group = 1),color="blue")+
  geom_line(data=bist100,aes(x=Year, y=Value,group = 1),color="green")


print(p)
