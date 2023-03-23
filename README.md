# Situation Assessment Survey of Agricultural Households (2019) Estimation Scripts

These R scripts were developed as a personal project to learn sample survey estimation using R. The scripts were heavily influenced by my friend [Deepak's work on the same topic](https://github.com/deepakjohnson91/NSSO-77-Round-SAS/). I started out trying to replicate his work. However, I have ended up deviating  enough to not be able to call it a fork anymore, and therefore decided to create my own repository. The scripts are simple and heavily commented to be useful to beginners. I used RStudio, an IDE for R to do this work.

These scripts are designed to estimate the results of the Situation Assessment Survey of Agricultural Households conducted by NSSO in 2019. The scripts are specifically tailored to work with the published data from this survey.

## 1. Situation Assessment Survey of Agricultural Households (2019)

India's National Sample Survey Organisation conducted its 77th Round of surveys in 2018-19. Among different topics covered in this round was the assessment of farming conditions in India. A brief review of the surveys and some results from the past can be found in the two links given below. 
1. [Situation Assessment Survey of Agricultural Households 2019: A Statistical Note by Aparajita Bakshi](http://ras.org.in/situation_assessment_survey_of_agricultural_households_2019_a_statistical_note)
2. [The Situation Assessment Surveys: An Evaluation by Biplab Sarkar](http://ras.org.in/index.php?Article=the_situation_assessment_surveys&q=biplab&keys=biplab)

The full list of unit-level datasets and documentation associated with NSS 77th Round Situation Assessment Survey this can be found [here](https://mospi.gov.in/web/mospi/download-tables-data/-/reports/view/templateFour/25302?q=TBDCAT). 
Please remember that archive.org can be used to access the website links if needed.

In this workbook, I use the information given in the documentation to calculate the monthly income of agricultural households using the unit-level data.


## 2. Approach

### 2.1 Data Extraction

The data used in these scripts are from the 2019 round of the Situation Assessment Survey of Agricultural Households conducted by the National Sample Survey Office (NSSO) in India. The NSSO provides the raw data in fixed width files along with documentation on how to read them, including information about the column names and their respective widths.

I have prepared some lists based on the documentation (for example column names and their widths for each level is made into one spreadsheet) to be used in the calculations. These files are uploaded here along with the scripts. Nonetheless it is recommended that a beginner learns to prepare such files themselves by going through the documentation.

### 2.2 Analysis Process

The calculations in these scripts are performed after applying sample weights provided by the NSSO.

The idea is to seperately calculate different components of household income and then merge them together to calculate the monthly household income of the agricultural households. Thus, The income for each component (income from crop production, animal resources, etc.) is computed separately using the appropriate weights and other relevant variables. These component datasets are then combined together to obtain the household income.

The scripts are heavily commented and should be easy to follow, even for those with limited experience in R. Note that the scripts are specifically tailored to work with the published data from the 2019 round of the survey.

## 3. Contents

### 3.1 Scripts 

The six R scripts in this repository contain the code and comments for basic analysis of the unit-level data from the Situation Assessment Survey of Agricultural Households conducted by the NSSO in 2019. All of these files use data from both survey visits.

The analysis can be conducted in the following order:

    All_Basic_HH.R 									- this script creates a dataset with some basic information about all the households, and identifies agricultural households that are common across two visits.
	Crop_Income.R 									- this script calculates the crop income using the paid-out approach.
	Animal_Income.R 								- this script calculates animal income using the paid-out approach.
	NonFarm_Business_Income.R 						- this script calculates income from non-farm businesses.
	Other_Income.R 									- this script calculates other incomes such as Wages, Rents and Pensions.
    Household_Income_of_Agricultural_Households.R 	- this script combines crop income, animal income, wage, rent, and non-farm business income to calculate household incomes.

### 3.2 Supporting files

These are the supporting files prepared based on the documentation, for use in the scripts. 

    List_Level_Codes.xlsx 							- contains the widths specified by NSS for data extraction, as given in the "NSS_77th_Layout_Sch_33.1_mult_post.xls" file provided on the NSSO website.
    List_State.xlsx 								- contains codes for States.
    List_Social_Group.xlsx 							- contains codes for social groups.
    List_HH_Classification.xlsx 					- contains codes for household classification (e.g., self-employed in crop production).
    List_Religion.xlsx 								- contains codes for religion.
	List_Crop_Code.xlsx								- contains codes for crops (it has two lists - one for MSP Crops alone, and one for all crops.) This list is not used in the given code here, but will be of use when analysing cropwise data.


## 4. Disclaimer

As a beginner in R and sample survey estimation, I have done my best to keep the code uniform and well-commented. However, there may be mistakes or better ways to approach the analysis. Please let me know if you spot any issues or have suggestions for improvement. I have not done an exhaustive check of formatting consistency or other potential issues, so please don't hesitate to reach out if you have any questions or concerns.

## 5. Contributing

These scripts were designed for personal use, but if you would like to contribute to this project, feel free to fork the repository and make any modifications you see fit.


## 6. License

This work is licensed under the [GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.html) license. This work is free: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This work is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

## 7. Acknowledgements

These scripts were inspired by [the work of Deepak Johnson](https://github.com/deepakjohnson91/NSSO-77-Round-SAS/). I would like to thank Deepak for his initial work and guidance in this project. Thanks are due also to friends and other colleagues from the [Foundation for Agrarian Studies](https://fas.org.in/) for all their help.
