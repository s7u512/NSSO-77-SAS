# Getting Started

Read this document first to get started.

## 1. Requirements

You can download and install R from [here](https://cloud.r-project.org/)
I highly recommend downloading and installing an Integrated Development Environment for R. I used [RStudio](https://posit.co/products/open-source/rstudio/) in my exercise.

Get the raw data and other documentation for this survey. (I have provided some links for this in the [README file](https://github.com/s7u512/NSSO-77-SAS/blob/main/README.md), however you may need to find different links at the time of viewing this.)

NSSO provides the unit level data as fixed width text files. The data is split into multiple levels for each visit (There are two visits). Download everything. 
NSSO provides a spreadsheet that contains the layout information. This includes the widths of different variables and their names, the information contained in each level, and some other less relevant information.

In the future I will be documenting how to use this file to prepare the lists that I have prepared and provided in this repo to help with the analysis.

## 2. Folder Structure

Decide a working directory (a folder/directory in which you will do the work. I have used `/home/user/Desktop/SAS2019` as my folder.
The scripts provided here assumes the following folder structure in the working directory:
`/home/user/Desktop/SAS2019/Raw Data` in which all the raw data are stored, including all levels from both visits
`/home/user/Desktop/SAS2019/Output` which can be empty to begin with. This will get populated with all the calculated data frames in the form of .csv and .RData files as we execute the scripts.


# 3. Running the Scripts

After these folders are made, bring all the six scripts and the six lists and place them on the working directory (in this case `/home/user/Desktop/SAS2019`)
Open the first script using RStudio or R. 
Run the script. 
Repeat the process for all the scripts in order.

You are done. 
The outputs will be generated in the /Output folder.
