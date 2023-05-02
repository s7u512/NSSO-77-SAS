# =================== Wage, Rent, and Other Income SAS Data - 77th Round of NSSO =================== #

# Author: Sethu C. A.
# License: GNU GPLv3

#  This is script 6 of 7
#  This work is inspired by Deepak Johnson's work here: https://github.com/deepakjohnson91/NSSO-77-Round-SAS/

#  Documentation on and data/readme files available at https://www.mospi.gov.in/unit-level-data-report-nss-77-th-round-schedule-331-january-2019-%E2%80%93-december-2019land-and-livestock
#  One level - level 2 (block 3) - personal records deal with wages, pensions, and rental income. 
#  The estimation in the NSSO report for reporting the total income (table 23-A) is done at the level of agricultural households. 
#  The logic is to merge the level 3 with the list of agri HHs and then estimate using the weights for all agri HHs (weights given in Visit 2).
#  The reported incomes are as follows:
#  V 1 (per month): Wages = 3932; Lease-out = 113; Pension/remittance = 578
#  V 2 (per month): Wages = 4190; Lease-out = 157; Pension/remittance = 641
#  V 1 + 2 (per month): Wages = 4063; Lease-out = 134; Pension/remittance = 611

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
Level2Codes <- read_excel("List_Level_Codes.xlsx", sheet = "Level2")

# Read Level 2 Visit 1 data 

#Note: Information we want is given at the person level. We will first take that and then summarize to household level

# The name of the data frame has the following logic: Level 2 in Visit 1
L2_V1 <- read_fwf("Raw data/r77s331v1L02.txt", 
                   fwf_widths(widths = Level2Codes$Length),
                   col_types = cols(
                     X12 = col_character(),                 #RANT from before
                     .default = col_number()
                   ))

# Add column names to the data frame after sanitizing them as valid variable names
colnames(L2_V1) <- make.names(Level2Codes$Name)


# Create a common ID for all households as per documentation.
L2_V1 <- L2_V1 %>%
  mutate(HH_ID = paste(FSU.Serial.No.,Second.stage.stratum.no.,Sample.hhld..No., sep = "0"))


# Task: Summarise the information by household
L2_V1_HH <- L2_V1 %>%
  group_by(HH_ID) %>%
  summarise(
    Wages_V1 = sum(Wages...salary..earnings..Rs.., na.rm = TRUE),
    Pensions_V1 = sum(Earning.from.pension.remittances..Rs.., na.rm = TRUE),
    Lease_Rent_V1 = sum(Income.from.rent.of.leased.out.land..Rs.., na.rm = TRUE)
            )

# Now merge this to All_Basic_HH to create Other Incomes data frame
Other_Income_V1 <- left_join(All_HH_Basic, L2_V1_HH, by = "HH_ID")

# Remove NAs just to be sure
Other_Income_V1[is.na(Other_Income_V1)] <- 0


# Now visit 2

#Load and make the data frame
L2_V2 <- read_fwf("Raw data/r77s331v2L02.txt",
                  fwf_widths(widths = Level2Codes$Length),
                  col_types = cols(
                    X12 = col_character(),                  #RANT from before
                    .default = col_number()
                  ))
colnames(L2_V2) <- make.names(Level2Codes$Name)
L2_V2 <- L2_V2 %>%
  mutate(HH_ID = paste(FSU.Serial.No.,Second.stage.stratum.no.,Sample.hhld..No., sep = "0"))

# Summarise by household
L2_V2_HH <- L2_V2 %>%
  group_by(HH_ID) %>%
  summarise(
    Wages_V2 = sum(Wages...salary..earnings..Rs.., na.rm = TRUE),
    Pensions_V2 = sum(Earning.from.pension.remittances..Rs.., na.rm = TRUE),
    Lease_Rent_V2 = sum(Income.from.rent.of.leased.out.land..Rs..,na.rm = TRUE)
  )

# Now merge this to Common_Basic_HH to create Other Incomes data frame of visit 2. Not using All_HH_Basic because Common_HH_Basic has visit 2 data alone unlike the former.
Other_Income_V2 <- left_join(Common_HH_Basic, L2_V2_HH, by = "HH_ID")

# Remove NAs just to be sure
Other_Income_V2[is.na(Other_Income_V2)] <- 0


# Now merge both to get total

Other_Income <- left_join(Other_Income_V1, Other_Income_V2 %>%
                            select(c(1, 11:14)),
                          by = "HH_ID")

# Add calculated columns of total wages, pensions and rent
Other_Income <- Other_Income %>%
  mutate(
    Wages = Wages_V1 + Wages_V2,
    Pensions = Pensions_V1 + Pensions_V2,
    Lease_Rent = Lease_Rent_V1 + Lease_Rent_V2
  )


# Subset to agricultural households
AH_Other_Income <- Other_Income %>% filter(HH_ID %in% AH_Common_HH_Basic$HH_ID)

# Run the tests

wtd.mean(AH_Other_Income$Wages, weights = AH_Other_Income$Weights_V2)/12
# We get 4062.621 which matches with 4063 in the report
wtd.mean(AH_Other_Income$Wages_V2, weights = AH_Other_Income$Weights_V2)/6
# We get 4189.501 which matches with 4190 in the report
wtd.mean(AH_Other_Income$Wages_V1, weights = AH_Other_Income$Weights_V1)/6
# We get 3931.748 which matches with 3932 in the report

wtd.mean(AH_Other_Income$Pensions, AH_Other_Income$Weights_V2)/12
# We get 611.1576 which matches with 611 in the report

wtd.mean(AH_Other_Income$Lease_Rent, AH_Other_Income$Weights_V2)/12
# We get 134.3046 which matches with 134 in the report

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
