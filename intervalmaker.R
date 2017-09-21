intervalmaker <- function (data, colDtStart, colDtEnd, minSeconds = 3600, 
                           boolShiftHalf = FALSE, createBusyDensity = TRUE, createBusyIndex = TRUE,
                           maxIntervalLimit = 24) {
  
  ## TO DO
  # create a max interval limit and make it used
  
  ## --- SETUP VARIABLES ---
  # data - data table
  # minSeconds - interval in seconds e.g. 15 min interval is 900. Should be either 900 (15min), 1800 (30min), or 3600 (60min).
  # boolShiftHalf - TRUE means start and end datetimes will be shifted half of the minInterval to reduce shifting of dates to the left
  # colDtStart, colDtEnd = strings of start and end date times
  
  # check for reserved headers
  reservedHeaders <- c("clean_DT_Start", "clean_DT_End", "clean_DT_Stamp", "clean_BusyIndex", "clean_IntervalsPerEntry", "clean_BusyDensity")
  conflictHeaders <- intersect(names(data),reservedHeaders)
  try(if(length(conflictHeaders) > 0) stop(paste("Error: reserved headers are found in the input data.frame:", paste(conflictHeaders,collapse=" "))))
  
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
  # the recursive function
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
  
  return(output)
}
