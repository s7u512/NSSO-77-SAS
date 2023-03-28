#  =================== Creating Land Size Classification based on Visit 2 - SAS Data - 77th Round of NSSO =================== # 

# Author: Sethu C. A.
# License: GNU GPLv3

#  This is script an optional extra

#  Documentation on and data/readme files available at https://www.mospi.gov.in/unit-level-data-report-nss-77-th-round-schedule-331-january-2019-%E2%80%93-december-2019land-and-livestock
#  Land information is provided in Block 5 in the data, which is in Level 4. I have already added that to the first script for visit 1.
#  This script is to make a data frame that has land size classes for visit 2, so that you can add that to other calculations when required.


rm(list = ls())         # clear the environment

#  Load packages
library(readxl)         #  for reading excel files
library(readr)          #  for reading fixed width files in a fast and consistent manner compared to the 'foreign' library
library(data.table)     #  for exporting data in a fast manner
library(dplyr)          #  tidyverse package for data manipulation


# Set working directory
setwd("/home/fasuser/Sync/Other/RStudio/NSSO-77-SAS/") # change this path to your specific directory before running the script 

# Load relevant data prepared earlier
load("Output/Common_HH_Basic.Rdata")


# Task: Get and add land size classification for visit 2 to this

# Land information is provided in Block 5 in the data, which is in Level 4. Let us load this now.

# Read the corresponding level codes into a data frame
Level4Codes <- read_excel("List_Level_Codes.xlsx", sheet = "Level4") 


# Load the data for given level from the fixed width file provided into a data frame using the byte lengths provided in the level codes file
# The name of the data frame has the following logic: Level 4 in Visit 2
L4_V2 <- read_fwf("Raw data/r77s331v2L04.txt", 
                  fwf_widths(widths = Level4Codes$Length),
                  col_types = cols(
                    X12 = col_character(),                 #RANT from before
                    .default = col_number()
                  ))

# Add column names to the data frame after sanitizing them as valid variable names
colnames(L4_V2) <- make.names(Level4Codes$Name)

# Create a common ID for all households as per documentation.
L4_V2 <- L4_V2 %>%
  mutate(HH_ID = paste(FSU.Serial.No.,Second.stage.stratum.no.,Sample.hhld..No., sep = "0"))

# Make a new column called "Weights" for weights (the formula for this is provided in the documentation)
L4_V2 <- L4_V2 %>% 
  mutate(Weights_V2 = Multiplier/100)

# Round off Weights
L4_V2$Weights_V2 <- round(L4_V2$Weights_V2, digits =1)

# Issue: The following code will show that there are 56818 households recorded in this level (which is 76 less than the total number of households sampled). We will assume they have 0 land. 
# L4_V2 %>% distinct(HH_ID) %>% n_distinct() 

# DEFINITION: Out of various categories of land reported against a rural household, land which are ‘owned and possessed’, ‘leased-in’ and ‘otherwise possessed’ are combined and termed as ‘land possessed’ by the household. (3.1.2.1 on Page 46 (76/4264))

# This means that we have to add area in serial no.s 1, 2, 3, 4, 6, 7, and 8 for each hh_id

# Create a new data frame with just the land information. 
Land_categorization_V2 <- L4_V2 %>%
  group_by(HH_ID) %>%
  summarise(
    land_possessed_acres_V2 = sum(area.of.land..0.00.acre.[Srl.No. %in% c(1,2,3,4,6,7,8,9)], na.rm = TRUE)
  )

# Explanation for the code above:
# Land information is given as different categories. We are going to add the different categories such as land owned, land leased-in etc. discussed in the definition above (which are listed as serial numbers 1 through 9 except for 5 which is land leased out) for each household.
# First we group the data by household ID, and then we sum the area of land for serial numbers 1 through 9 except for 5.
# This sum is stored in a new column called land_possessed_acres



# Convert the land possessed into hectares from acres
# For convenience use roun() function to round off the converted value to three decimal places
# Note that the report mentions in Page 23 (51/4264) that the conversion factor used from acres to hectares is 0.405

Land_categorization_V2$land_possessed_ha_V2 <- round(
  Land_categorization_V2$land_possessed_acres_V2 *  0.405, 
  3)


# Add a column to categorize the land sizes in the same manner as the report. 
# The report has the following categories: <0.01, 0.01-0.40, 0.40-0.1.00, 1.01-2.00, 2.01-4.00,4.01-10.00,10+
# Page 23 (51/4264) of the report defines the categories in detail.

# Define the new size classes
size_classes_list <- c(-0.001, 0.004, 0.404, 1.004, 2.004, 4.004, 10.004, Inf)                                            # We get these values from the table in Page 23 of the report
size_class_labels_list <- c("< 0.01", "0.01 - 0.40", "0.41 - 1.00", "1.01 - 2.00", "2.01 - 4.00", "4.01 - 10.00", "10+")  # We get these values from the table in Page 23 of the report

# Use the cut() function to categorize the land sizes
Land_categorization_V2 <- Land_categorization_V2 %>% 
  mutate(
    size_class_of_land_possessed_ha_V2 = cut(
      land_possessed_ha_V2, 
      breaks = size_classes_list, 
      labels = size_class_labels_list,
      right = TRUE
    ))

# Explanation for the code above:
# First we create a new column in the data frame using mutate() function, calling it size_class_of_land_possessed_ha
# Now we use the cut() function. The cut() function in R is used to divide a continuous variable into discrete intervals, or "bins." It takes a number as input and returns a factor object with labels for each bin.
# Here we break the column land_possessed_ha into intervals defined in size_classes_list, and then apply labels given in size_class_labels_list.
# Next we specify that the breaks need to happen by keeping the right end of the interval closed, by specifying right = TRUE
# We are done



# Replace NAs with 0 to be sure
Land_categorization_V2[is.na(Land_categorization_V2)] <- 0

# Now merge this column and the area column to the Common_HH_Basic data frame.

Common_HH_Basic_with_Land_V2 <- Common_HH_Basic %>% 
  left_join(
    Land_categorization_V2 %>%
      select(HH_ID, land_possessed_ha_V2, size_class_of_land_possessed_ha_V2),
    by = "HH_ID"
  )

# Replace the NA values in size_class_of_land_possessed_ha column with the factor "<0.01" as these households have no land and therefore did not feature in the L4 data frame, and subsequently did not feature in the Land_categorization data frame.
levels(Common_HH_Basic_with_Land_V2$size_class_of_land_possessed_ha_V2) <- c(levels(Common_HH_Basic_with_Land_V2$size_class_of_land_possessed_ha_V2), "< 0.01")
Common_HH_Basic_with_Land_V2$size_class_of_land_possessed_ha_V2[is.na(Common_HH_Basic_with_Land_V2$size_class_of_land_possessed_ha_V2)] <- "< 0.01"


# Replace NAs with 0 to be sure
Common_HH_Basic_with_Land_V2[is.na(Common_HH_Basic_with_Land_V2)] <- 0


# This step is complete

# Make a subset of Agricultural Households
AH_Common_HH_Basic_with_Land_V2 <- subset(Common_HH_Basic_with_Land_V2, Common_HH_Basic_with_Land_V2$value.of.agricultural.production.from.self.employment.activities.during.the.last.365.days.code. == 2)

# Save the files


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

# The end
