#### Bruce Pezzlo 5 Dec 2015
### Jonhs Hopkins MOOC - Getting and Cleaning Data
### 
### this library is meant to be included from run_analysis.R
###
### two main functions:   
###        (1) reading the internal signals data 
###        (2) summarizing the data
### 
### -- read.inertialsignals():
### its purpose is to read in all the files in the 'inertial signals' folder
### it does this by looping through 3 vectors representing <partitions> <axis> and <measurements>
### then dynamically finding the appropriate files and pulling in the data
### the data is reshaped to melt the 128 timeframe columns into rows of one column per file
### the row is appended to an index based upon columns of activity / subjectid / partition / axis
### becuase this index is not unique (there are multiple readings per activity/subject) an additional identifer
### is created called index that when taken together with the columns timeframe column above creates a primary key
###
### -- summarise.is ( datatable )
### taking the dataframe from the read.inertialsignals tidy data as input
### this functin uses dplyr to group the data by subject / activity and provide the mean and standard deviation of data

read.factors <- function(partition) {
  #Read in the subjectid, Activity and partition as factors
  df <- data.frame()
  subject <- read.lookup(dataFileName= get.filename(file= '<partition>/subject_<partition>.txt',
                                                    partition),
                         column= 'subjectid')
  activity <- read.lookup(dataFileName= get.filename(file= '<partition>/y_<partition>.txt',
                                                     partition),
                          column= 'activityid')
  df <- cbind(subject, 
              activity, 
              partition=partition)
  df[,'subjectid'] <- as.factor(df[,'subjectid'])  
  df[,'activityid'] <- as.factor(df[,'activityid'])    
  activity.lookup <- read.lookup(dataFileName= 'activity_labels.txt', 
                                 column= c('activityid',
                                           'activity'))
  library(plyr)
  df <- join(x=df,
             y=activity.lookup,
             by="activityid",
             type="left")
  subset(df, select = c('subjectid','partition','activity') )
  
}
read.all.inertialsignals <- function() {
  print("get a cup of coffee, this is gonna take fifteen minutes")
  #create an empty dataset to fill in with the data from each partition
  partitions.df <- data.frame()
  for (partition in partitions) {
    #create a dataset for the partition
    partition.factors.df <- read.factors(partition)
    # because the rows are not unique by activity, subjectid, and partition alone - added an index column of sequential numbers row where these 3 values are equal
    # in other words there can be multiple rows where subject 2 in test is Standing ... and this will give each of these rows a unique number
    partition.factors.df$indx <- ave( 1:nrow(partition.factors.df), 
                                      partition.factors.df$subjectid, 
                                      partition.factors.df$partition, 
                                      partition.factors.df$activity, 
                                      FUN=seq_along )
    #create an empty axes.df to fill up by each axis    
    axes.df <- data.frame()
    for (axis in axes) {
      #create a dataset for the axis
      axis.df <- cbind(partition.factors.df, axis= axis)
      axis.df[,'axis'] <- as.factor(axis.df[,'axis']) 
      fixed.columns <- colnames(axis.df)
      #create an empty measurement.df to fill up
      measurements.df <- data.frame()
      for (measurement in measurements) {
        # total_acc_<axis>_<partition>.txt becomes total_acc_z_<partition>.txt 
        measurement <- gsub("<axis>", 
                            axis, 
                            measurement)
        # turn the filename into column name
        #   by removing file path and take first two words of file like this 'bodyacc'
        nameVector <-  gsub("<partition>/Inertial\ Signals/",
                                  "",
                                  paste(strsplit(measurement, "_")[[1]][1:2],
                                        sep="",
                                        collapse=""))
        # create axis as part of column with describing data (e.g. bodyAcc will have three columns bodyAccX, bodyAccY, bodyAccZ to match style of x_*.txt)
        prepend.cols.df <- cbind(partition.factors.df, vector= nameVector, axis= toupper(axis))
        fixed.column.names <- colnames(prepend.cols.df)
        measurement.df <- read.data.fw(get.filename(measurement, 
                                                    partition), 
                                       columnCount = 128, 
                                       columnWidth = 16)
        measurement.df <- cbind(prepend.cols.df, measurement.df)
        library(reshape)
        # convert the 128 columns of data into rows of data identified by the 'timewindow' integer of the column
        measurement.df <- melt(measurement.df,
                               id= fixed.column.names) 
        #set last two column names , to timewindow and the final one would be bodyacc for example
        measurement.df <- setNames(measurement.df,
                                   c(fixed.column.names,
                                     'timewindow',
                                     'value')
        )
        #create index on the timewindow column (values 1:128)
        measurement.df[,'timewindow'] <- as.factor(measurement.df[,'timewindow'])
        measurements.df <- rbind(measurements.df, measurement.df)
        rm(measurement.df) #remove from memory to prevent confusion
      }#for measurement
      #append the measurements to the running collection of axis
      axes.df <- rbind(axes.df, measurements.df)
      rm(measurements.df) #remove from memory to prevent confusion
    }#for axes
    #append the axes to the running collection of partition data
    partitions.df <- rbind(partitions.df, axes.df)  
    rm(axes.df) #remove from memory to prevent confusion
  }#for partition
  partitions.df
}
inertialsignals.tidy <- function() {
  # iterate through the three vectors of partitions, axes, and measurements, to dynamically read in 
  # all the data, building and building up a single dataset with all the data as a single tidy table consisting of:
  # a primary key made up of: (subjectid, partition, activity, axis, timewindow)
  # and 3 measurements made up of: (bodyacc, bodygyro, totalacc)

  #if the raw data has already been processed, just use the cached version
  if (file.exists('inertial.signals.RDS')) {
    # Load archived version from drive
    inertialsignals.df <- readRDS("inertial.signals.RDS")
  } else {  
    # loop through the files and read in the data
    raw.data.inertialsignals.df <- read.all.inertialsignals()
    # now take this large dataset that is a tidy version of all readings
    # and produce the standard deviation and mean for each variable
    library(dplyr)
    # use dplyr to format data as needed
    #    dplyr uses this syntax select(), filter(), arrange(), mutate(), and summarize()
    # use dplyr's data frame tbl
    raw.data.is.df <- tbl_df(raw.data.inertialsignals.df)  #convert dataframe to dplyr's own table dataframe object
    rm(raw.data.inertialsignals)
    inertialsignals.df <- raw.data.is.df %>%
                group_by(subjectid, 
                         activity,
                         indx,
                         vector,
                         axis) %>%
                summarise(mean= mean(value),
                          std= sd(value)) 
    inertialsignals.df$subjectid <- as.numeric(inertialsignals.df$subjectid)
    # rearrange this data because first groupby used subjectid as factor text as opposed to numeric
    inertialsignals.df <- inertialsignals.df %>% arrange(subjectid,
                              activity,
                              indx)
    # Save (archive) cached version of dataset as RDS for faster subsequent calls 
    saveRDS(inertialsignals.df, file='inertial.signals.RDS') 
  }# else manually loaded the data
  write.table(inertialsignals.df,
              file="intertialSignals_df.txt",
              row.name = FALSE)
  inertialsignals.df
}

summarise.inertialsignals.tidy <- function(df) {
  library(dplyr)
  # use dplyr to format data as needed
  #    dplyr uses this syntax select(), filter(), arrange(), mutate(), and summarize()
  # use dplyr's data frame tbl
  is.df <- tbl_df(df)  #convert dataframe to dplyr's own table dataframe object
  is.df <- is.df %>%
     group_by(subjectid, 
             activity,
             vector,
             axis) %>%
     summarise(mean.mean = mean(mean),
               mean.std = mean(std)
               ) 
  is.df$subjectid <- as.numeric(is.df$subjectid)
  is.df %>% arrange(subjectid, 
                    activity) 
  is.df
}

#syntax of to use this library :   summarise.inertialsignals.tidy(inertialsignals.tidy())
