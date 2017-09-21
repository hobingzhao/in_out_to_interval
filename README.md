# R Script for converting in-out data to interval by expanding the number of rows the data has

## How to Use

intervalmaker.R contains the intervalmaker() function that you need.

NOTE: Currently maxIntervalLimit does nothing. Still in alpha. createBusyDensity and createBusyIndex does not work.
??? write about error that happens with conflicting header
- data: data frame to convert
- colDtStart: string that is the header name of the start date/time. Input must be POSIXct
- colDtEnd: string that is the header name of the end date/time. Input must be POSIXct
- minSeconds = 3600: numeric. how long you want to slice the interval in seconds. Recommended: 900 (15mins), 1800 (30mins), 3600 (60mins)
- boolShiftHalf: If TRUE, shifts the start and end date/times to minSeconds/2 to the right. This might help you prevent the data from being skewed to the left when presenting it because the timestamps are created by rounding down to the lowest minSeconds. If FALSE, does not shift the date/times.
- createBusyDensity: creates a column ???
- createBusyIndex: ???
- maxIntervalLimit: Default is 24. ???

