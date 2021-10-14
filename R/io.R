#' retrieve example type hobotemp file name
#'
#' @export
#' @return filename
example_filename <- function(){
  system.file("exampledata/little_drisko_hobo.csv",
              package="hobotemp")
}

#' clip hobotemp table by date
#'
#' @export
#' @param x tibble, hobotemp
#' @param startstop POSIXt vector of two values or NA, only used if clip = "user"
#' @return tibble
clip_hobotemp <- function(x,
                          startstop = NA) {

  if (is.na(startstop)) {
     x <- x %>% dplyr::mutate (Date = as.Date(DateTime, tz = "EST"),
                              DateNum = as.numeric(DateTime))

     ix <- which(diff(x$Date) != 0)[1]  + 1
     firstday <- as.numeric(difftime(x$DateTime[ix], x$DateTime[1]))

        if (firstday < 23) {
          x <- x[-(1:(ix-1)),]
        }

     iix <- dplyr::last(which(diff(x$Date) != 0))  + 1
     lastday <- as.numeric(difftime(dplyr::last(x$DateTime),x$DateTime[iix]))

        if (lastday < 23) {
          x <- x[-((iix+1):nrow(x)),]
        }

     x <- x %>% dplyr::select(-Date, -DateNum)
  }


  if (!is.na(startstop)) {
    x <- x %>%
      dplyr::filter(DateTime >= startstop[1]) %>%
      dplyr::filter(DateTime <= startstop[2])
  }

  x
}

#' read hobotemp data file
#'
#' @export
#' @param filename character, the name of the file
#' @param clipped "auto", "user", or NA, if auto, removed partial start/end days. if user, uses supplied startstop days. if NA, does no date trimming
#' @param startstop POSIXt vector of two values or NA, only used if clip = "user"
#' @return tibble
read_hobotemp <- function(filename = example_filename(),
                          clipped = "auto",
                          startstop = NA){
  stopifnot(inherits(filename, "character"))
  stopifnot(file.exists(filename[1]))
  x <- suppressMessages(readr::read_csv(filename[1],
                                        skip = 1,
                                        col_types = "dcddccccc"))

  colnames(x)[1] <- "Reading"
  colnames(x)[2] <- "DateTime" #EST
  colnames(x)[3] <- "Temp"
  colnames(x)[4] <- "Intensity"
  x <- x[-(5:9)]

  #convert date/time to POSIXct format
  x$DateTime = as.POSIXct(x$DateTime, format = "%m/%d/%y %I:%M:%S %p", tz = "EST")


  if (!is.na(clipped) && clipped == "auto") {
    x <- clip_hobotemp(x,
                       startstop = NA)
  } else if (!is.na(clipped) && clipped == "user") {
    x <- clip_hobotemp(x,
                       startstop = startstop)
  }


  return(x)

}


