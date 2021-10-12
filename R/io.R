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
#' @param deploy POSIXt or NA, if not NA, clip data before this time
#' @param recover POSIXt or NA, if not NA, clip data before this time
#' @return tibble
clip_hobotemp <- function(x,
                          deploy = NA,
                          recover = NA) {

  if (!is.na(deploy)) {
    x <- x %>%
      dplyr::filter(DateTime >= deploy[1])
  }

  if (!is.na(recover)) {
    x <- x %>%
      dplyr::filter(DateTime <= recover[1])
  }

  x
}

#' read hobotemp data file
#'
#' @export
#' @param filename character, the name of the file
#' @param deploy POSIXt or NA, if not NA, clip data before this time
#' @param recover POSIXt or NA, if not NA, clip data before this time
#' @return tibble
read_hobotemp <- function(filename = example_filename(),
                          deploy = NA,
                          recover = NA){
  stopifnot(inherits(filename, "character"))
  stopifnot(file.exists(filename[1]))
  x <- suppressMessages(readr::read_csv(filename[1],
                                        skip = 1,
                                        col_types = "dcddccccc"))

  colnames(x)[1] <- "Reading"
  colnames(x)[2] <- "DateTime" #EST
  colnames(x)[3] <- "Temp"
  colnames(x)[4] <- "Intensity"
  colnames(x)[5] <- "Coupler.detached"
  colnames(x)[6] <- "Coupler.attached"
  colnames(x)[7] <- "Host.connected"
  colnames(x)[8] <- "Stopped"
  colnames(x)[9] <- "End.file"


  #convert date/time to POSIXct format
  x$DateTime = as.POSIXct(x$DateTime, format = "%m/%d/%y %H:%M")

  x <- clip_hobotemp(x,
                    deploy = deploy,
                    recover = recover)

  return(x)

}


