#  =================== Crop Income (only paid-out costs) - SAS Data - 77th Round of NSSO =================== # 

# Author: Sethu C. A.
# License: GNU GPLv3

#  This is script 2 of 6
#  This work is inspired by Deepak Johnson's work here: https://github.com/deepakjohnson91/NSSO-77-Round-SAS/


#  Documentation on and data/readme files available at https://www.mospi.gov.in/unit-level-data-report-nss-77-th-round-schedule-331-january-2019-%E2%80%93-december-2019land-and-livestock
#  Two levels - 7 and 8 - deal with total value crop production. 
#  Level 7 - total value and Level 8 - costs of inputs. 
#  The estimation in the NSSO report for reporting the total income (table 23-A) is done at the level of agricultural households. 
#  The logic is to merge the two levels with the list of agri HHs and then estimate using the weights for all agri HHs (weights given in Visit 2).
#  The reported crop income for V 1 is Rs 4,001 per month and Rs 3,584 per month for V 2. 

rm(list = ls())         # clear the environment

#  Load packages
library(readxl)         #  for reading excel files
library(readr)          #  for reading fixed width files in a fast and consistent manner compared to the 'foreign' library
library(dplyr)          #  tidyverse package for data manipulation
library(tidyr)          #  tidyverse package for data cleaning
library(Hmisc)          #  for for weighted mean, etc.

# Set working directory
setwd("path/to/working/directory") 

# Load relevant data prepared earlier
load("Output/All_HH_Basic.Rdata")
load("Output/Common_HH_Basic.Rdata")
load("Output/AH_Common_HH_Basic.Rdata")

# Read in level codes for levels 7 and 8 to data frames
Level7Codes <- read_excel("List_Level_Codes.xlsx", sheet = "Level7")
Level8Codes <- read_excel("List_Level_Codes.xlsx", sheet = "Level8")

# Read Level 7 data which contains output information

# Load the data for given level from the fixed width file provided into a data frame using the byte lengths provided in the level codes file
# The name of the data frame has the following logic: Level 7 in Visit 1
L7_V1 <- read_fwf("Raw data/r77s331v1L07.txt", 
                   fwf_widths(widths = Level7Codes$Length),
                   col_types = cols(
                     X12 = col_character(),                 #RANT from before
                     .default = col_number()
                   ))

# Add column names to the data frame after sanitizing them as valid variable names
colnames(L7_V1) <- make.names(Level7Codes$Name)


# Create a common ID for all households as per documentation.
L7_V1 <- L7_V1 %>%
  mutate(HH_ID = paste(FSU.Serial.No.,Second.stage.stratum.no.,Sample.hhld..No., sep = "0"))

# Now level 8
L8_V1 <- read_fwf("Raw data/r77s331v1L08.txt", 
                  fwf_widths(widths = Level8Codes$Length),
                  col_types = cols(
                    X12 = col_character(),                 #RANT from before
                    .default = col_number()
                  ))

# Add column names to the data frame after sanitizing them as valid variable names
colnames(L8_V1) <- make.names(Level8Codes$Name)

# Create a common ID for all households as per documentation.
L8_V1 <- L8_V1 %>%
  mutate(HH_ID = paste(FSU.Serial.No.,Second.stage.stratum.no.,Sample.hhld..No., sep = "0"))




# Task: Create a data frame with CropIncome

# First we need the gross value of output from Level 7 data
# For this we need to select only total value of all crops, i.e, with one observation per household (Sl. no. 9 in the questionnaire block) from Level 7 data
# Further, We need only the total value column from Level 7 data
# We need to join that against the basic Household info data frame we already made earlier.
# So let us approach this challenge

CropIncome_V1 <- left_join(All_HH_Basic, L7_V1 %>%                     # We are leftjoining, but first filter the GVO_7_V1
                             filter(Srl.No. == 9) %>%                  # Only where serial no. = 9 because we only want total value of all crops
                             select(HH_ID, total.value..Rs..),         # Only selecting HH_ID and total value columns
                           by = "HH_ID")                               # The column by which join happens is HH_ID as it is unique and present in both data frames

# Now we need costs from Level 8 data
# Similar to before, we need to select only the total costs of all crops, i.e., with one observation per household (Sl. no. 22 in the questionnaire block) from Level 8 data
# And similar to before, we only need the column with paid out expenses of inputs from this subset.
# We would join this column to the crop income data frame

CropIncome_V1 <- left_join(CropIncome_V1, L8_V1 %>%
                             filter(Serial.no. == 22) %>%
                             select(HH_ID, Inputs.paid.out.expenses),
                           by = "HH_ID"
)

# Now Calculate Crop Income by taking the difference between GVO and Costs
# But before that replace NA with 0
CropIncome_V1[is.na(CropIncome_V1)] <- 0

CropIncome_V1 <- CropIncome_V1 %>% 
  mutate(CropIncome = total.value..Rs.. - Inputs.paid.out.expenses)



# Now visit 2

# Load data
L7_V2 <- read_fwf("Raw data/r77s331v2L07.txt", 
                   fwf_widths(widths = Level7Codes$Length),
                   col_types = cols(
                     X12 = col_character(),                #RANT from before
                     .default = col_number()
                   ))

# Add column names to the data frame after sanitizing them as valid variable names
colnames(L7_V2) <- make.names(Level7Codes$Name)


# Create a common ID for all households as per documentation.
L7_V2 <- L7_V2 %>%
  mutate(HH_ID = paste(FSU.Serial.No.,Second.stage.stratum.no.,Sample.hhld..No., sep = "0"))


# Load data
L8_V2 <- read_fwf("Raw data/r77s331v2L08.txt", 
                   fwf_widths(widths = Level8Codes$Length),
                   col_types = cols(
                     X12 = col_character(),                 #RANT from before
                     .default = col_number()
                   ))

# Add column names to the data frame after sanitizing them as valid variable names
colnames(L8_V2) <- make.names(Level8Codes$Name)


# Create a common ID for all households as per documentation.
L8_V2 <- L8_V2 %>%
  mutate(HH_ID = paste(FSU.Serial.No.,Second.stage.stratum.no.,Sample.hhld..No., sep = "0"))

# Like before, we are preparing crop incomes for V2
# First we take GVO from Level 7 data
# And note that we merge it to Common_HH_Basic instead of All_HH_Basic because the former has visit 2 households alone.
CropIncome_V2 <- left_join(Common_HH_Basic, L7_V2 %>%             
                             filter(Srl.No. == 9) %>%                  # Only where serial no. = 9 because we only want total value of all crops
                             select(HH_ID, total.value..Rs..),         # Only selecting HH_ID and total value columns
                           by = "HH_ID") 

# Next we add costs from Level 8 to that
CropIncome_V2 <- left_join(CropIncome_V2, L8_V2 %>%
                             filter(Serial.no. == 22) %>%
                             select(HH_ID, Inputs.paid.out.expenses),
                           by = "HH_ID"
                           )


# Replace NAs
CropIncome_V2[is.na(CropIncome_V2)] <- 0


# Calculate Crop income by taking the difference between GVO and costs
CropIncome_V2$CropIncome = CropIncome_V2$total.value..Rs.. - CropIncome_V2$Inputs.paid.out.expenses

# Now for total crop income  
# We join both V1 and V2 crop incomes.

CropIncome <- left_join(CropIncome_V1, CropIncome_V2 %>% 
                          select(c(1, 11:14)),            #We only need these columns to be merged to CropIncomesV1 as the rest are repeating
                        by = "HH_ID"
                          )
# Replace NAs
CropIncome[is.na(CropIncome)] <- 0

# Create new column total crop income in this
CropIncome$TotalCropIncome = CropIncome$CropIncome.x + CropIncome$CropIncome.y

# Create a subset of crop incomes for agricultural households
AH_CropIncome <- CropIncome %>% filter(HH_ID %in% AH_Common_HH_Basic$HH_ID)
    
# Test the results

# Let us check the monthly Crop Income from Visit 1. For this, we take the weighted mean of the crop incomes and weights from visit 1, and divide it by 6 because it is for 6 months.
wtd.mean(AH_CropIncome$CropIncome.x, weights = AH_CropIncome$Weights_V1)/6  
#We get 4000.749 which matches with 4001 in the report.

# Let us check the monthly Crop Income from Visit 2. For this, we take the weighted mean of the crop incomes and weights from visit 2, and divide it by 6 because it is for 6 months.
wtd.mean(AH_CropIncome$CropIncome.y, weights = AH_CropIncome$Weights_V2)/6
#We get 3583.748 which matches with 3584 in the report.

# Let us check the monthly Crop Income combined.
wtd.mean(AH_CropIncome$TotalCropIncome, weights = AH_CropIncome$Weights_V2)/12
# We get 3798.236 which matches with 3798 in the report

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