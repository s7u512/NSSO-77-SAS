#  =================== Animal Income (only paid-out costs) SAS Data - SAS Data - 77th Round of NSSO =================== # 

# Author: Sethu C. A.
# License: GNU GPLv3

#  This is script 3 of 6
#  This work is inspired by Deepak Johnson's work here: https://github.com/deepakjohnson91/NSSO-77-Round-SAS/


#  Documentation on and data/readme files available at https://www.mospi.gov.in/unit-level-data-report-nss-77-th-round-schedule-331-january-2019-%E2%80%93-december-2019land-and-livestock
#  The blocks associated with animal resources - expenditure and income - are 9 and 10 (from the schedule). 
#  NSSO collects data for the last 30 days.
#  Block 9 serial no. 16 and block 10 serial no. 18 is to be checked  - to filter out total value and costs per household.
#  The layout file shows that Level 11 and 12 correspond to the information needed from these blocks. 
#  The weights of Visit 2 have to be used while combining data from both visits. (This is stated in the documentation as well.)
#  The report gives the animal income for V1 as Rs 1,598 per month and V2 as Rs 1,552 per month and for combined as Rs, 1,582 per month

#  Issues: V1 and V2 figures are not matching with the report

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


# Read in relevant level codes
Level11Codes <- read_excel("List_Level_Codes.xlsx", sheet = "Level11")
Level12Codes <- read_excel("List_Level_Codes.xlsx", sheet = "Level12")

# Read Level 7 data which contains output information

# Load the data for given level from the fixed width file provided into a data frame using the byte lengths provided in the level codes file
# The name of the data frame has the following logic: Level 11 in Visit 1
L11_V1 <- read_fwf("Raw data/r77s331v1L11.txt", 
                      fwf_widths(widths = Level11Codes$Length),
                      col_types = cols(
                        X12 = col_character(),                 #RANT from before
                        .default = col_number()
                      ))

# Add column names to the data frame after sanitizing them as valid variable names
colnames(L11_V1) <- make.names(Level11Codes$Name)


# Create a common ID for all households as per documentation.
L11_V1 <- L11_V1 %>%
  mutate(HH_ID = paste(FSU.Serial.No.,Second.stage.stratum.no.,Sample.hhld..No., sep = "0"))

# Now level 12
L12_V1 <- read_fwf("Raw data/r77s331v1L12.txt", 
                   fwf_widths(widths = Level12Codes$Length),
                   col_types = cols(
                     X12 = col_character(),                 #RANT from before
                     .default = col_number()
                   ))
colnames(L12_V1) <- make.names(Level12Codes$Name)
L12_V1 <- L12_V1 %>%
  mutate(HH_ID = paste(FSU.Serial.No.,Second.stage.stratum.no.,Sample.hhld..No., sep = "0"))


# Task: Create a data frame with AnimalIncome

# First we need the gross value of output from Level 11 data
# For this we need to select only total value, i.e, with one observation per household (Sl. no. 16 in the questionnaire block) from Level 7 data
# Further, We need only the total value column from Level 11 data
# We need to join that against the basic Household info data frame we already made earlier.

AnimalIncome_V1 <- left_join(All_HH_Basic, L11_V1 %>%
                               filter(Serial.no. == 16) %>%
                               select(HH_ID, total.produce..value.Rs.),
                             by = "HH_ID")

# Now we add costs from L12 to that
# After filtering Sl. no. 18 alone out, we select only the paid out expenses column and add it to this.

AnimalIncome_V1 <- left_join(AnimalIncome_V1, L12_V1 %>%
                               filter(Serial.no. == 18) %>%
                               select(HH_ID, paid.out.expenses),
                             by = "HH_ID")

# Replace NA with 0
AnimalIncome_V1[is.na(AnimalIncome_V1)] <- 0

# Add the calculated column Animal income from last month as the difference between total produce value and paid out expenses
AnimalIncome_V1$AnimalIncomeLastMonth = AnimalIncome_V1$total.produce..value.Rs. - AnimalIncome_V1$paid.out.expenses


# Add animal income from 8 months as 8 * animal income from last month as visit 1 is for 8 months
AnimalIncome_V1$AnimalIncome_V1 = AnimalIncome_V1$AnimalIncomeLastMonth * 8


# Now visit 2

# Load data

L11_V2 <- read_fwf("Raw data/r77s331v2L11.txt", 
                   fwf_widths(widths = Level11Codes$Length),
                   col_types = cols(
                     X12 = col_character(),                 #RANT from before
                     .default = col_number()
                   ))
colnames(L11_V2) <- make.names(Level11Codes$Name)
L11_V2 <- L11_V2 %>%
  mutate(HH_ID = paste(FSU.Serial.No.,Second.stage.stratum.no.,Sample.hhld..No., sep = "0"))


L12_V2 <- read_fwf("Raw data/r77s331v2L12.txt", 
                   fwf_widths(widths = Level12Codes$Length),
                   col_types = cols(
                     X12 = col_character(),                 #RANT from before
                     .default = col_number()
                   ))
colnames(L12_V2) <- make.names(Level12Codes$Name)
L12_V2 <- L12_V2 %>%
  mutate(HH_ID = paste(FSU.Serial.No.,Second.stage.stratum.no.,Sample.hhld..No., sep = "0"))


# Now make the Animal Income data frame again
# But use Common_HH_Basic not All_HH_Basic because the former has the visit 2 data alone.

AnimalIncome_V2 <- left_join(Common_HH_Basic, L11_V2 %>%
                               filter(Serial.no. == 16) %>%
                               select(HH_ID, total.produce..value.Rs.),
                             by = "HH_ID")

AnimalIncome_V2 <- left_join(AnimalIncome_V2, L12_V2 %>%
                               filter(Serial.no. == 18) %>%
                               select(HH_ID, paid.out.expenses),
                             by = "HH_ID")

# Replace NA with 0
AnimalIncome_V2[is.na(AnimalIncome_V2)] <- 0

# Add the calculated column Animal income as the difference between total produce value and paid out expenses
AnimalIncome_V2$AnimalIncomeLastMonth = AnimalIncome_V2$total.produce..value.Rs. - AnimalIncome_V2$paid.out.expenses

# Add animal income from 4 months as 4 * animal income from last month as visit 2 is for 4 months
AnimalIncome_V2$AnimalIncome_V2 = AnimalIncome_V2$AnimalIncomeLastMonth * 4



# Now for total animal income
# We will join Visit 1 and visit 2 data

AnimalIncome <- left_join(AnimalIncome_V1, AnimalIncome_V2 %>%
                            select(c(1,11:15)),        # We only need to merge these columns
                          by = "HH_ID" )
# Replace NAs
AnimalIncome[is.na(AnimalIncome)] <- 0


# The animal incomes in visit 1 and visit 2 are collected for last month, and visit 1 is for 8 months, while visit 2 is for 4
# Therefore total animal income is the sum of that

AnimalIncome$TotalAnimalIncome = AnimalIncome$AnimalIncome_V1 + AnimalIncome$AnimalIncome_V2
AnimalIncome$MonthlyAnimalIncome = ((AnimalIncome$AnimalIncomeLastMonth.x * 8) + (AnimalIncome$AnimalIncomeLastMonth.y * 4))/12

# Create a subset of agricultural households alone
AH_AnimalIncome <- AnimalIncome %>% filter(HH_ID %in% AH_Common_HH_Basic$HH_ID)


# Time to run tests

# The report gives the animal income for V1 as Rs 1,598 per month and V2 as Rs 1,552 per month and for combined as Rs, 1,582 per month

# Issue 1: We need to check this visit 1 and visit 2 figures properly. Various things I tried are not giving those figures

wtd.mean(AH_AnimalIncome$AnimalIncome_V1, weights = AH_AnimalIncome$Weights_V1)/8 
wtd.mean(AH_AnimalIncome$AnimalIncomeLastMonth.x, weights = AH_AnimalIncome$Weights_V1)
# We keep getting 1593.022, not 1598 as in the report
wtd.mean(AH_AnimalIncome$AnimalIncomeLastMonth.x, weights = AH_AnimalIncome$Weights_V2)
# We get 1599 here interestingly though this is not a sensible calculation


wtd.mean(AH_AnimalIncome$AnimalIncome_V2, weights = AH_AnimalIncome$Weights_V2)/4
wtd.mean(AH_AnimalIncome$AnimalIncomeLastMonth.y, weights = AH_AnimalIncome$Weights_V2)
# We keep getting 1548.685, not 1552 as in the report


# However, the combined figure is correct. But this needs to be taken with suspicion given prev figures
wtd.mean(AH_AnimalIncome$MonthlyAnimalIncome, weights = AH_AnimalIncome$Weights_V2)
wtd.mean(AH_AnimalIncome$TotalAnimalIncome, weights = AH_AnimalIncome$Weights_V2)/12
# We keep getting 1582.476 which matches with 1582 as given in the report.

# Note: Page 10 of the report says: "Wherever information is collected for the reference period of last 30 days combined aggregate is calculated as a weighted mean of estimates for common households of visit-1 and visit-2 where the weights are 8 and 4 respectively as the survey period of visit-1 and visit-2 were 8 and 4 months, respectively."



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