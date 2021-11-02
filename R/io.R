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

#' read hobotemp data file header
#'
#' @export
#' @param filename character, the name of the file
#' @param skip numeric, number of lines to skip - default 1
#' @return named list
read_hobo_cols <- function(filename = example_filename(),
                                 skip = 1){

  x <- readLines(filename)[skip+2] %>%
   # stringr::str_split('("[^"]*),') %>%
    stringr::str_split(stringr::fixed(","), n = Inf) %>%
    `[[`(1)

  N <- length(x)
  #x <- x[length(x) >0]

  r = c("icnn", rep("-",N-4)) %>% paste(collapse = "")

  n = c("Reading", "DateTime", "Temp", "Intensity", LETTERS[seq_len(N-4)])

  r <- list(col_names = n, col_types = r)

  return(r)
}



#' read hobotemp data file
#'
#' @export
#' @param filename character, the name of the file
#' @param clipped character, if auto, removed partial start/end days. if user, uses supplied startstop days. if none, does no date trimming
#' @param startstop POSIXt vector of two values or NA, only used if clip = "user"
#' @param skip numeric, number of rows to skip when reading, default 1
#' @return tibble
read_hobotemp <- function(filename = example_filename(),
                          clipped = c("auto", "user", "none")[1],
                          startstop = NA,
                          skip = 1){
  stopifnot(inherits(filename, "character"))
  stopifnot(file.exists(filename[1]))

  columns <- read_hobo_cols(filename[1])

  x <- readr::read_csv(filename,
                       #col_names = columns[['col_names']],
                       col_types = columns[["col_types"]],
                       skip = skip,
                       quote = '"')

  colnames(x) <- columns[["col_names"]][1:4]

  #extract site name from first line of file
  site <- readLines(filename, 1) %>%
    stringr::str_extract_all("(?<=: ).+(?=\")") %>%
    `[[`(1)  %>%
    stringr::str_replace_all("[^[:alnum:]]", "")

  #x <- tibble::as_tibble(data.table::fread(filename[1], select = c(1:4)))

 # colnames(x) <- columns[["col_names"]][1:4]
 #colnames(x)[1] <- "Reading"
 #colnames(x)[2] <- "DateTime" #GMT-04
 #colnames(x)[3] <- "Temp"
 #colnames(x)[4] <- "Intensity"

  x <- x %>% dplyr::mutate(Site = site)

  #convert date/time to POSIXct format
  x$DateTime = as.POSIXct(x$DateTime, format = "%m/%d/%y %I:%M:%S %p", tz = "US/Eastern")

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


