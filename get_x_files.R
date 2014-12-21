#### Bruce Pezzlo 5 Dec 2015
### Jonhs Hopkins MOOC - Getting and Cleaning Data
### 
### this library is meant to be included from run_analysis.R
###
### it serves two functions:   
###        (1) retrieve the features tidy data set from the data provided 
###        (2) summarizing features tidy data
### 
### -- features.tidy ():
### its purpose is to read in all the summary feature calculations related to mean and standard deviation
### first it reads in the column headings to determine which columns should be stored
### then reads in the data and appends a key to the rows based upon the observation key
### then it turns the data into a tidy set using tidyr to reshape the so that there are key columns and two measures per observation
###    the two measures per observatino are the mean and the standard deviation numeric values
###    all other columns form the key factors describing these measurements, they include
###               activity / subjectid / partition / vectorname /  axis (not every vector has an axis value, see readme and codebook for more)
###                         
### -- summarise.is ( datatable )
### taking the dataframe from the read.inertialsignals tidy data as input
### this functin uses dplyr to group the data by subject / activity and provide the 
###        mean of each of the mean and standard deviation values across an subject/activity


feature.labels <- function() {
  #Read in the features.txt, containting the labels, then clean up the file
  #only consider rows that have mean or std in the label 
  #     especially ignore capital M Mean as this relates to angles where one of the vectors is a mean ... i
  #         this value in and of itself is ~not~ a mean value
  #     get rid of paranthesis and dashes
  #     find the ordinal values of the columns, to only read in these columns from the fixed width file, ignoring all other data
  df <- read.lookup(dataFileName= get.filename(file= 'features.txt',
                                                    partition = ''),
                         column= c('index', 'label'))
  df$filtered <- grepl("(std)|(mean[^Freq])", df$label, perl=TRUE) 
  df$label <- gsub("[()]", "", df$label, perl=TRUE) 
  df$label <- gsub("-", "_", df$label, perl=TRUE) 
  df[df$filtered==TRUE,]$filtered <- !grepl("meanFreq_[XYZ]$", df[df$filtered==TRUE,]$label, perl=TRUE)
  df$label <- sub("(mean$)", "mean_-", df$label, perl=TRUE) 
  df$label <- sub("(std$)", "std_-", df$label, perl=TRUE)  
  df$index <- as.numeric(df$index)
  df
}
feature.partition <- function(partition, labels){
  partition.factors.df <- read.factors(partition)
  # because the rows are not unique by activity, subjectid, and partition alone - added an index column of sequential numbers row where these 3 values are equal
  # in other words there can be multiple rows where subject 2 in test is Standing ... and this will give each of these rows a unique number
  partition.factors.df$index <- ave( 1:nrow(partition.factors.df), 
                                     partition.factors.df$subjectid, 
                                     partition.factors.df$partition, 
                                     partition.factors.df$activity, 
                                     FUN=seq_along )
  fixed.columns <- colnames(partition.factors.df)    
  features.df <- read.data.fw(dataFileName= get.filename(file= '<partition>/x_<partition>.txt',
                                                         partition = partition),
                              columnCount = 561, 
                              columnWidth = 16)
  subset.features.df <- features.df[,labels$filtered]
  rm(features.df)
  subset.features.df <- setNames(subset.features.df, labels[labels$filtered,]$label)
  cbind(partition.factors.df, subset.features.df)
}

features.tidy <- function() {
  #if the files have already been processed, just use the cached version  
  if (file.exists('features_tidy_df.RDS')) {
    # Load archived version from drive
    features.tidy.df <- readRDS("features_tidy_df.RDS")    
  } else { 
    #create a dataset for the partition
    # read in column labels for x_*.txt files as found in features.txt
    labels <- feature.labels()
    # create an empty dataframe
    features.df <- data.frame()
    # read in the x_test.txt file and the x_train.txt files
    for (partition in partitions){
      # read in the partition data
      feature.partition.df <- feature.partition(partition, labels)  
      # merge the two partions data together
      features.df <- rbind(features.df, feature.partition.df)    
    }
    # use tidyr to tidy up the raw data
    #        specifically - break out each column from feature file so that they become rows of the table
    #        then split the name of the column across three columns based upon each column name containing:
    #             a) the name of the vector it describes
    #             b) when available the axis (x,y,z) that the observation describes (NA for measurements not related to an axis)
    #             c) the calculation of being performed on the value (mean or standard deviation)
    #        then spread the calculation across the columns because these are derived from the same observation measurement
    #               resulting in two data columns: mean and std
    #                         and a key of: subjectid, partition, activity, index of reading for subject/activity, vector, axis
    library(reshape)
    features.df <- melt(features.df, names(features.df)[1:4] )
    features.df <- setNames(features.df, c('subjectid', 'partition', 'activity', 'index', 'measure_calc_axis', 'value'))
    library(tidyr)
    library(dplyr)    
    features.tidy.df <- tbl_df(features.df)  #convert dataframe to dplyr's own table dataframe object
      #features.tidy.df <- features.tidy.df %>%
      #gather(measure.calc.axis, value, -subjectid, -partition, -activity, -index) %>%
      features.tidy.df <- separate(features.tidy.df, measure_calc_axis, c("vector", "calc", 'axis')) # %>%
      features.tidy.df <- spread(features.tidy.df, calc, value)
    # remove reference to NA from the data
    #features.tidy.df[features.tidy.df$axis=='NA',]$axis <- NULL
    # Save (archive) cached version of dataset as RDS for faster subsequent calls 
    saveRDS(features.tidy.df, file='features_tidy_df.RDS') 
  }#ifelse file exists
  features.tidy.df
}
summarise.features.tidy <- function(features.tidy.df) {
  # takes in a dataframe from features.tidy()
  # groups by the subject / activity, and the measurement (vector/axis)
  # calculates the mean of the mean values and the mean of the standard deviation values
  library(tidyr)
  library(dplyr)  
  summary.df <- features.tidy.df %>%
    group_by(subjectid, 
             activity,
             vector,
             axis) %>%
    summarise(mean.mean = mean(mean), 
              mean.std = mean(std))
  summary.df  
}

#syntax of to use this library :   summarise.features.tidy(features.tidy())




