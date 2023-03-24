# Estimation Scripts for Situation Assessment Survey of Agricultural Households (2019) (77th round of National Sample Surveys of India)

These R scripts were developed as a personal project to learn sample survey estimation using R. The scripts were heavily influenced by my friend [Deepak's work on the same topic](https://github.com/deepakjohnson91/NSSO-77-Round-SAS/). I started out trying to replicate his work. However, I have ended up deviating  enough to not be able to call it a fork anymore, and therefore decided to create my own repository. The scripts are simple and heavily commented to be useful to beginners. I used RStudio, a popular and free IDE for R, to do this work.

These scripts are designed to estimate the results of the Situation Assessment Survey of Agricultural Households conducted by NSSO in 2019 - also known as NSS 77 th Round for Schedule- 33.1, January 2019 – December 2019,(Land and Livestock Holding of Households and Situation Assessment of Agricultural Households). Unit-level data along with a report was published by the National Statistical Office in September 2019.

The scripts are specifically tailored to work with the published unit-level data from this survey.

## 1. Situation Assessment of Agricultural Households (2019)

[National Sample Survey](https://www.mospi.gov.in/national-sample-survey-nss) under the Ministry of Statistics and Programme Implementation of Government of India is responsible for the conduct of large scale sample surveys in diverse fields on an all India basis. They conducted their 77th Round of surveys in 2018-19. Among different topics covered in this round was the assessment of farming conditions in India. This was covered in Scheduled 33.1. [A report](https://ruralindiaonline.org/en/library/resource/situation-assessment-of-agricultural-households-and-land-and-livestock-holdings-of-households-in-rural-india/) along with the unit-level data, was published by the National Statistical Office in September 2021.  A brief review of this survey and some results from the past can be found in the two links given below. 
1. [Situation Assessment Survey of Agricultural Households 2019: A Statistical Note by Aparajita Bakshi](http://ras.org.in/situation_assessment_survey_of_agricultural_households_2019_a_statistical_note)
2. [The Situation Assessment Surveys: An Evaluation by Biplab Sarkar](http://ras.org.in/index.php?Article=the_situation_assessment_surveys&q=biplab&keys=biplab)

The full list of unit-level datasets and documentation associated with this can be found [here](https://mospi.gov.in/web/mospi/download-tables-data/-/reports/view/templateFour/25302?q=TBDCAT) or [here](https://mospi.gov.in/unit-level-data-report-nss-77-th-round-schedule-331-january-2019-%E2%80%93-december-2019land-and-livestock).
Please remember that archive.org can be used to access the website links if needed.


## 2. Approach

### 2.1 Data Extraction

In this workbook, I use the information given in the documentation to calculate the monthly income of agricultural households using unit-level data.

The National Statistcal Survey Office (NSSO) provides unit-level raw data in fixed width files along with documentation on how to read them, such as information about the widths of different columns and their respective column names.

This survey conatins household level information of a sample of the population of India, from two visits in 2019. All of the scripts here use data from both survey visits. 
NSSO provides the data for different aspects such as demographic information, cost of cultivation etc. in different blocks.

Using the provided documentation, the unit-level data is read into data frames, which can be manipulated, exported, and merged. 
(To do this, I have prepared some lists based on the documentation to be used in the calculations. These files are uploaded here along with the scripts. Nonetheless it is recommended that a beginner learns to prepare such files themselves by going through the documentation.)

### 2.2 Estimation

The goal here is to estimate the population's characteristics from the sample data. NSSO provides the weights of the samples to enable this. ([Here](https://unstats.un.org/unsd/demographic/meetings/egm/sampling_1203/docs/no_5.pdf) is a document to understand the concept of sample weights.)

The calculations in these scripts are performed after applying sample weights provided by the NSSO. 

The scope of this exercise concludes at estimating monthly household incomes of agricultural households in India during the agricultural year 2018-19. The idea is to seperately calculate different components of household income (such as income from farming, income from wages, etc.) and then merge them together to calculate the monthly household income of the agricultural households. The income from each component is computed separately using the appropriate weights and other relevant variables. These component datasets are then combined together to obtain the household income. We rely on [the report](https://ruralindiaonline.org/en/library/resource/situation-assessment-of-agricultural-households-and-land-and-livestock-holdings-of-households-in-rural-india/) published along with the unit-level data to verify the estimation.

The scripts are heavily commented and should be easy to follow, even for those with limited experience in R. Note that the scripts are specifically tailored to work with the published data from the 2019 round of the survey.

Despite the limited scope, the idea is that if a beginner is able to follow through this exercise they would be equipped to carry out further analysis as required.

## 3. Contents

Start by reading [Instructions](https://github.com/s7u512/NSSO-77-SAS/blob/main/00_Instructions.md) to get started.
The six R scripts in this repository contain the code and comments for reading, estimating, and conducting basic analysis of the unit-level data from Schedule 33.1 of the 77th round by NSSO. 
There are a few supporting files prepared based on the documentation, for use in the scripts. I recommend that beginners learn how to create these files on their own.


## 4. Disclaimer

As a beginner in R and sample survey estimation. I have done my best to keep the code uniform and well-commented. However, there may be mistakes and/or better ways to approach the task I set out to do. Please let me know if you spot any issues or have suggestions for improvement. I have not done an exhaustive check of formatting consistency or even other potential issues, so please don't hesitate to [open an issue](https://github.com/s7u512/NSSO-77-SAS/issues/new) or [reach out](https://twitter.com/all_awry).

## 5. Contributing

These scripts were designed for personal use, but if you would like to contribute to this project, feel free to fork the repository and make any modifications you see fit. I would like to expand the documentation to be a more generalisable guide towards sample survey estimations through R. If anyone is interested let me know/contribute.


## 6. License

This work is licensed under the [GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.html) license. This work is free: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This work is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

## 7. Acknowledgements

These scripts were inspired by [the work of Deepak Johnson](https://github.com/deepakjohnson91/NSSO-77-Round-SAS/). I would like to thank Deepak for his initial work and guidance in this project. Thanks are due also to friends and other colleagues from the [Foundation for Agrarian Studies](https://fas.org.in/) for all their help.
