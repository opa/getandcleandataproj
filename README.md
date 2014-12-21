README.md

This project analyzes data from a wearable technology study titled Human Activity Recognition Using Smartphones Dataset version 1.0.  There is a file in this directory named README.txt that describes this study.  The data for this project may be downloaded from here https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip  and a more detailed explanation of the underlying project and its data may be found here http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

The program in this folder conducts 5 tasks:
- Merges the training and the test sets to create one data set.
- Extracts only the measurements on the mean and standard deviation for each measurement. 
- Uses descriptive activity names to name the activities in the data set
- Appropriately labels the data set with descriptive variable names. 
- From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

The script run_analysis.R contains a method run_analysis() that does not require any parameters.  This is the main function that will do all the work.  This script will requires that the working directory is set to the location of the data files and that the data files are present (folders for test and train should be contained in this working directory and all files remain with original names.)

The overall approach taken is:
1)	read the summary data for each partition
2)	correlate the summary data to its subject , activity,  partition (test or train) and row number
3)	transform the data into a tidy set using plyr, dplyr and tidyr – save a copy of the tidy set
4)	group the data by the subject/activity/vectorname/axis  and calculate the mean of the measured observations: (a)mean of means and (b) mean of standard deviations 
5)	output the summary of this tidy set of data

In addition, it will read in all the raw data and extract the sum and mean for this data and include this in the above datasets.  (note:  I am doing this based upon my original interpretation of the assignment and the definition of extract (which is ‘to calculate’) as found in this thread: https://class.coursera.org/getdata-016/forum/thread?thread_id=218  … since this was my original interpretation of the assignment, I include it here in addition to completing the assignment based upon the interpretation of Dave FAQ https://class.coursera.org/getdata-016/forum/thread?thread_id=50 as found here, and I combine the two sets of information to give a complete set of means across all vectors … so if you are used to just Dave’s set of data, you’might notice some extra datapoints, but the ones you are used to will still line up and have matching values.  (notice that there are 5940 x 6 data points for the features data, and there are 1620 x 6 data points for the raw data yielding a total of 7560 rows by 6 columns).

Reading in the x_*.txt data:
The program first uses data from the x_train.txt and the x_test.txt data files.   Train and Test correspond to arbitrary partitioning of the data into a 30% 70% split.  As part of the program the data from the two partitions are remerged together into a single set. 

To import the data from these files, column headers are referenced from a file named features.txt. The names of the columns are found in the features.txt where each row in the latter corresponds to a column in the x_*.txt file.  Because x_train and x_test contain more columns of information than is necessary for this study, unused columns are discarded.    Only columns that contain std or mean but not meanFreq are selected – corresponding to the mean and standard deviation values used for this analysis.  The rows in the features.txt file are read into a recordset and using regular expressions a Boolean vector is created and used to eliminate unnecessary data from the dataset.  

Correlation strategy
Row keys are next added to this data set, from subject_*.txt and y_*.txt files found in the respective train or test folders.  Y_*.txt indicates what activity this row describes.  A lookup for the activity is found in the root working directory named features.txt.  The combination of this information is not unique, so an additional index is created incrementing the rows.  This index is an incremental number counting out the number of readings for a given subject/activity.  The result is a primary key of “subject id, activity id, index, partition”

Transform strategy - Tidy Data
The data is then reshaped to make it tidy.  This discussion spells out the overall strategy for creating a tidy data set.  In this setting, it concludes that the tidy data set would have a single observation( row ) to include two measurements – the mean and the standard deviation, for the observation.  The observation is uniquely identified by all other data which includes : the name of the vector, the axis the measurement is on, the activity, the subject, the partition of data, and the row index.  Specific reference to tidy as it pertains to this data can be found here:

"For this assignment we are only using the features involving the standard deviation and the mean as a subset of all the available features.

3 - I would say they are discrete members of the set of observations, as it is possible for an action to change a y direction reading in the phone without changing a x or z direction reading"

https://class.coursera.org/getdata-016/forum/thread?thread_id=100


Summarizing the data
Summarise.features.tidy() is the method that creates a summary of the data using dplyr and tidyr to goup_by the collection of (subjected, activity, vector name, axis) and calculates the mean of the mean values and the mean of the standard deviation values for all measurements .

Once the data is summarized, the summary data is written to a .txt file placed in the working folder.  In addition, cached versions of the two datasets are also written to the working folders as RDS files (R object files), so subsequent runs are much faster.




CODEBOOK


This project analyzes data from a wearable technology study titled Human Activity Recognition Using Smartphones Dataset version 1.0.  There is a file in this directory named README.txt that describes this study.  The data for this project may be downloaded from here https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip  and a more detailed explanation of the underlying project and its data may be found here http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

Overall there are 7560 x 6 data points correlating to:
    1620 x 6 datapoints derived from the raw data in interval signals folders
     7560 x 6 datapoints derived from the features summary data found in x_*.txt files

The 6 columns of the tidy data set include 4 keys and 2 measures detailed:
   Subject ID – integer value variable from 1 to 30 uniquely identifying the subject across observations . 
   Activity – this key is a factor text value variable indicating one of the six possible activities performed during the measurement  These values are sourced at activity_labels.txt
   Vector – this key is a character value variable indicating the vector as derived from the names found in source file features.txt
  Axis – this key is a text field variable indicating the Cartesinal direction of the measured value – possible values are X,Y,Z and there are some measurements that there is no value indicating that type of measurement is not broken into caresinal components
   Mean.mean – this is a numeric measurement calculating the mean of the mean values across all the recordings for the same type of activity matching the keys of this row (observation).  This value does not have units, and is always between -1 and 1 as the underlying data was normalized between these values as explained in the study’s original documentation and on this FAQ. https://class.coursera.org/getdata-016/forum/thread?thread_id=50
  Mean.std – this is a numeric measurement calculating the mean of the standard deviation across all the recordings for the same type of activity matching the keys of this row (observation).   This value does not have units and is always between -1 and 1 as the underlying data was normalized between all rows in this study as explained in the study’s original documentation and on this FAQ. https://class.coursera.org/getdata-016/forum/thread?thread_id=50 
    
Tidy data
The output conforms to Tidy Data as it is a datafile that consists of 6 columns where all the columns follow Hadley’s recommendations of tidy data. <link>
Hadley recommends tidy data have these 3 criteria:

In addition, there are notes from the TA in the coursera forum <link> indicating that each axis is its own observation and contains two columns of measurements – mean and standard deviation.  Excerpt quoted below:   

"For this assignment we are only using the features involving the standard deviation and the mean as a subset of all the available features.

3 - I would say they are discrete members of the set of observations, as it is possible for an action to change a y direction reading in the phone without changing a x or z direction reading"

https://class.coursera.org/getdata-016/forum/thread?thread_id=100


