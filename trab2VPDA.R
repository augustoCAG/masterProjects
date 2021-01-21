## importing the libraries
library(readxl)
library(tidyverse)
library(dplyr)
library(lubridate)
library(ggplot2)
library(ggthemes)
library(zoo)

## importing the datasets
df1 = read_xlsx('datasetFiltrado.xlsx')
df2 = read_xlsx('1a_crimesPortugal__EDITADO.xlsx')
df1
df2

## verifying statistics proprieties and missing values
describe_df1 = summary(df1)
describe_df1
describe_df2 = summary(df2)
describe_df2

## filling missing values with the attribute's mean/median induces bias in the variance
## it's better to use a linear regression model
## we will considered it as a MCAR - missing completely at random - missing mechanism



