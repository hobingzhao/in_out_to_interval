# read intervalmaker
source("intervalmaker.R")

## --- DATA SOURCE ---
library(openxlsx)
data <- read.xlsx("data.xlsx")
# convert excel dates to POSIXct
data$DateTime_Start <- convertToDateTime(data$DateTime_Start)
data$DateTime_End <- convertToDateTime(data$DateTime_End)
## --- END DATA SOURCE ---
data$clean_BusyDensity <- "test"
# --- EXECUTE intervalmaker ---
output <- intervalmaker(data, "DateTime_Start", "DateTime_End")

## --- DATA TESTING ---
head(output)
