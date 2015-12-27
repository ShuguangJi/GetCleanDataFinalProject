
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "data.zip")##No method="curl" used.
unzip("data.zip");
file.rename("UCI HAR Dataset","data");

#1.Merges the training and teh test sets to create one dataset.
TrainSet<-read.table("data/train/X_train.txt");
TestSet<-read.table("data/test/X_test.txt");
SetData<-rbind(TrainSet,TestSet);

TrainLabel<-read.table("data/train/y_train.txt");
TestLabel<-read.table("data/test/y_test.txt");
LabelData<-rbind(TrainLabel,TestLabel);

TrainSubj<-read.table("data/train/subject_train.txt");
TestSubj<-read.table("data/test/subject_test.txt");
SubjData<-rbind(TrainSubj,TestSubj);

names(SubjData)<-c("subject");
names(LabelData)<-c("activity");
DataFeatureNames<-read.table("data/features.txt",head=FALSE);
names(SetData)<-DataFeatureNames$V2;

DataCombine<-cbind(SubjData,LabelData);
Data<-cbind(SetData,DataCombine);

#2. Extracts only teh measurements on the mean and standard deviation for each measurement.
SubFeature<-DataFeatureNames$V2[grep("mean\\(\\)|std\\(\\)", DataFeatureNames$V2)];
SelectedNames<-c(as.character(SubFeature), "subject", "activity" );
Data_Mean_Sd<-subset(Data,select=SelectedNames);

#3. Uses descriptive activity names to name the activities in the data set.
DataDesc<-Data_Mean_Sd;
ActivityLabel<-read.table("data/activity_labels.txt",header = FALSE);
DataDesc$activity<-factor(DataDesc$activity);
DataDesc$activity<- factor(DataDesc$activity,labels=as.character(ActivityLabel$V2));

#4. Appropriately labels teh data set with descriptive varialbe names.
names(DataDesc)<-gsub("^t", "Time", names(DataDesc))
names(DataDesc)<-gsub("^f", "Frequency", names(DataDesc))
names(DataDesc)<-gsub("Acc", "Accelerometer", names(DataDesc))
names(DataDesc)<-gsub("Gyro", "Gyroscope", names(DataDesc))
names(DataDesc)<-gsub("Mag", "Magnitude", names(DataDesc))
names(DataDesc)<-gsub("BodyBody", "Body", names(DataDesc))

#5. From the data set in step 4, creates a second, independently tidy data
#set with the average of each variable for each activity and each subject. 
D2<-aggregate(x=DataDesc, by=list(activities=DataDesc$activity, subj=DataDesc$subject), FUN=mean)
D2<-D2[, !(colnames(D2) %in% c("subj", "activity"))]
str(D2)
write.table(D2,'submission.txt', row.names = F)

