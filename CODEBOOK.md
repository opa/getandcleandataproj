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
