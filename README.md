# Estimation Scripts for SAS 2019 (NSSO 77)

These R scripts were developed as a personal project to learn sample survey estimation using [R](https://www.r-project.org/about.html) and [RStudio](https://github.com/rstudio/rstudio). The scripts were heavily influenced by my friend [Deepak's work on the same topic](https://github.com/deepakjohnson91/NSSO-77-Round-SAS/). I started out trying to replicate his work from scratch. However, I have ended up deviating enough to not be able to call it a fork anymore, and therefore decided to create my own repository.

I have written a [primer on the process](https://fas.org.in/nsso-survey-sas-2019-using-r-for-beginners/) undertaken here, that will be of use to beginners. 

The scripts here are simple and heavily commented to be useful to beginners. Read the [instructions](https://github.com/s7u512/NSSO-77-SAS/blob/main/00_Instructions.md) to get started.

These scripts are designed to estimate the results of the Situation Assessment Survey of Agricultural Households conducted by NSSO in 2019 - also known as _*NSS 77 th Round for Schedule- 33.1, January 2019 – December 2019,(Land and Livestock Holding of Households and Situation Assessment of Agricultural Households)*_. Unit-level data along with a report was published by the National Statistical Office in September 2021.

The scripts are specifically tailored to work with the unit-level data from this survey published as fixed width text files. There are some changes in the formats and availability of this data. Instructions on necessary modifications can be found [here](https://github.com/s7u512/NSSO-77-SAS/blob/main/New_Format_Instructions.md).

## 1. Situation Assessment of Agricultural Households (2019)

[National Sample Survey](https://www.mospi.gov.in/national-sample-survey-nss) under the Ministry of Statistics and Programme Implementation of Government of India is responsible for the conduct of large scale sample surveys in diverse fields on an all India basis. They conducted their 77th Round of surveys in 2018-19. Among different topics covered in this round was the assessment of farming conditions in India. This was covered in Scheduled 33.1. [A report](https://ruralindiaonline.org/en/library/resource/situation-assessment-of-agricultural-households-and-land-and-livestock-holdings-of-households-in-rural-india/) along with the unit-level data, was published by the National Statistical Office in September 2021. A brief review of this survey and some results from the past can be found in the two links given below.
1. [Situation Assessment Survey of Agricultural Households 2019: A Statistical Note by Aparajita Bakshi](http://ras.org.in/situation_assessment_survey_of_agricultural_households_2019_a_statistical_note) 
2. [The Situation Assessment Surveys: An Evaluation by Biplab Sarkar](http://ras.org.in/index.php?Article=the_situation_assessment_surveys&q=biplab&keys=biplab)

## 2. Data

### 2.1 Availability

The unit-level data and documentation associated with this can be found [here](http://microdata.gov.in/nada43/index.php/catalog/157)

Currently one needs to create an account with MoSPI in order to get access to this data. This process, at the moment, seems unreliable due to seemingly technical issues. Please let me know if there is a better and more reliable way to obtain the data, or if you think I am missing something about the process.

The full list of unit-level datasets and documentation associated with this used to be publicly available [here](https://mospi.gov.in/web/mospi/download-tables-data/-/reports/view/templateFour/25302?q=TBDCAT) or [here](https://mospi.gov.in/unit-level-data-report-nss-77-th-round-schedule-331-january-2019-%E2%80%93-december-2019land-and-livestock). One way to obtain some of the files is through archive.org.

[Reach out](https://twitter.com/all_awry) for any help/clarifications. 



This survey contains household level information of a sample of the population of India, from two visits in 2019. All of the scripts here use data from both survey visits. NSSO provided the data for different aspects such as demographic information, cost of cultivation etc. in different blocks.

Using the provided documentation, the unit-level data is read into data frames, which can be manipulated, exported, and merged. (To do this, I have prepared some lists for use in calculations, based on the documentation. These files are uploaded here along with the scripts. Nonetheless it is recommended that a beginner learns to prepare such files themselves by going through the documentation.)

### 2.2 Extraction

Currently the unit level data is provided in the proprietary `.nesstar` format, along with a Nesstar Explorer executable installer. Read [this](https://github.com/s7u512/NSSO-77-SAS/blob/main/New_Format_Instructions.md) on how to proceed using such data or formats such a `.sav` or `.dta`. 

The unit level data used to be available in fixed width text files that can be easily read.

In this exercise, we are using unit level data in fixed width files. (Documentation on how to read them, such as information about the widths of different columns and their respective column names, and other details such as application of weights was available in the old documentation.)

### 2.3. Estimation

This is a sample survey. From the information of the surveyed sample of households, an estimation can be made about the population's information. So, the goal is to estimate the population and its characteristics from the sample data. NSSO provides the weights of the samples to enable this. ([Here](https://unstats.un.org/unsd/demographic/meetings/egm/sampling_1203/docs/no_5.pdf) is a document to understand the concept of sample weights.)

The calculations in these scripts are performed after applying sample weights provided by the NSSO.

The scope of this exercise concludes at estimating monthly household incomes of agricultural households in India during the agricultural year 2018-19 using the paid-out costs approach. The idea is to seperately calculate different components of household income (such as income from farming, income from wages, etc.) and then merge them together to calculate the monthly household income of the agricultural households. The income from each component is computed separately using the appropriate weights and other relevant variables. These component datasets are then combined together to obtain the household income. [The report](https://ruralindiaonline.org/en/library/resource/situation-assessment-of-agricultural-households-and-land-and-livestock-holdings-of-households-in-rural-india/) published along with the unit-level data is relied upon to verify the estimations.

The scripts are heavily commented and should be easy to follow, even for those with limited experience in R. Note that the scripts are specifically tailored to work with the fixed width files published from the 2019 round of the survey.

Despite the limited scope, the idea is that if a beginner is able to follow through this exercise they would be equipped to carry out further analysis as they require.

## 3. Contents and Usage

Read [these instructions](https://github.com/s7u512/NSSO-77-SAS/blob/main/00_Instructions.md) to get started. The R scripts in this repository contain the code and comments for reading, estimating, and conducting basic analysis of the unit-level data from Schedule 33.1 of the 77th round by NSSO. There are a few supporting files prepared based on the documentation, for use in the scripts. I recommend that beginners learn how to create these files on their own. 

Read [these instructions](https://github.com/s7u512/NSSO-77-SAS/blob/main/New_Format_Instructions.md) for some help with modifying this script to work with unit-level data in `.nesstar`, `.sav` or `.dta` formats.

## 4. Disclaimer

I am a beginner in both R and sample survey estimation. 

I have done my best to keep the code uniform and well-commented. However, there may be mistakes and/or better ways to approach the task I set out to do. Please [let me know](https://twitter.com/all_awry) if you spot any issues or have suggestions for improvement.

I have not done an exhaustive check of formatting consistency or even other potential issues, so please don't hesitate to [open an issue](https://github.com/s7u512/NSSO-77-SAS/issues/new) or [reach out](https://twitter.com/all_awry) if you find something.

## 5. Contributing

These scripts were designed for personal use, but if you would like to contribute to this project, feel free to fork the repository and submit a pull request. I would like to expand the documentation to make it sufficient for someone to start from absolute scratch. I would also like to expand this work into a more generalisable guide towards sample survey estimations through R. If you are interested let me know/contribute.

## 6. License

This work is licensed under the [GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.html) license. This work is free: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This work is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

## 7. Acknowledgements

This is a personal project. These scripts were inspired by [the work of Deepak Johnson](https://github.com/deepakjohnson91/NSSO-77-Round-SAS/). I would like to thank Deepak for his initial work and guidance in this project. Thanks are due also to friends and other colleagues from the [Foundation for Agrarian Studies](https://fas.org.in/) for all their help.
