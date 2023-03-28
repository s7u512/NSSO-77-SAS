# New Format Instructions

Instructions on how to modify the existing code to work with formats other than fixed width files are what follow.

## Nesstar

[Nesstar](https://en.wikipedia.org/wiki/Nesstar "wikipedia link") was a software system for data management maintained by the [Norwegian Social Science Data Services](https://en.wikipedia.org/wiki/Norwegian_Centre_for_Research_Data "Norwegian Centre for Research Data") (also known as **NSD**). Currently the [micro-data catalogue](http://microdata.gov.in/nada43/index.php/catalog/central/about) provides the raw data as a compressed set of three files - the Nesstar Explorer installer for Windows, a PDF file with instructions on how to get data from the website, and a `.nesstar` file.

The `.nesstar` format is proprietary and requires the software provided to view and export the data into other select formats such as:

1.  IBM® SPSS® Statistics data format `.sav`

2.  Stata `.dta` dataset

3.  Delimited `.txt` files

among other formats. I will briefly comment about these three formats alone here. But first, a word about extracting data from the `.nesstar` files.

## Using Nesstar Explorer

The nesstar explorer installer is provided along with the raw data, as I mentioned earlier. However, it comes as an `.exe` file, which is primarily meant for the Windows operating system. However, it is possible to make this run in a GNU/Linux or MacOS system through the use of another software called [wine](https://en.wikipedia.org/wiki/Wine_(software)).

If you are using Microsoft Windows, you can just execute the installer by double clicking it, and following instructions to install the software.

If you are using any version of GNU/Linux, I recommend using this software called [Bottles](https://docs.usebottles.com/getting-started/installation) available as a flatpak package. This is the easiest and most hassle free way to do it. It uses wine, but also has a nice GUI and is very user friendly. There is nothing you need to configure.

If you are using MacOS, I hear there are ways to install wine in it, and run the installer through that. Not sure about anything more except that there's a way.

Now on to a brief discussion on the available formats.

## Delimited files

These files have two advantages - they are the smallest sizes to export to, and load the fastest.

Actually there is a third advantage in that variable types are the closest to what you would actually want. Leading zeroes are preserved as character only for variables that *should be so*.

Here is some example code:

``` r
library(readr)

L3_V1 <- read_delim("Visit1  Level - 03 (Block 4) - demographic and other particulars of household members.txt", col_names = FALSE)
```

However, the disadvantage is that without information regarding the layout of the file, such as column titles, the file will be somewhat difficult to work with. I still have no clue as to where to get the column titles from through the Nesstar Explorer. The data is there, it is just not exportable as column titles alone I think. Let me know if you find the answer to this.

## STATA and SPSS file formats

These file formats can be read using the functions from the `haven` package. They take longer to load (with not much observable difference between each other).

Here is some example code:

``` r
library(haven)

L3_V1_SPSS <- read_sav("Visit1  Level - 03 (Block 4) - demographic and other particulars of household members.sav")

L3_V1_STATA <- read_stata("Visit1  Level - 03 (Block 4) - demographic and other particulars of household members.dta")
```

However, both the formats have the advantage of providing a well labelled data frame.

I personally prefer creating the variable names from a layout file that is provided, but this is definitely the next best thing. I keep getting thrown off by the variable names bearing no resemblance to the labels.

The variable name is essentially the block number and question number put together, such as `b4q8` while labels provide a verbose description of the variable (in this case `expenditure on purchase of household durable during last 365 days (D)`)

The drawback here is that `NA` values appear as blanks, and variable types are not always what you want them to be.

## Modifying the scripts in this repository

If you are cloning this repo and making changes, make it a fork, make the changes, and upload that if possible. Everyone would benefit.

Basically what needs to be done are a couple of things.

1.  In each script, change the few lines pertaining to reading in the raw data in each script (akin to the sample codes provided above).

2.  I am assuming some changes in variable types are required if you are using `.dat` or `.sav` formats. (For example, Religion Code is a character variable instead of a numeric with range 0-9. Maybe this is fine, maybe there are cases where this is not fine. Let me know if you do this.

3.  The big headache is replacing all the variable names used in the scripts with the variable names that the data frames from the new format uses.

4.  Some decision will have to be taken about the mutated variables and labels too. This can be done. Some example code below:

    ``` r
    library(dplyr)
    library(labelled)

    # Create a sample data frame
    df <- data.frame(x = c(1, 2, 3), y = c(4, 5, 6))

    # Mutate variable x and assign a label
    df <- df %>%
      mutate(x_new = x * 2) %>%
      label(x_new = "New label for x_new")

    # Print the data frame with labels
    df
    ```

5.  Another issue common to any format emanating from the `.nesstar` file is that of Household ID. The `.nesstar` data has a pre-made Household ID column (while my script constructs one each time because the fixed width files did not come with it). Note that even though both Household IDs are following the documentation they are not the same. The Household IDs in these scripts have extra separator 0s in them. On the whole it might be a better idea to remove the code that creates household IDs. Keep an eye on column numbering though, as the pre-existence of the Household IDs may mean sometimes a column number 11 becomes column number 12.

I think that is about all. Should be a day's work at most, going through the scripts and making these changes.

Once again, if you do this, please let me know and/or fork the repository (I strongly suggest a GPLv3 license). It's just that I have already done all this work, and I only have half a mind to split this repo into two directories called `Old method` and `New method` or something, and upload all the changes here.

Thanks for reading. Consider contributing. Please [reach out](https://twitter.com/all_awry) if anything is not clear enough for you. Feel free to [open an issue](https://github.com/s7u512/NSSO-77-SAS/issues/new) if you come across any.

## 
