# This R script does the following: 
#
# 1. Merges the training and the test sets to create one data set.
#
trainData <- read.table("./data/train/X_train.txt")
dim(trainData) # 7352*561
head(trainData)
trainLabel <- read.table("./data/train/y_train.txt")
table(trainLabel)
trainSubject <- read.table("./data/train/subject_train.txt")
table(trainSubject)
testData <- read.table("./data/test/X_test.txt")
dim(testData) # 2947*561
testLabel <- read.table("./data/test/y_test.txt") 
table(testLabel) 
testSubject <- read.table("./data/test/subject_test.txt")
table(testSubject)
#
# Joining all the corresponding data sets of train and test
#
joinData <- rbind(trainData, testData)
dim(joinData) # 10299*561
joinLabel <- rbind(trainLabel, testLabel)
dim(joinLabel) # 10299*1
sum(table(joinLabel))
head(joinLabel)
joinSubject <- rbind(trainSubject, testSubject)
dim(joinSubject) # 10299*1
sum(table(joinSubject))
head(joinSubject)
# 
# Step2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 
features <- read.table("./data/features.txt")
dim(features)  # 561*2
head(features)
meanStdIndices <- grep("mean\\(\\)|std\\(\\)", features[, 2])
length(meanStdIndices) # 66
joinData <- joinData[, meanStdIndices]
dim(joinData) # 10299*66
head(joinData)
colnames(joinData)
names(joinData) <- gsub("\\(\\)", "", features[meanStdIndices, 2]) # removing "()" in all column names
names(joinData) <- gsub("mean", "Mean", names(joinData)) # capitalizing mean to Mean
names(joinData) <- gsub("std", "Std", names(joinData)) # capitalizing std to Std
names(joinData) <- gsub("-", "", names(joinData)) # removing "-" in all column names 
#
# Step3. Uses descriptive activity names to name the activities in 
# the data set
#
activity <- read.table("./data/activity_labels.txt")
activity[, 2] <- tolower(gsub("_", "", activity[, 2]))
substr(activity[2, 2], 8, 8) <- toupper(substr(activity[2, 2], 8, 8))
substr(activity[3, 2], 8, 8) <- toupper(substr(activity[3, 2], 8, 8))
activityLabel <- activity[joinLabel[, 1], 2]
joinLabel[, 1] <- activityLabel
names(joinLabel) <- "activity"


# Step4. Appropriately labels the data set with descriptive activity 
# names. 
names(joinSubject) <- "subject"
cleanedData <- cbind(joinSubject, joinLabel, joinData)
dim(cleanedData) # 10299*68
head(cleanedData)
tail(cleanedData)
write.table(cleanedData, "merged_data.txt") # writing out the First dataset to a file
#
# 5. Creates a Second, independent tidy data set with the average of each variable for each activity and each subject.
#
#### Getting the mean for all values for all the subjects using melt and cast
#
library("reshape2")
head(cleanedData)
sortedSubject <- cleanedData[order(cleanedData$subject,cleanedData$activity),]
head(sortedSubject)
meltedSubject <- melt(sortedSubject,id.vars= c("subject","activity"))
head(meltedSubject)
castedSubject <- dcast(meltedSubject, subject+activity ~ variable, fun.aggregate=mean)
head(castedSubject)
dim(castedSubject)
write.table(castedSubject, "data_set_with_the_averages.txt",row.name=FALSE ) # writing out the Second dataset to a file

