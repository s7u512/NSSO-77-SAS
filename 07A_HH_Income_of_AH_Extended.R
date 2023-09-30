# =================== Household Income Extended of Agri HHs SAS Data - 77th Round of NSSO =================== #

# Author: Sethu C. A.
# License: GNU GPLv3

#  This is script 8 of 7
#  This work is inspired by Deepak Johnson's work here: https://github.com/deepakjohnson91/NSSO-77-Round-SAS/

#  Documentation on and data/readme files available at https://www.mospi.gov.in/unit-level-data-report-nss-77-th-round-schedule-331-january-2019-%E2%80%93-december-2019land-and-livestock
#  Combine all incomes - crop, animal, non-farm business, and the others (wages, pensions and rent) 
#  The estimation in the NSSO report for reporting the total income (table 23-A) is done at the level of agricultural households. 
#  The plan is to load all the pre-arranged datasets and then combine them. 
#  The reported HH income for all agri HHs is Rs 10,218 per month  (V 1 + V 2).


rm(list = ls())         # clear the environment

#  Load packages
library(readxl)         #  for reading excel files
library(readr)          #  for reading fixed width files in a fast and consistent manner compared to the 'foreign' library
library(dplyr)          #  tidyverse package for data manipulation
library(tidyr)          #  tidyverse package for data cleaning
library(Hmisc)          #  for for weighted mean, etc.
library(data.table)     #  for exporting data in a fast manner

# Set working directory
setwd(".") # change this path to your specific directory before running the script if you downloaded all the code instead of cloning the repo.

# Load relevant data prepared earlier
load("Output/AH_Common_HH_Basic.Rdata")
load("Output/AH_CropIncome.Rdata")
load("Output/AH_ImputedCropIncome.Rdata")
load("Output/AH_AnimalIncome.Rdata")
load("Output/AH_AnimalIncomeExtended.Rdata")
load("Output/AH_NBI.Rdata")
load("Output/AH_Other_Income.Rdata")
load("Output/AH_Common_HH_Basic_with_Land_total.Rdata")
# Merge all data frames into the final big data frame

AH_Household_Income_Extended <- 
  left_join(AH_Common_HH_Basic, AH_ImputedCropIncome %>% 
              select(-c(2:10,15)), by = "HH_ID") %>%
  left_join(AH_CropIncome %>%
               select(1,13,17,18), by = "HH_ID") %>%
  left_join(AH_AnimalIncomeExtended %>% 
              select(-c(2:10, 18)),by = "HH_ID") %>%
  left_join(AH_NBI %>%
              select(-c(2:10,12)), by = "HH_ID") %>%
  left_join(AH_Other_Income %>%
              select(-c(2:10,14)), by = "HH_ID")

# Replaces NA with 0 just to be sure
AH_Household_Income_Extended[is.na(AH_Household_Income_Extended)] <- 0

# Create standardized monthly income variables where required
AH_Household_Income_Extended <- AH_Household_Income_Extended %>%
  mutate(
    across(c(TotalCropIncome, TotalImputedCropIncome, Wages, Pensions, Lease_Rent), ~./12, .names = "Monthly{col}"),
  )
# Note that we did not do this for Animal Incomes and Non-farm Business Incomes. This is because we made them in the earlier data set itself, as MonthlyAnimalIncome and MonthlyNBI respectively

# Create monthly HH Income by adding all except pensions
AH_Household_Income_Extended <- AH_Household_Income_Extended %>%
  mutate(
    Household_Income_Monthly = MonthlyTotalCropIncome + MonthlyAnimalIncome + MonthlyNBI + MonthlyWages + MonthlyLease_Rent,
    Household_Income_Monthly_Imputed = MonthlyTotalImputedCropIncome + MonthlyImputedAnimalIncome + MonthlyNBI + MonthlyWages + MonthlyLease_Rent
    )

# Let us bring in the land size classification to be used for both visits, collected in Block 5.1 (found in Level 19) of Visit 2
# We had prepared this earlier in AH_Common_HH_Basic_with_Land_total
# Add the relevant column to the essentials data frame
AH_Household_Income_Extended <- left_join(AH_Household_Income_Extended, AH_Common_HH_Basic_with_Land_total %>%
                                            select(HH_ID, land_possessed_ha_total, size_class_of_land_possessed_ha_total),
                                          by = "HH_ID")


# Check if data is correct
wtd.mean(AH_Household_Income_Extended$Household_Income_Monthly, weights = AH_Household_Income_Extended$Weights_V2)
# We get 10218.18 which matches with the report that gave Rs. 10,218 BABYYYYY!!!!!!

wtd.mean(AH_Household_Income_Extended$Household_Income_Monthly_Imputed, weights = AH_Household_Income_Extended$Weights_V2)
# We get 8336.774 which matches with the report that gave Rs. 8,337 BABYYYYY!!!!!!


# Finally let us make a shorter version of this data frame with just the essential columns for brevity
AH_Household_Income_Extended_Essentials <- AH_Household_Income_Extended[,c("HH_ID","Weights_V2","State","Household.size","Religion.code","Social.group.code","Household.classification..code", "land_possessed_ha_total", "size_class_of_land_possessed_ha_total", "MonthlyTotalCropIncome", "MonthlyTotalImputedCropIncome", "MonthlyAnimalIncome", "MonthlyImputedAnimalIncome", "MonthlyNBI", "MonthlyWages", "MonthlyLease_Rent", "MonthlyPensions", "Household_Income_Monthly", "Household_Income_Monthly_Imputed")]


# Run another check


Average_Incomes_by_Landsize <- AH_Household_Income_Extended_Essentials %>% 
  group_by(size_class_of_land_possessed_ha_total) %>%
  summarise(
    wages = wtd.mean(MonthlyWages, weights =  Weights_V2),
    lease = wtd.mean(MonthlyLease_Rent, weights = Weights_V2),
    crop = wtd.mean(MonthlyTotalCropIncome, weights = Weights_V2),
    crop_imputed = wtd.mean(MonthlyTotalImputedCropIncome, weights = Weights_V2),
    animal = wtd.mean(MonthlyAnimalIncome, weights = Weights_V2),
    animal_imputed = wtd.mean(MonthlyImputedAnimalIncome, weights = Weights_V2),
    business = wtd.mean(MonthlyNBI, weights = Weights_V2),
    household_income = wtd.mean(Household_Income_Monthly, weights = Weights_V2),
    household_income_imputed = wtd.mean(Household_Income_Monthly_Imputed, weights = Weights_V2)
  )

# Table matches the report (check page A-1018 (1196/4264 and 1385/4264))


# That's all folks

# Time to save the files

# I am creating a code block to iterate through all relevant data frames, and save them both as RData and csv files

# First we define an output folder
output_dir <- "Output"

# Next we get a list of objects in the global environment at the moment (NOTE: This takes all objects in the global enviroment, which means it will create confusions if you were running other codes and had other objects from other scripts in the global environment)
obj_list <- ls()

# Next we define a function that runs some checks to see if we want to save a given object in the global enviroment or not.
tobesaved <- sapply(                              # sapply applies whatever function we specify to all the elements in the list we specify
  obj_list, function(x)                          # we are taking the list tobesaved, and applying a function called x. We will define x now
  {
    is.data.frame(get(x)) &&                      # It checks if the item in the list is a data frame, and
      !startsWith(x, "Level") &&                  # It checks if the item does not start with "Level", and
      !endsWith(x, "_list")                       # It checks if the item does not end with "_list"
  }
)


# Now we just run a loop that takes each object from the list, see if it has to be saved, and then saves it if true.
for (i in obj_list[tobesaved])
{
  save(list = i, file = file.path(output_dir, paste0(i,".Rdata")))
  fwrite(get(i), file = file.path(output_dir, paste0(i,".csv")))     #fwrite is better than write.csv2 as it is faster to save big files.
}



# The End

# That's all folks
