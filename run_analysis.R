#### Bruce Pezzlo 5 Dec 2015
### Jonhs Hopkins MOOC - Getting and Cleaning Data
### HW 1
# Assignment is given a set of motion accelerometer data from Samsung phones:
# 1)  Merges the training and the test sets to create one data set.
# 2)  Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3)  Uses descriptive activity names to name the activities in the data set
# 4)  Appropriately labels the data set with descriptive variable names. 
# 5)  From the data set in step 4, creates a second, independent tidy data set with the average 
#     of each variable for each activity and each subject.

#assumes user has set the working directory and placed the source files in the working directory

########################### 3 vectors as settings ######################################
partitions <- c('test', 'train')
axes <- c('x','y','z') 
measurements <- c('<partition>/Inertial\ Signals/body_acc_<axis>_<partition>.txt',
                  '<partition>/Inertial\ Signals/body_gyro_<axis>_<partition>.txt',
                  '<partition>/Inertial\ Signals/total_acc_<axis>_<partition>.txt')
########################################################################################
#important, plyr should be loaded before dplyr
required.packages <- c('plyr','reshape','dplyr','tidyr')
########################################################################################


get.filename <- function(file, partition = '') {
  # uses partition to find the exact path to file prepended with the working current working directory
  # for example c:/workingdirectory/activity_lables.txt
  paste(c(getwd(),
          "/",
          gsub("<partition>",  # for example: <partition>/y_<partition>.txt would become test/y_test.txt
               partition, 
               file)),
        sep="",
        collapse="")
}
read.lookup <- function(dataFileName, column) {
  #read in file and name columns based upon parameters passed
  df <- read.table(dataFileName, 
                   sep= " ",
                   header= FALSE, 
                   na.strings= FALSE)
  setNames(df, column)
}
read.data.fw <- function(dataFileName, columnCount = 128, columnWidth = 16) {
  # read in fixed width datafiles where column names are the index of columnCount
  read.fwf(file = dataFileName, 
           widths = replicate(columnCount, columnWidth), # create an array of columnwidths e.g. c(16,16 ...) for the number of columns in the file
           header = FALSE, 
           sep = "\t", 
           skip = 0, 
           col.names = (1:columnCount), # use a number for the column 
           n = -1, # no limit to maximum number of records to be read
           buffersize = 2000, 
           fileEncoding = "", 
           colClasses = replicate(columnCount, 'numeric'))
}

load.packages <- function (packages){
  #make sure environment has the appropriate installed packages and that they are loaded into library  
  for (package in required.packages){
    if(package %in% rownames(installed.packages()) == FALSE) {install.packages(package)}
    do.call(library, as.list(eval(package)))    
  }  
}

run_analysis <- function(){
  #setup work environment
  load.packages(packages) 
  # warning unless the cached file 'inertial.signals.RDS' is available
  ##   then (no cached file) the next line will take about 15 minutes
  ##   with cached file - this will execute almost instantly  
  ##   read in all the raw data into a single tidy dataset     
  ## read in the features files
  source('get_x_files.R')  
  features.tidy.df <- features.tidy()
  summary.features.df <- summarise.features.tidy(features.tidy.df)
  print(head(summary.features.df))
  ## read in the raw source files
  source('get_inertialsignals.R')  
  inertial.signals.tidy.df <- inertialsignals.tidy()  
  summary.signals.df <- summarise.inertialsignals.tidy(inertial.signals.tidy.df)  
  print(head(summary.signals.df))
  ## merge the inertial signals data and the x_*.txt information
  merged.df <- rbind(summary.features.df, summary.signals.df)
  print(head(merged.df))  
  write.table(merged.df,
              file="merged_summary_df.txt",
              row.name = FALSE)
  merged.df  
}





