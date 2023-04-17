#  =================== Estimating Basic Figures and Identifying Agricultural Households - SAS Data - 77th Round of NSSO =================== # 

# Author: Sethu C. A.
# License: GNU GPLv3

#  This is script 1 of 6
#  This work is inspired by Deepak Johnson's work here: https://github.com/deepakjohnson91/NSSO-77-Round-SAS/


#  Documentation on and data/readme files available at https://www.mospi.gov.in/unit-level-data-report-nss-77-th-round-schedule-331-january-2019-%E2%80%93-december-2019land-and-livestock
#  The crop production and all other data are given for common households from 1 & 2 visits. 
#  In this workbook, we select the common households from both the visits, and combine some basic features. 
#  The report gives the number of common number of agricultural households in the sample as 44,740.
#  For Visit 1 it was 45,714 and for Visit 2 it was	44,770. 
#  The weights of Visit 2 have to be used while combining data from both visits. (This is stated in the documentation as well.)
#  Aside: Excel tables can be downloaded from page 175 of the report by clicking on the hyperlinks. (It is possible that MoSPI does not host them at the time of your viewing. In that case, use archive.org)


rm(list = ls())         # clear the environment

#  Load packages
library(readxl)         #  for reading excel files
library(readr)          #  for reading fixed width files in a fast and consistent manner compared to the 'foreign' library
library(data.table)     #  for exporting data in a fast manner
library(dplyr)          #  tidyverse package for data manipulation


# Set working directory
setwd(".") # change this path to your specific directory before running the script if you downloaded all the code instead of cloning the repo.

# The initial target is to create a data frame with data from level 3 of visit 1 as it contains some basic information regarding each household.

# Read the corresponding level codes into a data frame
Level3Codes <- read_excel("List_Level_Codes.xlsx", sheet = "Level3") 

# Load the data for given level from the fixed width file provided into a data frame using the byte lengths provided in the level codes file
# The name of the data frame has the following logic: Level 3 data for Visit 1

# Remark: read_fwf() from 'readr' library is a significantly faster way to load large files compared to read.fwf() from 'foreign' library. But it is 'too safe' in assuming column types. By default read_fwf() tries to preserve leading zeroes by making columns character instead of number. This is why we manually specify the column types to be number.

L3_V1 <- read_fwf("Raw data/r77s331v1L03.txt",
                       fwf_widths (widths = Level3Codes$Length),      # get the widths from the the level codes
                       col_types = cols(                              # manually specifying column types
                         X12 = col_character(),                       # RANT: This column alone has character values. It is FOD.Sub.Region, and has values except for the NE States for whom letters are used. For eg. MIZ for Mizoram. Annoying. BEGIN RANT: This one step is a drawback of using read_fwf() instead of read.fwf() as the former is too careful in deciding data types. read_fwf() decides to preserve leading zeros as characters whereas read.fwf() does not. Long story short, read.fwf() does a better job of guessing column type, but takes exponentially longer time to process the data. It does this sequentially, unlike read_fwf() which processes in parallel. Tangibly, read_fwf() takes seconds where read.fwf() will take tens of minutes.  END RANT
                         .default = col_number()                      # the rest are to be number. 
                       ))


# Add column names to the data frame after sanitizing them as valid variable names
colnames(L3_V1) <- make.names(Level3Codes$Name)                       
                       


# Make a new column called "Weights" for weights (the formula for this is provided in the documentation)
L3_V1 <- L3_V1 %>% 
  mutate(Weights_V1 = Multiplier/100)

# Round off Weights
L3_V1$Weights_V1 <- round(L3_V1$Weights_V1, digits =1)

# Create a common ID for all households as per documentation.
# This can be done by creating a new column combining three specific columns seperated by a zero
L3_V1 <- L3_V1 %>%
  mutate(HH_ID = paste(FSU.Serial.No.,Second.stage.stratum.no.,Sample.hhld..No.,sep = "0"))


# Task: Create a column called 'State' that has the state name. This can be done by matching it with code in 'NSS.Region' column
# Step 1: Convert 'NSS.Region' to numeric from character (because it has leading zeroes)
# Step 2: Divide it by 10 and round down the result to get the State Code
L3_V1 <- L3_V1 %>%
  mutate(State = trunc(as.numeric(NSS.Region) / 10))

# Step 3: Match it with the code from StateList. For this we first read the State List into a data frame and then match the values.
State_list <- read_excel("List_State.xlsx")

# Next we match them by code, and apply the state names as labels, converting the column into factor variable aka categorical variable
L3_V1$State <- factor(L3_V1$State, 
                           levels = State_list$CODE,
                           labels = State_list$STATE)

# Task complete

# Similarly, match codes and create factor variables for Religion, Social Group and Household Classification using files provided
# we need not create new columns for this, as they are already there in the data frame.
# Read files into data frames
Religion_list <- read_excel("List_Religion.xlsx")
Social_Group_list <- read_excel("List_Social_Group.xlsx")
HH_Classification_list <- read_excel("List_HH_Classification.xlsx")

# Match them one by one
L3_V1$Religion.code <- factor(L3_V1$Religion.code,
                                   levels = Religion_list$CODE,
                                   labels = Religion_list$RELIGION)

L3_V1$Social.group.code <- factor(L3_V1$Social.group.code,
                                       levels = Social_Group_list$CODE,
                                       labels = Social_Group_list$SOCIAL_GROUP)

L3_V1$Household.classification..code <- factor(L3_V1$Household.classification..code,
                                                    levels = HH_Classification_list$CODE,
                                                    labels = HH_Classification_list$MAJOR_SOURCE)


# First step is complete

# Let us now run some basic tests

L3_V1 %>% summarise(Sample = n())

# Here we see the value is 58040 as opposed to 58035 in the report. This is because 5 households have weight of 0. Let us remove them.

# We can check this with the following code
L3_V1 %>% filter(Weights_V1 != 0) %>% summarise(Sample = n())

# Let us omit these five.

L3_V1 <- L3_V1 %>% filter(Weights_V1 != 0)



# Task: make a table of agricultural and non-agricultural households among different social groups to compare with the report.

# To do this, Group by and show the number of agricultural and non-agricultural households for different social groups

L3_V1 %>% 
  group_by(Social.group.code, value.of.agricultural.production.from.self.employment.activities.during.the.last.365.days.code.) %>%
  summarise(Sample = n(), Estimated_number = sum(Weights_V1))

# Explanation for code above
# Here we first grouped the data frame by social group and code for whether the household has agricultural production or not.
# Next, we are using summarise () function to get these summary statistics. 
# We are creating two columns called Sample and Estimated_number in this output
# The value of Sample column will be defined by n() which returns the number of observations
# The value of Estimated_number is provided by adding the weights for these observations
# The output should be a table with 4 columns and 8 rows

# The output obtained is checked with Table 3 (Excel Sheets) of the Report.
# Output: Sample number of non-agri ST = 2215; estimated number: 7920535. 
# Report: Sample number of non-agri ST = 2215; estimated number: 7920500. Note that the report gives the estimated number in 100s of households.Rounding gives the same figure.

# Second step is complete


# Now we will select the relevant columns alone from this data set and save it as the list of all households with basic info

All_HH_Basic <- L3_V1[,c("HH_ID", "State", "Weights_V1", "Household.size","Religion.code", "Social.group.code", "Household.classification..code", "value.of.agricultural.production.from.self.employment.activities.during.the.last.365.days.code." )]


# Replace NA with 0

All_HH_Basic[is.na(All_HH_Basic)] <- 0





# Task: Get and add land size classification to this

# Land information is provided in Block 5 in the data, which is in Level 4. Let us load this now.

# Read the corresponding level codes into a data frame
Level4Codes <- read_excel("List_Level_Codes.xlsx", sheet = "Level4") 

# Load the data for given level from the fixed width file provided into a data frame using the byte lengths provided in the level codes file
# The name of the data frame has the following logic: Level 7 in Visit 1
L4_V1 <- read_fwf("Raw data/r77s331v1L04.txt", 
                  fwf_widths(widths = Level4Codes$Length),
                  col_types = cols(
                    X12 = col_character(),                 #RANT from before
                    .default = col_number()
                  ))

# Add column names to the data frame after sanitizing them as valid variable names
colnames(L4_V1) <- make.names(Level4Codes$Name)

# Create a common ID for all households as per documentation.
L4_V1 <- L4_V1 %>%
  mutate(HH_ID = paste(FSU.Serial.No.,Second.stage.stratum.no.,Sample.hhld..No., sep = "0"))

# Make a new column called "Weights" for weights (the formula for this is provided in the documentation)
L4_V1 <- L4_V1 %>% 
  mutate(Weights_V1 = Multiplier/100)

# Round off Weights
L4_V1$Weights_V1 <- round(L4_V1$Weights_V1, digits =1)

# Issue: The following code will show that there are 57978 households recorded in this level (which is 57 less than the total number of households sampled) L4_V1 %>% distinct(HH_ID) %>% n_distinct() 

# DEFINITION: Out of various categories of land reported against a rural household, land which are ‘owned and possessed’, ‘leased-in’ and ‘otherwise possessed’ are combined and termed as ‘land possessed’ by the household. (3.1.2.1 on Page 46 (76/4264))

# This means that we have to sum the area for serial no.s 1, 2, 3, 4  and 6, 7, 8, 9 for each hh_id

# Create a new data frame with just the land information. 
land_categorization_V1 <- L4_V1 %>%
  group_by(HH_ID) %>%
  summarise(
    land_possessed_acres_V1 = sum(area.of.land..0.00.acre.[Srl.No. %in% c(1,2,3,4,6,7,8,9)], na.rm = TRUE)
  )

# Explanation for the code above:
# Land information is given as different categories. We are going to add the different categories such as land owned, land leased-in etc. discussed in the definition above (which are listed as serial numbers 1 through 9 except for 5 which is land leased out) for each household.
# First we group the data by household ID, and then we sum the area of land for serial numbers 1 through 9 except for 5.
# This sum is stored in a new column called land_possessed_acres_V1



# Convert the land possessed into hectares from acres
# For convenience use roun() function to round off the converted value to three decimal places
# Note that the report mentions in Page 23 (51/4264) that the conversion factor used from acres to hectares is 0.405

land_categorization_V1$land_possessed_ha_V1 <- round(
  land_categorization_V1$land_possessed_acres_V1 *  0.405, 
  3)


# Add a column to categorize the land sizes in the same manner as the report. 
# The report has the following categories: <0.01, 0.01-0.40, 0.40-0.1.00, 1.01-2.00, 2.01-4.00,4.01-10.00,10+
# Page 23 (51/4264) of the report defines the categories in detail.


# Define the new size classes
size_classes_list <- c(-0.001, 0.004, 0.404, 1.004, 2.004, 4.004, 10.004, Inf)                                            # We get these values from the table in Page 23 of the report
size_class_labels_list <- c("< 0.01", "0.01 - 0.40", "0.41 - 1.00", "1.01 - 2.00", "2.01 - 4.00", "4.01 - 10.00", "10+")  # We get these values from the table in Page 23 of the report

# Use the cut() function to categorize the land sizes
land_categorization_V1 <- land_categorization_V1 %>% 
                          mutate(
                                  size_class_of_land_possessed_ha_V1 = cut(
                                                                        land_possessed_ha_V1, 
                                                                        breaks = size_classes_list, 
                                                                        labels = size_class_labels_list,
                                                                        right = TRUE
                                                                        ))

# Explanation for the code above:
# First we create a new column in the data frame using mutate() function, calling it size_class_of_land_possessed_ha_V1
# Now we use the cut() function. The cut() function in R is used to divide a continuous variable into discrete intervals, or "bins." It takes a number as input and returns a factor object with labels for each bin.
# Here we break the column land_possessed_ha_V1 into intervals defined in size_classes_list, and then apply labels given in size_class_labels_list.
# Next we specify that the breaks need to happen by keeping the right end of the interval closed, by specifying right = TRUE
# We are done



# Replace NAs with 0 to be sure
land_categorization_V1[is.na(land_categorization_V1)] <- 0

# Now merge this column and the area column to the All_HH_Basic data frame.

All_HH_Basic <- All_HH_Basic %>%
  left_join(
    land_categorization_V1 %>%
      select(HH_ID, land_possessed_ha_V1, size_class_of_land_possessed_ha_V1),
    by = "HH_ID"
  )


# Replace the NA values in size_class_of_land_possessed_ha_V1 column with the factor "<0.01" as these households have no land and therefore did not feature in the L4 data frame, and subsequently did not feature in the land_categorization_V1 data frame.
levels(All_HH_Basic$size_class_of_land_possessed_ha_V1) <- c(levels(All_HH_Basic$size_class_of_land_possessed_ha_V1), "< 0.01")
All_HH_Basic$size_class_of_land_possessed_ha_V1[is.na(All_HH_Basic$size_class_of_land_possessed_ha_V1)] <- "< 0.01"


# Replace NAs with 0 to be sure
All_HH_Basic[is.na(All_HH_Basic)] <- 0


# Third step is complete



# Create a subset of Visit 2 households

# Load data that contains all visit 2 households

# Get level codes first
Level1Codes <- read_excel("List_Level_Codes.xlsx", sheet = "Level1")

# Load the fixed width file using read_fwf(). Level1 codes are a little cumbersome in this regard because five columns are character. On top of that, three columns have the same name. Consider using read.fwf() if all this is too complicated for you, but it will take longer for the system to load the files.
L1_V2 <- read_fwf("Raw data/r77s331v2L01.txt",
                       fwf_widths (widths = Level1Codes$Length),
                       col_types = cols(
                         X12 = col_character(),                 # RANT: This column alone has character values. It is FOD.Sub.Region, and has values except for the NE States for whom letters are used. For eg. MIZ for Mizoram. Annoying. BEGIN RANT: This one step is a drawback of using read_fwf() instead of read.fwf() as the former is too careful in deciding data types. read_fwf() decides to preserve leading zeros as characters whereas read.fwf() does not. Long story short, read.fwf() does a better job of guessing column type, but takes exponentially longer time to process the data. It does this sequentially, unlike read_fwf() which processes in parallel. Tangibly, read_fwf() takes seconds where read.fwf() will take tens of minutes.  END RANT
                         X22 = col_character(),                 # This column is also character in this set. Employee Code.
                         X23 = col_character(),                 # This column is also character in this set. Employee Code.
                         X24 = col_character(),                 # This column is also character in this set. Employee Code.
                         X28 = col_character(),                 # This column is also character in this set. It is no. of investigators or something. Interestingly there are 7 instances of * in the data.
                         .default = col_number()                # The rest are to be number
                       ))


# Add column names to the data frame after sanitizing them as valid variable names. There is an added make.unique function here because there are multiple columns with the same title.
colnames(L1_V2) <- make.unique(make.names(Level1Codes$Name))



# Make a new column called "Weights" for weights (the formula for this is provided in the documentation)
L1_V2 <- L1_V2 %>% 
  mutate(Weights_V2 = Multiplier/100)

# Round off Weights
L1_V2$Weights_V2 <- round(L1_V2$Weights_V2, digits =1)

# Create a common ID for all households as per documentation.
# This can be done by creating a new column combining three specific columns separated by a zero
L1_V2 <- L1_V2 %>%
  mutate(HH_ID = paste(FSU.Serial.No.,Second.stage.stratum.no.,Sample.hhld..No.,sep = "0"))




# Create data set for Common Households Basic Information (The households in visit 2 are a subset of visit 1, so there is no point in making a dataset for visit 2 alone.)
Common_HH_Basic <- subset(All_HH_Basic, All_HH_Basic$HH_ID %in% L1_V2$HH_ID)

# Bring over the weights_V2 from Level1 Visit 2

Common_HH_Basic <- left_join(Common_HH_Basic, L1_V2 %>%
                               select(HH_ID, Weights_V2),
                             by = "HH_ID")


# Make a subset of Agricultural Households
AH_Common_HH_Basic <- subset(Common_HH_Basic, Common_HH_Basic$value.of.agricultural.production.from.self.employment.activities.during.the.last.365.days.code. == 2)



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
