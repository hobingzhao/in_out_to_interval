## --- DATA SOURCE ---
library(openxlsx)
data <- read.xlsx("data.xlsx")
# get dates
data$DateTime_Start <- convertToDateTime(data$DateTime_Start)
data$DateTime_End <- convertToDateTime(data$DateTime_End)
## --- END DATA SOURCE --

# recursive interval munger!

## --- SETUP VARIABLES ---
# data - data table
# minSeconds - interval in seconds e.g. 15 min interval is 900. Should be either 900 (15min), 1800 (30min), or 3600 (60min).
minSeconds <- 900
# boolShiftHalf - TRUE means start and end datetimes will be shifted half of the minInterval to reduce shifting of dates to the left
boolShiftHalf <- TRUE
# colDtStart, colDtEnd = strings of start and end date times
colDtStart <- 'DateTime_Start'
colDtEnd <- 'DateTime_End'

# reserve the following headers: clean_DT_Start, clean_DT_End, clean_DT_Stamp, clean_BusyIndex, clean_IntervalsPerEntry, clean_BusyDensity
# these will be needed

# get the dates ready
data$clean_DT_Start <- data[,colDtStart]
data$clean_DT_End <- data[,colDtEnd]
# clean dates up first!
if (boolShiftHalf) {
  data$clean_DT_Start <- data$clean_DT_Start + (minSeconds / 2)
  data$clean_DT_End <- data$clean_DT_End + (minSeconds / 2)
}
data$clean_DT_Stamp <- data$clean_DT_Start - as.numeric(data$clean_DT_Start) %% minSeconds
data$clean_IntervalsPerEntry <- as.numeric(data$clean_DT_End - data$clean_DT_Start, unit="secs") / minSeconds

output <- NULL
# the recursive functions
funcBindTable <- function (rowItem) {
  addStamp <- rowItem$clean_DT_Stamp + minSeconds
  if (addStamp < rowItem$clean_DT_End) {
    newRowItem <- rowItem
    newRowItem$clean_DT_Stamp <- addStamp
    return(rbind(rowItem, funcBindTable(newRowItem)))
  } else {
    return(rowItem)
  }
}

initMax <- nrow(data)
for (eachRow in 1:initMax) {
  output <- rbind(output,funcBindTable(data[eachRow,]))
}

# calculate busy index
output$clean_BusyDensity <- pmin(1, as.numeric(output$clean_DT_End - output$clean_DT_Stamp, unit = "secs") / minSeconds) - pmax(0, as.numeric(output$clean_DT_Start - output$clean_DT_Stamp, unit = "secs") / minSeconds)
output$clean_BusyIndex <- output$clean_BusyDensity / output$clean_IntervalsPerEntry

## --- DATA TESTING ---
write.csv(output,"output.csv")
