# Instructions

Read this document first to get started.

## 1. Requirements

1. Download and Install [R](https://cloud.r-project.org/). Downloading and installing an Integrated Development Environment (IDE) for R such as [RStudio](https://posit.co/products/open-source/rstudio/) is highly recommended.

2. Obtain the Data: Get the raw data and other documentation for this survey. Some links to download this data are provided in the [README file](https://github.com/s7u512/NSSO-77-SAS/blob/main/README.md), but the process might be different at the time of your vieweing.

NSSO used to provide the unit level data as fixed width text files. The data was split into multiple levels for each visit (There are two visits). It is a good idea to have everything even though in this exercise only Levels 01, 02, 03, 04, 07, 08, 11, 12, and 13 are used owing to the limited scope. NSSO also provided a spreadsheet that contained information about the layout of the fixed width data. This included information such as the variables contained in each level, the widths of different variables and their names, and some other less relevant information.

3. Prepare lists: In the future I will document how to use NSSO's documentation to prepare some lists provided in this repo to help with estimation. For now the lists I have provided can suffice. However, I strognly suggest the beginner to go through NSSO's documentation to prepare these lists themselves.


## 2. Folder Structure

Decide on a working directory (a folder/directory in which you will do the work). For example I will use `/home/user/Desktop/SAS2019` as the working directory. The scripts provided here assume the following folder structure in the working directory:

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
| 02A_Land_Size_Class_Visit2.R       | Optional script to calculate land size class from Visit 2. Land size class from visit 1 alone is calculated otherwise. If you are using this script, please uncomment the relevant code block in 06_HH_Income_of_AH.R to add that to the final data frame. |


### 3.2 Supporting files

These are the supporting files prepared based on the documentation, for use in the scripts. 

| File Name                    | Description                                                                                                                               |
|------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| List_Level_Codes.xlsx        | Contains the widths specified by NSS for data extraction, as given in the documentation. |
| List_State.xlsx              | Contains codes for States.                                                                                                                |
| List_Social_Group.xlsx       | Contains codes for social groups.                                                                                                          |
| List_HH_Classification.xlsx | Contains codes for household classification (e.g., self-employed in crop production).                                                      |
| List_Religion.xlsx           | Contains codes for religion.                                                                                                               |
| List_Crop_Code.xlsx          | Contains codes for crops (it has two lists - one for MSP Crops alone, and one for all crops.) This list is not used here, but will be of use to analyse cropwise data. |





## 4. Running the Scripts

There are two ways of going about it I will describe here. The first one is easier if you have some basic familiarity with git, and the other is for if you do not want to be learning about git.

### 4.1 Cloning the git (optional | easier | requires basic familiarity with git)

1. Clone the git repo to your desired location. (You can do this [within RStudio](https://happygitwithr.com/index.html) as well.)
2. Create the folders `Raw Data` and `Output` in the location. These folders are already added to .gitignore
3. Place all the raw data in the Raw Data folder. 
4. Open the scripts in the IDE of your choice such as [RStudio](https://github.com/rstudio/rstudio)
5. Install relevant libraries if required.
6. Run them in the order of naming.
7. Done, the outputs should be populated in the `Output` directory. 

### 4.2 Without cloning the git

0. Decide on the working directory. In this example I will use `/home/user/Desktop/SAS2019` (Note: If you are in a Windows machine, you will need to reverse the slashes from, for example, `"D:\Statistics\SAS2019"` to `D:/Statistics/SAS2019`)
1. Bring all the six scripts and the six lists and place them on the working directory (in this case `/home/user/Desktop/SAS2019`)
2. Create the folders `/home/user/Desktop/SAS2019/Raw Data/` and `/home/user/Desktop/SAS2019/Output`
3. Bring all the raw data and place them in `/home/user/Desktop/SAS2019/Raw Data/` 
4. Open the first script using an IDE such as [RStudio](https://posit.co/products/open-source/rstudio/).
5. Read through the script.
6. Install relevant libraries if required.
7. Change the line ``setwd(".")`` to the path to your working directory. 
8. Run the script. 
9. Repeat the steps 4 to 8 for all the scripts in order.

You are done. 
The outputs will be generated in the Output folder.

You can of course change the folder structure to your liking so long as you make appropriate changes to the scripts as well.



Thanks for reading. Please [reach out](https://twitter.com/all_awry) if the instructions are not clear enough. Feel free to [open an issue](https://github.com/s7u512/NSSO-77-SAS/issues/new) if you come across any.
