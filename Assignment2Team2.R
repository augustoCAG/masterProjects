# -*- coding: utf-8 -*-
"""ATUALIZADO_trab2VPDAemR.ipynb

Automatically generated by Colaboratory.

Original file is located at
    https://colab.research.google.com/drive/1iVYLxwAhP7IQL6aM_GXcU22r-7E6sAdV

##**Research question:**

- How are crimes distributed over time and across the Portuguese territory? Also, how are crimes affected by unemployment?

TEAM 2

AUGUSTO AGOSTINI

JULIO OLIVEIRA

# Importing libraries and datasets as dataframes
"""

#install.packages('caret')
#install.packages('mlbench')

## importing the libraries
library(readxl)
library(tidyverse)
library(dplyr)
library(lubridate)
library(ggplot2)
#library(ggthemes)
#library(zoo)

## importing the datasets
df1 = read_xlsx('datasetFiltrado.xlsx')
crimes = read_xlsx('1a_crimesPortugal__EDITADO.xlsx')
unemploy = read_xlsx('unemployrate_pt.xlsx')

"""# Visualizing the first 4 rows of both dataframes"""

head(df1,n=4L)

colnames(df1)

#total rows in df1
nrow(df1)

"""  - The dataset **df1** is composed of variables of unemployment rate, convicted crimes and some environmental indicators, over the years."""

head(crimes,n=4L)

colnames(crimes)

#total rows in crimes
nrow(crimes)

"""  - The dataset **crimes** is composed of variables of various types of crime and the total crimes among counties and over the years."""

sapply(df1, class)

sapply(crimes, class)

"""- As Crimes dataset counts on values from 2011 to 2019 and Df1 dataset counts on values from 1998 to 2018, we will proceede with all the analysis considerig values from 2011 to 2018 for both datasets."""

# Rewrites df1 and crimes considering only 2011 to 2018
anos = c(2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018)
crimes = crimes %>% filter(crimes$Ano %in% anos)
df1 = df1 %>% filter(df1$Ano %in% anos)

#total rows in df1
nrow(df1)

"""# Preliminary Analysis

##Df1
"""

## verifying statistics proprieties and missing values
summary(df1)

"""- It seams that the data on **df1** has well distributed variables and has no outliers. In this sense, a priori, it will not be necessary to invest much in the preparation of data for this dataset.

##Crimes
"""

## verifying statistics proprieties and missing values
summary(crimes)

"""- The same applies to the **crimes** Data Set: it has well distributed variables and no outliers.

##Unemploy Rate:
"""

summary(unemploy)

"""- The same applies to the **unemploy** Data Set: it has well distributed variables and no outliers.

# **Missing Values**

## "Crimes" dataframe:
"""

crimes %>% summarise_all(funs(sum(is.na(.))))

#total rows in crimes
nrow(crimes)

"""- If we consider just "Crimes against persons", "Crimes against patrimony" and "Crimes against life in society", the DataSet has just 102 missing values over 2464 rows (arround 4% of the total). Thus, if we replace the missing by its mean or the median, we will not create too much distortion on the data.

###**Crimes against persons:**
"""

against_persons = crimes %>% rename("crimes_against_persons" = "Crimes against persons") 
ggplot(against_persons, aes(x=crimes_against_persons)) + 
  geom_histogram(color="black", fill="white")

"""- The graph shows that the variable presents a strong asymmetry: it has a large frequency for small occurrences and as the occurrences increase the frequency constantly reduces.

- As Median = 107.0 and Mean = 270.3 are very different due to some high values that increase the mean, we better use median in order to fill in the 4 missing values in "Crimes against persons".
"""

#crimes %>% rename("crimes_against_persons" = "Crimes against persons") %>%
#crimes$crimes_against_persons[is.na(df$crimes_against_persons)] = median(df$crimes_against_persons, na.rm=TRUE)

crimes[is.na(crimes[,6]), 6] = 270.3

"""###**Crimes against patrimony:**"""

against_patrimony = crimes %>% rename("crimes_against_patrimony" = "Crimes against patrimony")
ggplot(against_patrimony, aes(x=crimes_against_patrimony)) + 
  geom_histogram(color="black", fill="white")

"""- The same aplies here: the variable presents a strong asymmetry, having a large frequency for small occurrences and as the occurrences increase the frequency constantly reduces.

- As Median = 182.0 and Mean = 622.09 are very different due to some high values that increase the mean, we better use median in order to fill in the 6 missing values in "Crimes against patrimony".
"""

crimes[is.na(crimes[,7]), 7] = 182.0

"""**Crimes against life in society**"""

against_life = crimes %>% rename("crimes_against_life" = "Crimes against life in society")
ggplot(against_life, aes(x=crimes_against_life)) + 
  geom_histogram(color="black", fill="white")

"""- Same assimetric pattern as before.

- As Median = 69.0 and Mean = 150.3 are very different due to some high values that increase the mean, we better use median in order to fill in the 92 missing values in "Crimes against life in society".
"""

crimes[is.na(crimes[,8]), 8] = 69.0

"""**Crimes against the State, Crimes against pet animals and Crimes set out in sundry legislation:**

- Crimes against the State has 	847 missing values, Crimes against pet animals	has 1923 and Crimes set out in sundry legislation has 478. Concerning that the Crimes dataset has 2464 instances, the missing values represent a huge part of it for these variables. These three variables are not important for us in this work, so we better delete them from de dataframe.
"""

drops = c("Crimes against the State","Crimes against pet animals", "Crimes set out in sundry legislation")
crimes = crimes[ , !(colnames(crimes) %in% drops)]

"""- Verifying that there isn't any missign values anymore:"""

crimes %>% summarise_all(funs(sum(is.na(.))))

summary(crimes)

"""## "Df1" dataframe:"""

df1 %>% summarise_all(funs(sum(is.na(.))))

"""- Doesn't have any missing values.

**Considerations:**

- in general, filling missing values with the attribute's mean/median induces bias in the variance, so it's better to use a linear regression model. However we do have a tiny numer os instancer for some variables, making difficult to handdle a good estimation using regression. 

- also, considering that the missing values do not depend neither on the observed nor the unobserved variables (considering a  MCAR - missing completely at random - missing mechanism), we could ignore all instances with missing values without adding bias. However we preferred to fill them with median or mean to fill in the missing values.

# **Outliers**

## "Crimes" dataframe:

**- Total	Crimes:**
"""

Q1_crimes_5 = quantile(crimes[,5], probs = 0.25, na.rm=TRUE)
Q3_crimes_5 = quantile(crimes[,5], probs = 0.75, na.rm=TRUE)
IQR_crimes_5 = Q3_crimes_5 - Q1_crimes_5
Q1_crimes_5
Q3_crimes_5
IQR_crimes_5

lim_sup_crimes_5 = Q3_crimes_5 + 1.5 * IQR_crimes_5
lim_inf_crimes_5 = Q1_crimes_5 - 1.5 * IQR_crimes_5
crimes %>% filter(crimes[,5] < lim_inf_crimes_5 & crimes[,5] > lim_sup_crimes_5)

"""- There're no outliers for Total Crimes

**- Crimes against persons:**
"""

Q1_crimes_6 = quantile(crimes[,6], probs = 0.25, na.rm=TRUE)
Q3_crimes_6 = quantile(crimes[,6], probs = 0.75, na.rm=TRUE)
IQR_crimes_6 = Q3_crimes_6 - Q1_crimes_6
Q1_crimes_6
Q3_crimes_6
IQR_crimes_6

lim_sup_crimes_6 = Q3_crimes_6 + 1.5 * IQR_crimes_6
lim_inf_crimes_6 = Q1_crimes_6 - 1.5 * IQR_crimes_6
crimes %>% filter(crimes[,6] < lim_inf_crimes_6 & crimes[,6] > lim_sup_crimes_6)

"""- There're no outliers for Crimes against persons

**- Crimes against patrimony:**
"""

Q1_crimes_7 = quantile(crimes[,7], probs = 0.25, na.rm=TRUE)
Q3_crimes_7 = quantile(crimes[,7], probs = 0.75, na.rm=TRUE)
IQR_crimes_7 = Q3_crimes_7 - Q1_crimes_7
Q1_crimes_7
Q3_crimes_7
IQR_crimes_7

lim_sup_crimes_7 = Q3_crimes_7 + 1.5 * IQR_crimes_7
lim_inf_crimes_7 = Q1_crimes_7 - 1.5 * IQR_crimes_7
crimes %>% filter(crimes[,7] < lim_inf_crimes_7 & crimes[,7] > lim_sup_crimes_7)

"""- There're no outliers for Crimes against patrimony

**- Crimes against life in society:**
"""

Q1_crimes_8 = quantile(crimes[,8], probs = 0.25, na.rm=TRUE)
Q3_crimes_8 = quantile(crimes[,8], probs = 0.75, na.rm=TRUE)
IQR_crimes_8 = Q3_crimes_8 - Q1_crimes_8
Q1_crimes_8
Q3_crimes_8
IQR_crimes_8

lim_sup_crimes_8 = Q3_crimes_8 + 1.5 * IQR_crimes_8
lim_inf_crimes_8 = Q1_crimes_8 - 1.5 * IQR_crimes_8
crimes %>% filter(crimes[,8] < lim_inf_crimes_8 & crimes[,8] > lim_sup_crimes_8)

"""- There're no outliers for Crimes against life in society

## "Df1" dataframe:

- As the Df1 dataframe has a large number of numeric attributes, we will access all its quantiles at once inside a for loop:
"""

Q1_df1 = c()
Q3_df1 = c()
IQR_df1 = c()
for (i in 2:25) {
  Q1_df1 = append(Q1_df1, quantile(df1[,i], probs = 0.25, na.rm=TRUE))
  Q3_df1 = append(Q3_df1, quantile(df1[,i], probs = 0.75, na.rm=TRUE))
  IQR_df1 = append(IQR_df1, Q3_df1[i-1]-Q1_df1[i-1])
}

lim_sup_df1 = c()
lim_inf_df1 = c()
for (j in 1:24) {
  lim_sup_df1 = append(lim_sup_df1, Q3_df1[i] + 1.5 * IQR_df1[i])
  lim_inf_df1 = append(lim_inf_df1, Q1_df1[i] - 1.5 * IQR_df1[i])
}

rows = c()
outliers_df1 = list()
for (i in 1:24){
  outliers_df1 = df1 %>% filter(df1[,i+1] < lim_inf_df1[i] & df1[,i+1] > lim_sup_df1[i])
  rows = append(rows, nrow(outliers_df1))
}

str(rows)

"""- Vector with the number of lines in each data frame (one datafram per variable/attribute - each line would be a row with an outlier):"""

rows

"""- There're no outliers in df1 also.

- Example of the first dataframe (verification os outliers for the first numeric variable in df1):
"""

df1 %>% filter(df1[,2] < lim_inf_df1[1] & df1[,2] > lim_sup_df1[1])

"""# **Normalization**

- Normalization type Stardadization being applied to numeric attributes of each dataframe:
"""

crimes_2 = crimes
df1_2 = df1

crimes_norm = as.data.frame(scale(crimes_2[, 5:8]))
df1_norm = as.data.frame(scale(df1_2[, 2:25]))

"""- Unite numeric attributes normalized to the non-numeric ones:"""

# for the "Crimes" dataframe

crimes_2$Total = crimes_norm[,1] 
crimes_2$`Crimes against persons` = crimes_norm[,2]
crimes_2$`Crimes against patrimony` = crimes_norm[,3]
crimes_2$`Crimes against life in society`= crimes_norm[,4]

# for the "Df1" dataframe

for (i in 1:24) {
  df1_2[,i+1] = df1_norm[,i]
}

head(df1_2, n=4L)

head(crimes_2, n=4L)

"""- **crimes_2** and **df1_2** are the **normalized** dataframes. They could be very useful if we would make a clustering analysis or develop a prediction problem (regression, for example), or even in some plots when variables have different orders of magnitude. However, in the present work it probably won't be necessary."""

multiplot <- function(..., plotlist=NULL, cols) {
  require(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # Make the panel
  plotCols = cols                          # Number of columns of plots
  plotRows = ceiling(numPlots/plotCols) # Number of rows needed, calculated from # of cols
  
  # Set up the page
  grid.newpage()
  pushViewport(viewport(layout = grid.layout(plotRows, plotCols)))
  vplayout <- function(x, y)
    viewport(layout.pos.row = x, layout.pos.col = y)
  
  # Make each plot, in the correct location
  for (i in 1:numPlots) {
    curRow = ceiling(i/plotCols)
    curCol = (i-1) %% plotCols + 1
    print(plots[[i]], vp = vplayout(curRow, curCol ))
  }
  
}

"""#**Research question:**

- How are crimes distributed over time and across the Portuguese territory? Also, how are crimes affected by unemployment?

## **Plots:**

##Df1

###Crimes vs Unemployment
"""

df1

df1_plot = df1 %>%
  rename(cond_mil = "Condenados por mil hab.") %>%
  rename(desempTotPerc = "desempTotal%") %>%
  #group_by(Ano) %>%
  arrange(Ano) %>%
  mutate(sum_cond =sum(cond_mil)) %>%
  select(Ano, cond_mil, sum_cond, desempTotPerc)

df1_plot

#Crimes over years
porc_pop_cond = df1_plot$cond_mil/1000

p10 = ggplot(data=df1_plot, aes(x=Ano, y=porc_pop_cond))
p10 = p10 + geom_point()
p10 = p10 + geom_line(color="red")
p10 = p10 + scale_y_continuous(labels = scales::percent_format())
p10 = p10 + labs(x = 'Year', y = '%  of Popul. Convicted', title='% of Population Convicted per Year')
p10 = p10 + theme_bw() + theme(plot.title=element_text(size =rel(2), hjust=0, color='blue' ))
p10 = p10 + theme(axis.text.x = element_text(color = "grey20", size = 15, angle = 0, hjust = .5, vjust = .5, face = "plain"),
                  axis.text.y = element_text(color = "grey20", size = 15, angle = 0, hjust = 1, vjust = 0, face = "plain"),  
                  axis.title.x = element_text(color = "grey20", size = 20, angle = 0, hjust = .5, vjust = 0, face = "plain"),
                  axis.title.y = element_text(color = "grey20", size = 22, angle = 90, hjust = .5, vjust = .5, face = "plain"))

p10

"""  - This graph shows that the convicted crimes presents a tendency of reduction since 2012. Besides the year of 2011 and 2014, the convicted crimes are constantly decreasing."""

# Unemployed over year
porc_pop_desemp = df1_plot$desempTotPerc/100

p11 = ggplot(data=df1_plot, aes(x=Ano, y=porc_pop_desemp))
p11 = p11 + geom_point()
p11 = p11 + geom_line(color="red")
p11 = p11 + scale_y_continuous(labels = scales::percent_format())
p11 = p11 + labs(x = 'Year', y = '%  of Popul. Unemployed', title='% of Population Unemployed per Year')
p11 = p11 + theme_bw() + theme(plot.title=element_text(size =rel(2), hjust=0, color='blue' ))
p11 = p11 + theme(axis.text.x = element_text(color = "grey20", size = 15, angle = 0, hjust = .5, vjust = .5, face = "plain"),
                  axis.text.y = element_text(color = "grey20", size = 15, angle = 0, hjust = 1, vjust = 0, face = "plain"),  
                  axis.title.x = element_text(color = "grey20", size = 20, angle = 0, hjust = .5, vjust = 0, face = "plain"),
                  axis.title.y = element_text(color = "grey20", size = 22, angle = 90, hjust = .5, vjust = .5, face = "plain"))

p11

"""  - This graph shows a similar tendency as the convicted crimes: besides two specific years, the unemployment rate has constantly decreased.

"""

#Unemployment vs Crimes

p1_ = ggplot(data=df1_plot, aes(x=porc_pop_desemp*100, y=porc_pop_cond))
p1_ = p1_ + geom_point()
p1_ = p1_ + geom_line(color="red")
p1_ = p1_ + scale_y_continuous(labels = scales::percent_format())
p1_ = p1_ + labs(x = '%  of Population Unemployed', y = '%  of Population Convicted' , title='Unemployment vs Convicted ')
p1_ = p1_ + theme_bw() + theme(plot.title=element_text(size =rel(2), hjust=0, color='blue' ))
p1_ = p1_ + theme(axis.text.x = element_text(color = "grey20", size = 15, angle = 0, hjust = .5, vjust = .5, face = "plain"),
                  axis.text.y = element_text(color = "grey20", size = 15, angle = 0, hjust = 1, vjust = 0, face = "plain"),  
                  axis.title.x = element_text(color = "grey20", size = 20, angle = 0, hjust = .5, vjust = 0, face = "plain"),
                  axis.title.y = element_text(color = "grey20", size = 22, angle = 90, hjust = .5, vjust = .5, face = "plain"))
p1_

"""- This graph shows the strong correlation between these two variables. As we expected, the crime rates increases as the unemployment increases.


  - Disclaimer: This graph contains just 8 points that expresse the average of the two variables for the entire country. Thus, since the information is condensed, a linear regression model probably won`t great results. On the other hand, the visualisation of the given chart gives the opportunitty to clearly see the relationship between those two variables.
"""

multiplot(p10, p11, cols=1)

"""###Unemployment among age groups"""

df1_plot2 = df1 %>%
  rename(cond_mil = "Condenados por mil hab.") %>%
  rename(porcDesempSub25 = "desempMenores25%") %>%
  rename(porcDesemp25to54 = "desemp25-54anos%") %>%
  rename(porcDesemp55to64 = "desemp55-64anos%") %>%
  #group_by(Ano) %>%
  arrange(Ano) %>%
  mutate(sum_cond =sum(cond_mil)) %>%
  select(Ano, cond_mil, sum_cond, porcDesempSub25, porcDesemp25to54, porcDesemp55to64)

df1_plot2

porc_popSub25_desemp = df1_plot2$porcDesempSub25/100

p12 = ggplot(data=df1_plot, aes(x=Ano, y=porc_popSub25_desemp))
p12 = p12 + geom_point()
p12 = p12 + geom_line(color="red")
p12 = p12 + scale_y_continuous(labels = scales::percent_format())
p12 = p12 + labs(x = 'Year', y = '% of Population Under 25 Unemployed', title='% of Population Under 25 Unemployed per Year')
p12 = p12 + theme_bw() + theme(plot.title=element_text(size =rel(1.5), hjust=0, color='blue' ))
p12 = p12 + theme(axis.text.x = element_text(color = "grey20", size = 15, angle = 0, hjust = .5, vjust = .5, face = "plain"),
                  axis.text.y = element_text(color = "grey20", size = 15, angle = 0, hjust = 1, vjust = 0, face = "plain"),  
                  axis.title.x = element_text(color = "grey20", size = 20, angle = 0, hjust = .5, vjust = 0, face = "plain"),
                  axis.title.y = element_text(color = "grey20", size = 20, angle = 90, hjust = .5, vjust = .5, face = "plain"))

p12

"""  - This graph expresses the same behavior as it was saw before for the entire population (considering all ages)"""

porc_pop25to54_desemp = df1_plot2$porcDesemp25to54/100

p13 = ggplot(data=df1_plot, aes(x=Ano, y=porc_pop25to54_desemp))
p13 = p13 + geom_point()
p13 = p13 + geom_line(color="red")
p13 = p13 + scale_y_continuous(labels = scales::percent_format())
p13 = p13 + labs(x = 'Year', y = '% of Population 25-54 Years Old Unemployed', title='% of Population 25-54 Years Old Unemployed per Year')
p13 = p13 + theme_bw() + theme(plot.title=element_text(size =rel(1.5), hjust=0, color='blue' ))
p13 = p13 + theme(axis.text.x = element_text(color = "grey20", size = 15, angle = 0, hjust = .5, vjust = .5, face = "plain"),
                  axis.text.y = element_text(color = "grey20", size = 15, angle = 0, hjust = 1, vjust = 0, face = "plain"),  
                  axis.title.x = element_text(color = "grey20", size = 20, angle = 0, hjust = .5, vjust = 0, face = "plain"),
                  axis.title.y = element_text(color = "grey20", size = 20, angle = 90, hjust = .5, vjust = .5, face = "plain"))

p13

"""Again, the graph expresses the same behavior."""

porc_pop55to64_desemp = df1_plot2$porcDesemp55to64/100

p14 = ggplot(data=df1_plot, aes(x=Ano, y=porc_pop55to64_desemp))
p14 = p14 + geom_point()
p14 = p14 + geom_line(color="red")
p14 = p14 + scale_y_continuous(labels = scales::percent_format())
p14 = p14 + labs(x = 'Year', y = '% of Population 55-64 Years Old Unemployed', title='% of Population 55-64 Years Old Unemployed per Year')
p14 = p14 + theme_bw() + theme(plot.title=element_text(size =rel(1.5), hjust=0, color='blue' ))
p14 = p14 + theme(axis.text.x = element_text(color = "grey20", size = 15, angle = 0, hjust = .5, vjust = .5, face = "plain"),
                  axis.text.y = element_text(color = "grey20", size = 15, angle = 0, hjust = 1, vjust = 0, face = "plain"),  
                  axis.title.x = element_text(color = "grey20", size = 20, angle = 0, hjust = .5, vjust = 0, face = "plain"),
                  axis.title.y = element_text(color = "grey20", size = 20, angle = 90, hjust = .5, vjust = .5, face = "plain"))

p14

multiplot(p12, p13, p14, p10, cols=2)

multiplot(p12, p10, cols=2)

multiplot(p13, p10, cols=2)

multiplot(p14, p10, cols=2)

"""- As the decrease of convicted people from 2013 to 2014 is high and the unemployment among 55-64 years old people doesn't decrease that much (less than the decrease for 25-54 and under 25 years old people), we can assume that most of crimes are commited by under 25 or 25-54 years old people.



**Very strong conclusion here**

##Crimes:
"""

crimes

"""###Crimes among regions"""

crimes_plot <- crimes %>%
  rename( intermunicipal = "INTERMUNICIPAL COMMUNITY") %>%
  group_by ( REGION) %>%
  arrange ( Ano ) %>% ## to make sure it is sorted
  #mutate ( seq = row_number() ) %>% ## seq within country
  mutate ( sum_crimes = sum( Total ) ) %>% ## cumulative sums
  #mutate ( MedianaCrimesAno = median( Total )) %>% ## cumulative sums
  #ungroup() %>% ## remove grouping 
  select(REGION, sum_crimes) %>%
  distinct()

head(crimes_plot, n=10L)

p1 = ggplot(data = crimes_plot )
p1 =  p1 + geom_col( aes(x = reorder(REGION, -sum_crimes) , y = sum_crimes/100000) , alpha = 0.8, color="red")
p1 = p1 + labs(x = 'Region', y = 'Total Crimes x 10^-5', title='Total Crimes across regions (2011 to 2018)')
##
p1= p1 + theme_bw()+ theme(axis.text.x=element_blank()) + theme(plot.title=element_text(size =rel(2), hjust=0, color='blue' ))
p1=p1+ theme(axis.text.x = element_text(color = "grey20", size = 15, angle = 0, hjust = .5, vjust = .5, face = "plain"),
             axis.text.y = element_text(color = "grey20", size = 15, angle = 0, hjust = 1, vjust = 0, face = "plain"),
             axis.title.y = element_text(color = "black", size = 25, angle = 90, hjust = .5, vjust = .5, face = "plain"),
             axis.title.x = element_text(color = "black", size = 20, angle = 0, hjust = .5, vjust = 0, face = "plain"))
p1= p1 + scale_x_discrete(labels=c('Alentejo' = "Alent.", 'Algarve' = "Algar.", '�rea Metropolitana de Lisboa'= "Reg.Lis.",
                                   'Regi�o Aut�noma da Madeira' = "Madei.", 'Regi�o Aut�noma dos A�ores' = "A�or.",
                                   'Centro' = "Centro", 'Norte' = "Norte"))
p1 = p1 + guides(fill=guide_legend(title="Regions"))
p1=p1+ coord_flip()
##

p1

"""population per region (alphabetic order): populacao =c(776339, 395208, 2808414, 2348453, 3818722, 245012, 244006)

This graph shows that Lisbon and the Center region are the top ones on Total Crimes, while A�ores and Madeira regions are the lowest ones. Since Lisbon and the Center region are the most populous, it may gives the false impretion that these two are the most violent regions, but it may not be the case.
For a better understanding of the violence situation we should analise the crimes per capita for each region.
"""

populacao =c(776339, 395208, 2808414, 2348453, 3818722, 245012, 244006)/1000000
regions = c('Alentejo', 'Algarve', '�rea Metropolitana de Lisboa', 'Centro', 'Norte', 'Regi�o Aut�noma da Madeira', 'Regi�o Aut�noma dos A�ores')
pop_reg = as.data.frame(regions, populacao)# %>% ifelse(pop_reg$regions=="�rea Metropolitana de Lisboa", 1, 0)
p3 = ggplot(data=pop_reg) + geom_col(aes(x=reorder(regions, -populacao), y=populacao) , alpha = 0.8,  color="red")
p3= p3 + labs(x = 'Region', y = 'Population x 10^-6', title='Population per Region (2020)')
##
p3= p3 + theme_bw()+ theme(axis.text.x=element_blank()) + theme(plot.title=element_text(size =rel(2), hjust=0, color='blue' ))
p3=p3+ theme(axis.text.x = element_text(color = "grey20", size = 15, angle = 0, hjust = .5, vjust = .5, face = "plain"),
             axis.text.y = element_text(color = "grey20", size = 15, angle = 0, hjust = 1, vjust = 0, face = "plain"),
             axis.title.y = element_text(color = "black", size = 25, angle = 90, hjust = .5, vjust = .5, face = "plain"),
             axis.title.x = element_text(color = "black", size = 20, angle = 0, hjust = .5, vjust = 0, face = "plain"))
p3= p3 + scale_x_discrete(labels=c('Alentejo' = "Alent.", 'Algarve' = "Algar.", '�rea Metropolitana de Lisboa'= "Reg.Lis.",
                                   'Regi�o Aut�noma da Madeira' = "Madei.", 'Regi�o Aut�noma dos A�ores' = "A�or.",
                                   'Centro' = "Centro", 'Norte' = "Norte"))
p3 = p3 + guides(fill=guide_legend(title="Regions"))
p3=p3+ coord_flip()
##

p3

"""- This (and the following) plots were built using the regions with a legend format because the names are too long and would appear one over other. A solution would be to flip the coordinates."""

multiplot(p1, p3, cols=1)

"""- The Lisbon Metropolitan Region, the region with more crimes, has more crimes per hab. than the North Region. The same occurs with A�ores, which has a little bit less population than Madeira but has more crimes."""

crimes_plot_ = crimes_plot
crimes_plot_$population =c(776339, 395208, 2808414, 2348453, 3818722, 245012, 244006)
crimes_plot_$crimes_pp = crimes_plot_$sum_crimes/crimes_plot_$population
crimes_plot_

# Crimes per capita
p_ = ggplot(data = crimes_plot_ )
p_ =  p_ + geom_col( aes(x = reorder(REGION, -crimes_pp) , y = crimes_pp) , alpha = 0.8, color="red")
p_ = p_ + labs(x = 'Region', y = 'Total Crimes', title='Crimes/hab across regions (2011 to 2018)')
##
p_= p_ + theme_bw()+ theme(axis.text.x=element_blank()) + theme(plot.title=element_text(size =rel(2), hjust=0, color='blue' ))
p_=p_+ theme(axis.text.x = element_text(color = "grey20", size = 15, angle = 0, hjust = .5, vjust = .5, face = "plain"),
             axis.text.y = element_text(color = "grey20", size = 15, angle = 0, hjust = 1, vjust = 0, face = "plain"),
             axis.title.y = element_text(color = "black", size = 25, angle = 90, hjust = .5, vjust = .5, face = "plain"),
             axis.title.x = element_text(color = "black", size = 20, angle = 0, hjust = .5, vjust = 0, face = "plain"))
p_= p_ + scale_x_discrete(labels=c('Alentejo' = "Alent.", 'Algarve' = "Algar.", '�rea Metropolitana de Lisboa'= "Reg.Lis.",
                                   'Regi�o Aut�noma da Madeira' = "Madei.", 'Regi�o Aut�noma dos A�ores' = "A�or.",
                                   'Centro' = "Centro", 'Norte' = "Norte"))
p_ = p_ + guides(fill=guide_legend(title="Regions"))
p_=p_+ coord_flip()
##

p_

"""  - The per capita chart shows that while the Lisbon and the North region remains in the top, now Alentejo and Algarve are on the botton of the rank.

  - Disclaimer: This graph considers the total crimes per capita over 8 year (2011 to 2019). Then, to visualize the the average of crimes per capita over 1 year we should divide the values by 8. Since the objective, from now, is just to compare the regions, it was kept like so.
"""

crimes_plot3 <- crimes %>%
  rename( intermunicipal = "INTERMUNICIPAL COMMUNITY") %>%
  group_by ( REGION, Ano) %>%
  arrange ( Ano ) %>% ## to make sure it is sorted
  #mutate ( seq = row_number() ) %>% ## seq within country
  mutate ( sum_crimes = sum( Total ) ) %>% ## cumulative sums
  #mutate ( MedianaCrimesAno = median( Total )) %>% ## cumulative sums
  #ungroup() %>% ## remove grouping 
  select(REGION, Ano, sum_crimes) %>%
  distinct()

sum_crimes_reduced = crimes_plot3$sum_crimes/100000
p4 = ggplot(crimes_plot3, aes(fill=factor(Ano), y=sum_crimes_reduced, x=reorder(REGION, -sum_crimes)))
p4 = p4 + geom_bar(position="stack", stat="identity")
p4 = p4 + labs(x = 'Region', y = 'Total Crimes x 10^-5', title='Total Crimes for All Regions and Years')
p4 = p4 + theme_bw() + theme(plot.title=element_text(size =rel(2), hjust=0, color='blue' ))
p4 = p4 + theme(axis.text.x = element_text(color = "grey20", size = 15, angle = 0, hjust = .5, vjust = .5, face = "plain"),
                axis.text.y = element_text(color = "grey20", size = 15, angle = 0, hjust = 1, vjust = 0, face = "plain"),  
                axis.title.x = element_text(color = "grey20", size = 20, angle = 0, hjust = .5, vjust = 0, face = "plain"),
                axis.title.y = element_text(color = "grey20", size = 22, angle = 90, hjust = .5, vjust = .5, face = "plain"))
p4= p4 + guides(fill=guide_legend(title="Years"))
p4= p4 + scale_x_discrete(labels=c('Alentejo' = "Alent.", 'Algarve' = "Algar.", '�rea Metropolitana de Lisboa'= "Reg.Lis.",
                                   'Regi�o Aut�noma da Madeira' = "Madei.", 'Regi�o Aut�noma dos A�ores' = "A�or.",
                                   'Centro' = "Centro", 'Norte' = "Norte"))
p4 = p4 + theme(legend.title = element_text(color = "grey20",size = 18), legend.text = element_text(color = "grey20",size = 15))  + theme(legend.title=element_blank())

p4

""" - **Not so good to visualize**"""

p5 = ggplot(crimes_plot3, aes(fill=REGION, y=sum_crimes, x=Ano))
p5 = p5 + geom_bar(position="stack", stat="identity")
p5 = p5 + labs(x = 'Year', y = 'Total Crimes', title='Total Crimes for All Years and Regions', color='')
p5 = p5 + theme_bw() + theme(plot.title=element_text(size =rel(2), hjust=0, color='blue' ))
p5 = p5 + theme(axis.text.x = element_text(color = "grey20", size = 15, angle = 0, hjust = .5, vjust = .5, face = "plain"),
                axis.text.y = element_text(color = "grey20", size = 15, angle = 0, hjust = 1, vjust = 0, face = "plain"),  
                axis.title.x = element_text(color = "grey20", size = 20, angle = 0, hjust = .5, vjust = 0, face = "plain"),
                axis.title.y = element_text(color = "grey20", size = 22, angle = 90, hjust = .5, vjust = .5, face = "plain"))
p5 = p5 + guides(fill=guide_legend(title="Regions"))
p5 = p5 + theme(legend.title = element_text(color = "grey20",size = 18), legend.text = element_text(color = "grey20",size = 15))  + theme(legend.title=element_blank())
#p5 = p5 + geom_text(aes(label=sum_crimes_year))

p5

p52 = ggplot(crimes_plot3, aes(fill=REGION, y=sum_crimes_reduced, x=Ano))
p52 = p52 + geom_line(position="stack", stat="identity", aes(color=REGION), size=1.5)
p52 = p52 + labs(x = 'Year', y = 'Total Crimes x 10^5', title='Total Crimes for All Years and Regions', color='')
p52 = p52 + theme_bw() + theme(plot.title=element_text(size =rel(2), hjust=0, color='blue' ))
p52 = p52 + theme(axis.text.x = element_text(color = "grey20", size = 15, angle = 0, hjust = .5, vjust = .5, face = "plain"),
                  axis.text.y = element_text(color = "grey20", size = 15, angle = 0, hjust = 1, vjust = 0, face = "plain"),
                  axis.title.y = element_text(color = "black", size = 22, angle = 90, hjust = .5, vjust = .5, face = "plain"),
                  axis.title.x = element_text(color = "black", size = 20, angle = 0, hjust = .5, vjust = 0, face = "plain"))
p52 = p52 + guides(fill=guide_legend(title="Regions"))
p52 = p52 + theme(legend.title = element_text(color = "grey20",size = 18), legend.text = element_text(color = "grey20",size = 15))

p52

"""- This chart shows that even though the crime rate overall had changed to lower level, the proportion of each region on the total remains almost the same."""

p8= ggplot(crimes_plot3, aes(Ano, sum_crimes)) +   
  geom_bar(aes(fill = REGION), position = "dodge", stat="identity")
p8 = p8 + guides(fill=guide_legend(title="Regions"))
p8 = p8+ labs(x = 'Year', y = 'Total Crimes', title='Total Crimes For All Years and Regions')
p8 = p8+ theme_bw() + theme(plot.title=element_text(size =rel(2), hjust=0, color='blue' ))
p8 = p8+ theme(axis.text.x = element_text(color = "grey20", size = 15, angle = 0, hjust = .5, vjust = .5, face = "plain"),
               axis.text.y = element_text(color = "grey20", size = 15, angle = 0, hjust = 1, vjust = 0, face = "plain"),  
               axis.title.x = element_text(color = "grey20", size = 20, angle = 0, hjust = .5, vjust = 0, face = "plain"),
               axis.title.y = element_text(color = "grey20", size = 22, angle = 90, hjust = .5, vjust = .5, face = "plain"))

p8 = p8  + theme(legend.title=element_blank())

p8

p88= ggplot(crimes_plot3, aes(reorder(REGION, -sum_crimes), sum_crimes/10000)) +   
  geom_bar(aes(fill = factor(Ano)), position = "dodge", stat="identity")
p88 = p88 + guides(fill=guide_legend(title="Regions"))
p88 = p88+ labs(x = 'Region', y = 'Total Crimes x 10^-4', title='Total Crimes For All Regions and Years')
p88 = p88+ theme_bw() + theme(plot.title=element_text(size =rel(2), hjust=0, color='blue' ))
p88 = p88+ theme(axis.text.x = element_text(color = "grey20", size = 15, angle = 0, hjust = .5, vjust = .5, face = "plain"),
                 axis.text.y = element_text(color = "grey20", size = 15, angle = 0, hjust = 1, vjust = 0, face = "plain"),  
                 axis.title.x = element_text(color = "grey20", size = 20, angle = 0, hjust = .5, vjust = 0, face = "plain"),
                 axis.title.y = element_text(color = "grey20", size = 22, angle = 90, hjust = .5, vjust = .5, face = "plain"))
p88=p88 + scale_x_discrete(labels=c('Alentejo' = "Alent.", 'Algarve' = "Algar.", '�rea Metropolitana de Lisboa'= "Reg.Lis.",
                                    'Regi�o Aut�noma da Madeira' = "Madei.", 'Regi�o Aut�noma dos A�ores' = "A�or.",
                                    'Centro' = "Centro", 'Norte' = "Norte"))
p88 = p88  + theme(legend.title=element_blank())
p88=p88 + theme(legend.title = element_text(color = "grey20",size = 18), legend.text = element_text(color = "grey20",size = 15))  + theme(legend.title=element_blank())

p88

crimes_plot3

p8_= ggplot(crimes_plot3, aes(sum_crimes,REGION )) +   
  geom_bar(aes(fill = Ano), position = "dodge", stat="identity")
p8_ = p8_ + guides(fill=guide_legend(title="Regions"))
p8_ = p8_+ labs(x = 'Year', y = 'Total Crimes', title='Total Crimes For All Years and Regions')
p8_ = p8_+ theme_bw() + theme(plot.title=element_text(size =rel(1), hjust=0, color='blue' ))
p8_ = p8_+ theme(axis.text.x = element_text(color = "grey20", size = 15, angle = 0, hjust = .5, vjust = .5, face = "plain"),
                 axis.text.y = element_text(color = "grey20", size = 15, angle = 0, hjust = 1, vjust = 0, face = "plain"),  
                 axis.title.x = element_text(color = "grey20", size = 20, angle = 0, hjust = .5, vjust = 0, face = "plain"),
                 axis.title.y = element_text(color = "grey20", size = 22, angle = 90, hjust = .5, vjust = .5, face = "plain")
                 
                 
)


p8_ = p8_  + theme(legend.title=element_blank())

p8_



"""**Plotar gr�fico per capita** -> desse tipo"""

p9 = ggplot(crimes_plot3, aes(fill=reorder(REGION, desc(-sum_crimes)), y=sum_crimes, x=Ano))
p9 = p9 + geom_bar(position="fill", stat="identity")
p9 = p9 + labs(x = 'Year', y = '%  of Total Crimes', title='Contributions for total crimes', subtitle=' of each region per year' ) 
p9 = p9 + theme_bw() + theme(plot.title=element_text(size =rel(2), hjust=0, color='blue' ), plot.subtitle = element_text(size=rel(1.5),hjust=0, color='blue'))
p9 = p9 + theme(axis.text.x = element_text(color = "grey20", size = 15, angle = 0, hjust = .5, vjust = .5, face = "plain"),
                axis.text.y = element_text(color = "grey20", size = 15, angle = 0, hjust = 1, vjust = 0, face = "plain"),  
                axis.title.x = element_text(color = "grey20", size = 20, angle = 0, hjust = .5, vjust = 0, face = "plain"),
                axis.title.y = element_text(color = "grey20", size = 22, angle = 90, hjust = .5, vjust = .5, face = "plain"))
p9 = p9 + guides(fill=guide_legend(title="Regions")) 
p9 = p9 + scale_y_continuous(labels = scales::percent_format())
p9 = p9 + theme(legend.title = element_text(color = "grey20",size = 18), legend.text = element_text(color = "grey20",size = 15))  + theme(legend.title=element_blank())

p9

"""  - **Nothing new to say about this chart**"""

multiplot(p5, p9, cols=1)

multiplot(p5, p8, cols=1)

p6 = ggplot(data=crimes_plot3, aes(fill=REGION, y=sum_crimes, x=reorder(REGION, -sum_crimes))) + 
  geom_bar(position="dodge", stat="identity") +
  facet_wrap(~Ano) +
  labs(x = 'Region', y = 'Total Crimes', title='Total Crimes per Year per Region') +
  theme_bw()+ theme(axis.text.x=element_blank()) + theme(plot.title=element_text(size =rel(1.5), hjust=0, color='blue' )) +
  theme(axis.text.y = element_text(color = "grey20", size = 12, angle = 0, hjust = 1, vjust = 0, face = "plain"),
        axis.title.y = element_text(color = "grey20", size = 15, angle = 90, hjust = .5, vjust = .5, face = "plain"),
        axis.title.x = element_text(color = "grey20", size = 15, angle = 0, hjust = .5, vjust = 0, face = "plain"))
p6 = p6 + guides(fill=guide_legend(title="Regions"))

p6

"""  - **Nothing new to talk about this one**"""

p7 = ggplot(data=crimes_plot3, aes(fill=factor(Ano), y=sum_crimes, x=Ano)) + 
  geom_bar(position="dodge", stat="identity") +
  facet_wrap(~REGION) +
  labs(x = 'Ano', y = 'Total Crimes', title='Total Crimes per Region per Year') +
  theme_bw()+ theme(axis.text.x=element_blank()) + theme(plot.title=element_text(size =rel(1.5), hjust=0, color='blue' )) +
  theme(axis.text.y = element_text(color = "grey20", size = 12, angle = 0, hjust = 1, vjust = 0, face = "plain"),
        axis.title.y = element_text(color = "grey20", size = 15, angle = 90, hjust = .5, vjust = .5, face = "plain"),
        axis.title.x = element_text(color = "grey20", size = 15, angle = 0, hjust = .5, vjust = 0, face = "plain"))
p7= p7    + guides(fill=guide_legend(title="Years"))   

p7

"""This chart shows that Alentejo, Algarve, A�ores and Madeira regions are almost constat over this period of time. Then, we can conclude that the reduction of crimes in Portugal comes mainly from Lisbon, North and Center region.

Julio: I think this chart is better plotet on lines instead of bars
"""

crimes_plot2 <- crimes %>%
  rename( intermunicipal = "INTERMUNICIPAL COMMUNITY") %>%
  group_by ( Ano) %>%
  arrange ( Ano ) %>% ## to make sure it is sorted
  #mutate ( seq = row_number() ) %>% ## seq within country
  mutate ( sum_crimes = sum( Total ) ) %>% ## cumulative sums
  #mutate ( MedianaCrimesAno = median( Total )) %>% ## cumulative sums
  #ungroup() %>% ## remove grouping 
  select(Ano, sum_crimes) %>%
  distinct()

p2 = ggplot( data = crimes_plot2 )
p2 = p2 + geom_col( aes(x = Ano , y = sum_crimes/100000) , alpha = 0.8, color='red')
p2 = p2 + labs(x = 'Year', y = 'Total Crimes For All Regions x 10^-5', title='Total Crimes From 2011 to 2018 in Portugal')
p2 = p2 + theme_bw() + theme(plot.title=element_text(size =rel(2), hjust=0, color='blue' ))
p2 = p2 + theme(axis.text.x = element_text(color = "grey20", size = 15, angle = 0, hjust = .5, vjust = .5, face = "plain"),
                axis.text.y = element_text(color = "grey20", size = 15, angle = 0, hjust = 1, vjust = 0, face = "plain"),  
                axis.title.x = element_text(color = "grey20", size = 20, angle = 0, hjust = .5, vjust = 0, face = "plain"),
                axis.title.y = element_text(color = "grey20", size = 22, angle = 90, hjust = .5, vjust = .5, face = "plain"))
p2

"""- This chart was already ploted using df1 dataset

##Unemployment Rate
"""

# unemployment rate from 2011 to 2019

head(unemploy)

