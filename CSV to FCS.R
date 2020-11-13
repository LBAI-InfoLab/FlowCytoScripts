# Install packages if required
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("flowCore")
if(!require('data.table')) {install.packages('data.table')}

# Load packages
library('flowCore')
library('Biobase')
library('data.table')

#csv2 to csv1 
dir<-file.path("D:/LMD")
File<-dir(dir, full=T)
File.Name<-dir(dir)
dir.create(paste0(dir,"/CSV1"))
for( i in 1:length(File)){
  csv2<-read.csv2(File[i], header = T)
  colnames(csv2)<-gsub("\\."," ",colnames(csv2))
  write.csv(csv2,paste0(dir,"/CSV1/", sub(".csv","",File.Name[i]),".csv"), row.names = F)
}


# Use this to manually set the working directory
setwd("D:/LMD/CSV1")                          
getwd()                                                         
PrimaryDirectory <- getwd()                                     
PrimaryDirectory

## Use to list the .csv files in the working directory -- important, the only CSV files in the directory should be the one desired for analysis. If more than one are found, only the first file will be used
FileNames <- list.files(path=PrimaryDirectory, pattern = ".csv")     
as.matrix(FileNames) 

## Read data from Files into list of data frames
DataList=list() 
# Creates and empty list to start 

for (File in FileNames) { 
  tempdata <- fread(File, check.names = FALSE)
  File <- gsub(".csv", "", File)
  DataList[[File]] <- tempdata}

rm(tempdata)
AllSampleNames <- names(DataList)

## Chech data quality
head(DataList)

##### END USER INPUT #####

x <- Sys.time()
x <- gsub(":", "-", x)
x <- gsub(" ", "_", x)

newdir <- paste0("Output_CSV-to-FCS", "_", x)

setwd(PrimaryDirectory)
dir.create(paste0(newdir), showWarnings = FALSE)
setwd(newdir)

for(i in c(1:length(AllSampleNames))){
  data_subset <- DataList[i]
  data_subset <- rbindlist(as.list(data_subset))
  dim(data_subset)
  a <- names(DataList)[i]
  
  metadata <- data.frame(name=dimnames(data_subset)[[2]],desc=paste('column',dimnames(data_subset)[[2]],'from dataset'))
  
  ## Create FCS file metadata - ranges, min, and max settings
  #metadata$range <- apply(apply(data_subset,2,range),2,diff)
  metadata$minRange <- apply(data_subset,2,min)
  metadata$maxRange <- apply(data_subset,2,max)
  
  data_subset.ff <- new("flowFrame",exprs=as.matrix(data_subset), parameters=AnnotatedDataFrame(metadata)) 
  head(data_subset.ff)
  write.FCS(data_subset.ff, paste0(a, ".fcs"))}
