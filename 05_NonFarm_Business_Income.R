# =================== Non-farm business Income SAS Data - 77th Round of NSSO =================== #

# Author: Sethu C. A.
# License: GNU GPLv3

#  This is script 5 of 7
#  This work is inspired by Deepak Johnson's work here: https://github.com/deepakjohnson91/NSSO-77-Round-SAS/

#  Documentation on and data/readme files available at https://www.mospi.gov.in/unit-level-data-report-nss-77-th-round-schedule-331-january-2019-%E2%80%93-december-2019land-and-livestock
#  One level - 13 - deals with the non-farm business income. 
#  The estimation in the NSSO report for reporting the total income (table 23-A) is done at the level of agricultural households. 
#  NSSO collects data for the last 30 days.
#  Serial no 99 is to be filtered if we want total per household.
#  The reported NBI income for V 1 is Rs 641 per month and Rs 638 per month for V 2. It is  Rs. 641 for both. 


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
load("Output/All_HH_Basic.Rdata")
load("Output/Common_HH_Basic.Rdata")
load("Output/AH_Common_HH_Basic.Rdata")


# Read in relevant level codes
Level13Codes <- read_excel("List_Level_Codes.xlsx", sheet = "Level13")

# Read Level 13 data which contains output information

# Load the data for given level from the fixed width file provided into a data frame using the byte lengths provided in the level codes file
# The name of the data frame has the following logic: Level 13 in Visit 1
L13_V1 <- read_fwf("Raw data/r77s331v1L13.txt", 
                   fwf_widths(widths = Level13Codes$Length),
                   col_types = cols(
                     X12 = col_character(),                 #RANT from before
                     .default = col_number()
                   ))

# Add column names to the data frame after sanitizing them as valid variable names
colnames(L13_V1) <- make.names(Level13Codes$Name)


# Create a common ID for all households as per documentation.
L13_V1 <- L13_V1 %>%
  mutate(HH_ID = paste(FSU.Serial.No.,Second.stage.stratum.no.,Sample.hhld..No., sep = "0"))


# Task: Create a data frame with Non-Farm Business Income

# First we need the gross value of output from Level 11 data
# We need only those observations which are the total value of all businesses for each household, i.e. with one observation per household (Sl.no 99 in the questionnaire block) 
# So we filter out only 99 from Sl no first
# Now, We need only the net recepits column from this
# We need to join that against the basic Household info data frame we already made earlier.
# Let us name this data frame using the logic: Non-farm Business Income from Visit 1

NBI_V1 <- left_join(All_HH_Basic, L13_V1 %>%
                      filter(L13_V1$Serial.no. == 99) %>%
                      select(c(HH_ID, Net.receipts.col.5...col.4.)),
                    by = "HH_ID")

# Replace NA with 0
NBI_V1[is.na(NBI_V1)] <- 0

# Now visit 2

# Load data
L13_V2 <- read_fwf("Raw data/r77s331v2L13.txt", 
                   fwf_widths(widths = Level13Codes$Length),
                   col_types = cols(
                     X12 = col_character(),                 #RANT from before
                     .default = col_number()
                   ))
colnames(L13_V2) <- make.names(Level13Codes$Name)
L13_V2 <- L13_V2 %>%
  mutate(HH_ID = paste(FSU.Serial.No.,Second.stage.stratum.no.,Sample.hhld..No., sep = "0"))

# Make NBI V2, but using Common_HH_Basic instead of All_HH_Basic because the former has visit 2 data alone.
NBI_V2 <- left_join(Common_HH_Basic, L13_V2 %>%
                      filter(L13_V2$Serial.no. == 99) %>%
                      select(c(HH_ID,Net.receipts.col.5...col.4.)),
                    by = "HH_ID")
#Replace NAs
NBI_V2[is.na(NBI_V2)] <- 0


# Now merge both
NBI <- left_join(NBI_V1, NBI_V2 %>%
                   select(c(1, 11, 12)),
                 by = "HH_ID")
#Replace NAs
NBI[is.na(NBI)] <- 0

# Create column for monthly calculation. Info is collected for 30 days with weight of 8 months in visit 1 and 4 months in visit 2.
NBI$MonthlyNBI <- ((NBI$Net.receipts.col.5...col.4..x * 8) + (NBI$Net.receipts.col.5...col.4..y * 4))/12

# subset this to create Agricultural Households subset
AH_NBI <- NBI %>% filter(HH_ID %in% AH_Common_HH_Basic$HH_ID)

# Run the tests

wtd.mean(AH_NBI$MonthlyNBI, weights = AH_NBI$Weights_V2)
# We get 640.5397 which can be rounded to the reported 641

wtd.mean(AH_NBI$Net.receipts.col.5...col.4..y, weights = AH_NBI$Weights_V2)
# We get 637.76 which matches with 638 in the report

wtd.mean(AH_NBI$Net.receipts.col.5...col.4..x, weights = AH_NBI$Weights_V1)
# We get 640.9731 which matches 641 in the report

# End

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
