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

  if (is.na(startstop)[1]) {
     x <- x %>% dplyr::mutate (Date = as.Date(.data$DateTime, tz = "UTC"),
                              DateNum = as.numeric(.data$DateTime))

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

     x <- x %>% dplyr::select(-.data$Date, -.data$DateNum)
  }


  if (!is.na(startstop)[1]) {
    x <- x %>%
      dplyr::filter(.data$DateTime >= startstop[1]) %>%
      dplyr::filter(.data$DateTime <= startstop[2])
  }

  x
}

#' read hobotemp data file
#'
#' @export
#' @param filename character, the name of the file
#' @param clipped character, if auto, removed partial start/end days. if user, uses supplied startstop days. if none, does no date trimming
#' @param startstop POSIXt vector of two values or NA, only used if clip = "user"
#' @return tibble
read_hobotemp <- function(filename = example_filename(),
                          clipped = c("auto", "user", "none")[1],
                          startstop = NA){
  stopifnot(inherits(filename, "character"))
  stopifnot(file.exists(filename[1]))
  x <- suppressMessages(readr::read_csv(filename[1],
                                        skip = 1,
                                        col_types = "dcddccccc"))

  colnames(x)[1] <- "Reading"
  colnames(x)[2] <- "DateTime" #EDT
  colnames(x)[3] <- "Temp"
  colnames(x)[4] <- "Intensity"
  x <- x[-(5:9)]

  #convert date/time to POSIXct format
  x$DateTime = as.POSIXct(x$DateTime, format = "%m/%d/%y %I:%M:%S %p", tz = "Etc/GMT-4")

  #convert date/time to UTC
  x <- x %>% dplyr::mutate(DateTime = lubridate::with_tz(x$DateTime, tzone = "UTC"))

  x <- switch(tolower(clipped[1]),
              "auto" = clip_hobotemp(x, startstop = NA),
              "user" = clip_hobotemp(x, startstop = startstop),
              "none" = x,
              stop("options for clipped are auto, user, or none. what is ", clipped, "?")
              )

  return(x)

}


