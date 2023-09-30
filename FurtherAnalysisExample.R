####### Margin of Crop Incomes ###########

# This is an example of how to work with this data

rm(list = ls())         # clear the environment

#  Load packages
library(readxl)         #  for reading excel files
library(readr)          #  for reading fixed width files in a fast and consistent manner compared to the 'foreign' library
library(dplyr)          #  tidyverse package for data manipulation
library(tidyr)          #  tidyverse package for data cleaning
library(Hmisc)          #  for for weighted mean, etc.
library(data.table)     #  for exporting data in a fast manner
library(ggplot2)        #  for plotting


# Set working directory
setwd(".") # change this path to your specific directory before running the script if you downloaded all the code instead of cloning the repo.

# Load relevant data prepared earlier
load("Output/AH_Household_Income_Extended.Rdata")
load("Output/AH_Household_Income_Extended_Essentials.Rdata")


df1 <- AH_Household_Income_Extended %>% mutate(TotalGVO = total.value..Rs...x + total.value..Rs...y)

df1 <- df1 %>% mutate(
  CropMarginA2 = TotalCropIncome/TotalGVO,
  CropMarginC2 = TotalImputedCropIncome/TotalGVO
  )

df1 <- df1 %>% mutate(CropMarginA2 = ifelse(TotalGVO == 0, 0, CropMarginA2))
df1 <- df1 %>% mutate(CropMarginC2 = ifelse(TotalGVO == 0, 0, CropMarginC2))


df1[is.na(df1)] <- 0

t1 <- df1 %>% group_by(size_class_of_land_possessed_ha_total) %>%
              summarise(
                CropIncomeA2 = wtd.mean(TotalCropIncome, weights = Weights_V2),
                CropIncomeC2 = wtd.mean(TotalImputedCropIncome, weights = Weights_V2),
                A2CropMargin = wtd.mean(CropMarginA2, weights = Weights_V2),
                C2CropMargin = wtd.mean(CropMarginC2, weights = Weights_V2)
              )


t2 <- t1 %>% select(size_class_of_land_possessed_ha_total, A2CropMargin, C2CropMargin)

t2_g <- gather(t2, type, value, - size_class_of_land_possessed_ha_total)



ggplot(t2_g, aes(x = type, y = value, fill = size_class_of_land_possessed_ha_total)) + 
  geom_bar(colour = "black", stat = "identity", position = position_dodge2(width = 0.9, preserve = "total", padding = 0.1, reverse = FALSE)) + 
  geom_label(label = round(t2_g$value, 2), family = "Garamond", colour = "black", fill = "white", stat = "identity", position = position_dodge2(width = 0.9, preserve = "total", padding = 0.1, reverse = FALSE)) +
  scale_fill_brewer(palette = "YlOrRd") +
  theme(text = element_text(family = "Garamond", size = 20))
  
  