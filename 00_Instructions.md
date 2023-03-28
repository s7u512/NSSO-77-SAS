# Instructions

Read this document first to get started. This applies for fixed-width data procured using the old method. I have made [instructions](https://github.com/s7u512/NSSO-77-SAS/blob/main/New_Format_Instructions.md) on how to use the data in the new format(s) and modify the scripts here to work with that. But read this first before going there, as that document assumes that you did.

## 1. Requirements

1.  [Download and Install R](https://cloud.r-project.org/). 

2.  Downloading and installing an Integrated Development Environment (IDE) for R such as [RStudio](https://posit.co/products/open-source/rstudio/) is highly recommended.

3.  Obtain the Data: Get the unit level raw data along with the documentation for this survey. Some links to download this data are provided in the [README file](https://github.com/s7u512/NSSO-77-SAS/blob/main/README.md), but the process might be different at the time of your viewing. [Reach out](https://twitter.com/all_awry) if you have queries.

4.  Prepare lists: In the future I may document how to use NSSO's documentation to prepare some lists provided in this repo to help with estimation. For now the lists I have provided can suffice. However, I strognly suggest the beginner to go through NSSO's documentation to prepare these lists themselves.

### Some Resources for a beginner

[Here](https://github.com/pawan1198/r-cheatsheets/blob/master/README.md) is a quick and basic introduction to R (although without any license information). [Here](https://github.com/rstudio/cheatsheets) are some cheat sheets from RStudio. [Here](https://resources.github.com/github-and-rstudio/) are some directions on using RStudio and GitHub together if you are into that sort of thing.


## 2. Folder Structure

Decide on a working directory (a folder/directory in which you will do the work). As an example I will use `/home/user/Desktop/SAS2019` as the working directory. The scripts provided here assume the following folder structure in the working directory:

-   `/home/user/Desktop/SAS2019/Raw Data`: All the raw data are stored here, including all levels from both visits.
-   `/home/user/Desktop/SAS2019/Output`: This can be an empty folder to begin with. It will get populated with all the calculated data frames in the form of .csv and .RData files as we execute the scripts.

## 3. Contents

### 3.1 Scripts

The R scripts in this repository contain the code and comments for reading, estimating, and conducting basic analysis of the unit-level data from Schedule 33.1 of the 77th round by NSSO.

The analysis can be conducted in the following order:

| File Name                    | Description                                                                                                                                                                                                                                                |
|------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 01_All_Basic_HH.R            | Creates a dataset with some basic information about all the households, and identifies agricultural households that are common across two visits.                                                                                                          |
| 02_Crop_Income.R             | Calculates the crop income using the paid-out approach.                                                                                                                                                                                                    |
| 03_Animal_Income.R           | Calculates animal income using the paid-out approach.                                                                                                                                                                                                      |
| 04_NonFarm_Business_Income.R | Calculates income from non-farm businesses.                                                                                                                                                                                                                |
| 05_Other_Income.R            | Calculates other incomes such as Wages, Rents and Pensions.                                                                                                                                                                                                |
| 06_HH_Income_of_AH.R         | Combines crop income, animal income, wage, rent, and non-farm business income to calculate household incomes.                                                                                                                                              |
| 02A_Land_Size_Class_Visit2.R | Optional script to calculate land size class from Visit 2. Land size class from visit 1 alone is calculated otherwise. If you are using this script, please uncomment the relevant code block in 06_HH_Income_of_AH.R to add that to the final data frame. |

### 3.2 Supporting files

These are the supporting files prepared based on the documentation, for use in the scripts.

| File Name                   | Description                                                                                                                                                            |
|-----------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| List_Level_Codes.xlsx       | Contains the widths of variables for data extraction, specified by NSS in the documentation.                                                                               |
| List_State.xlsx             | Contains a list of States against codes.                                                                                                                                             |
| List_Social_Group.xlsx      | Contains a list of social groups against codes.                                                                                                                                      |
| List_HH_Classification.xlsx | Contains a list of  household classifications against codes.                                                                                  |
| List_Religion.xlsx          | Contains a list of religions against codes.                                                                                                                                           |
| List_Crop_Code.xlsx         | Contains a list of crops against codes (it has two lists - one for MSP Crops alone, and one for all crops in the survey.) This list is not used here, but will be of use to analyse cropwise data. |

## 4. Running the Scripts

There are two ways of going about running these scripts I will describe here. The first one is easier if you have some basic familiarity with git, and the other is for if you do not want to be learning about git.

### 4.1 Cloning the git (optional \| easier \| requires basic familiarity with git)

1.  Clone the git repo to your desired location. (You can do this [within RStudio](https://happygitwithr.com/index.html) as well.)
2.  Create the folders `Raw Data` and `Output` in the location. These folders are already added to .gitignore
3.  Place all the fixed width files of raw data in the `Raw Data` folder.
4.  Open the scripts in the IDE of your choice such as [RStudio](https://github.com/rstudio/rstudio)
5.  Read through the scripts.
6.  Install relevant libraries if required. (This can be done by running the code `install.packages("packagename")` in the R Console)
8.  Run them in the order of naming.

### 4.2 Without cloning the git

0.  Decide on the working directory. In this example I will use `/home/user/Desktop/SAS2019` (Note: If you are in a Windows machine, you will need to reverse the slashes from, for example, `D:\Statistics\SAS2019` to `D:/Statistics/SAS2019`)
1.  Bring all the scripts and the lists in this repository and place them on the working directory (You can just right-click and save the links from [the main page of this repository](https://github.com/s7u512/NSSO-77-SAS)) 
2.  Create the folders `/home/user/Desktop/SAS2019/Raw Data/` and `/home/user/Desktop/SAS2019/Output`
3.  Bring all the fixed width files of raw data and place them in `/home/user/Desktop/SAS2019/Raw Data/`
4.  Open the first script using an IDE such as [RStudio](https://posit.co/products/open-source/rstudio/).
5.  Read through the script.
6.  Install relevant libraries if required. (This can be done by running the code `install.packages("packagename")` in the R Console)
7.  Change the line `setwd(".")` to the path to your working directory.
8.  Run the script.
9.  Repeat the steps 4 to 8 for all the scripts in order.

You are done. The outputs will be generated in the Output folder.

You can of course change the folder structure to your liking so long as you make appropriate changes to the scripts as well.

If you have data in other formats, read [these instructions](https://github.com/s7u512/NSSO-77-SAS/blob/main/New_Format_Instructions.md) for some help on how to modify these scripts to suit that.

Thanks for reading. Please [reach out](https://twitter.com/all_awry) if the instructions are not clear enough. Feel free to [open an issue](https://github.com/s7u512/NSSO-77-SAS/issues/new) if you come across any.
