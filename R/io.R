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



#' read raw hobotemp data file, QA/QC it, write as a new file
#'
#' @export
#' @param filename character, the name of the file
#' @param output character, the name for the outputted QAQC file
#' @param site character, the name of the site, if NA the code will use filename without special character
#' @param clipped character, if auto, removed partial start/end days. if user, uses supplied startstop days. if none, does no date trimming
#' @param startstop POSIXt vector of two values or NA, only used if clip = "user"
#' @param skip numeric, number of rows to skip when reading, default 1
#' @return tibble
read_hobotemp <- function(filename = example_filename(),
                          output = NA,
                          site = NA,
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

  #define site name to be filled in column
  if (!is.na(site)) {
    siteName <- site
  } else {
  #extract site name from first line of file
    siteName <- readLines(filename, 1) %>%
      stringr::str_extract_all("(?<=: ).+(?=\")") %>%
      `[[`(1)  %>%
      stringr::str_replace_all("[^[:alnum:]]", "")
  }

  #assign sitename to the column
  x <- x %>% dplyr::mutate(Site = siteName)

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

  #Remove na's
  x <- na.omit(x)

  if (!is.na(output)) {
  readr::write_csv(x, file = output) }

  return(x)

}


#' print out summary of hobotemp data
#'
#' @export
#' @param x tibble, tibble of hobotemp data
#' @return tibble
summarize_hobotemp <- function(x = read_hobotemp()){

  #remove any NA's before summarizing

  x <- na.omit(x)

  s <- x %>% dplyr::group_by(.data$Site) %>%
             dplyr::summarise(mean.temp = mean(.data$Temp),
                              first.day = dplyr::first(.data$DateTime),
                              last.day = dplyr::last(.data$DateTime),
                              max.temp = max(.data$Temp),
                              max.temp.date = .data$DateTime[which.max(.data$Temp)],
                              min.temp = min(.data$Temp),
                              min.temp.date = .data$DateTime[which.min(.data$Temp)])

  return(s)
}

