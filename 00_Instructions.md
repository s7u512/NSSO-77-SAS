# Instructions

Read this document first to get started.

## 1. Requirements

1. Download and Install R: You can download and install R from [here](https://cloud.r-project.org/). We recommend downloading and installing an Integrated Development Environment for R. We used [RStudio](https://posit.co/products/open-source/rstudio/) in our exercise.

2. Download the Data: Get the raw data and other documentation for this survey. We have provided some links for this in the [README file](https://github.com/s7u512/NSSO-77-SAS/blob/main/README.md), but you may need to find different links at the time of viewing this.

NSSO provides the unit level data as fixed width text files. The data is split into multiple levels for each visit (There are two visits). Download everything. NSSO also provides a spreadsheet that contains the layout information. This includes the widths of different variables and their names, the information contained in each level, and some other less relevant information.

3. Prepare lists: In the future I will be documenting how to use the documentation to prepare the lists that we have prepared and provided in this repo to help with the analysis. For now you can use the lists I have already provided. However, I strognly suggest the beginner to go through the documentation provided along with the unit level data to prepare these lists.


## 2. Folder Structure

Decide on a working directory (a folder/directory in which you will do the work). For example I used `/home/user/Desktop/SAS2019` for my exercise. The scripts provided here assume the following folder structure in the working directory:

- `/home/user/Desktop/SAS2019/Raw Data`: All the raw data are stored here, including all levels from both visits.
- `/home/user/Desktop/SAS2019/Output`: This can be an empty folder to begin with. It will get populated with all the calculated data frames in the form of .csv and .RData files as we execute the scripts.


## 3. Contents

### 3.1 Scripts 

The six R scripts in this repository contain the code and comments for reading, estimating, and conducting basic analysis of the unit-level data from Schedule 33.1 of the 77th round by NSSO. 

The analysis can be conducted in the following order:

| File Name               | Description                                                                                     |
|------------------------|-------------------------------------------------------------------------------------------------|
| 01_All_Basic_HH.R         | Creates a dataset with some basic information about all the households, and identifies agricultural households that are common across two visits. |
| 02_Crop_Income.R           | Calculates the crop income using the paid-out approach.                              |
| 03_Animal_Income.R         | Calculates animal income using the paid-out approach.                                 |
| 04_NonFarm_Business_Income.R | Calculates income from non-farm businesses.                                           |
| 05_Other_Income.R          | Calculates other incomes such as Wages, Rents and Pensions.                           |
| 06_HH_Income_of_AH.R       | Combines crop income, animal income, wage, rent, and non-farm business income to calculate household incomes. |


### 3.2 Supporting files

These are the supporting files prepared based on the documentation, for use in the scripts. 

| File Name                    | Description                                                                                                                               |
|------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| List_Level_Codes.xlsx        | Contains the widths specified by NSS for data extraction, as given in the documentation. |
| List_State.xlsx              | Contains codes for States.                                                                                                                |
| List_Social_Group.xlsx       | Contains codes for social groups.                                                                                                          |
| List_HH_Classification.xlsx | Contains codes for household classification (e.g., self-employed in crop production).                                                      |
| List_Religion.xlsx           | Contains codes for religion.                                                                                                               |
| List_Crop_Code.xlsx          | Contains codes for crops (it has two lists - one for MSP Crops alone, and one for all crops.) This list is not used in the given code here, but will be of use when analysing cropwise data. |





## 4. Running the Scripts

After these folders are made, 

1. Bring all the six scripts and the six lists and place them on the working directory (in this case `/home/user/Desktop/SAS2019`)
2. Open the first script using RStudio or R. 
3. Read through the script.
4. Change the line ``setwd("path/to/working/directory")`` to the path to your working directory (In my case ``setwd("/home/user/Desktop/SAS2019")``
5. Run the script. 
6. Save the file.
7. Repeat the steps 2 to 6 for all the scripts in order.

You are done. 
The outputs will be generated in the Output folder.



Thanks for reading. Please [reach out](https://twitter.com/all_awry) if the instructions are not clear enough. Feel free to [open an issue](https://github.com/s7u512/NSSO-77-SAS/issues/new) if you come across any.
