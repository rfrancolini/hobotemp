
#' Plot temperature data as scatter plot with trendline
#'
#' @export
#' @param x tibble of hobotemp data
#' @param main character, title
#' @param alpha numeric, 0.1 default
#' @param xlabel character, title of xaxis
#' @param ylabel character, title of yaxis
#' @return ggplot2 object
draw_plot <- function(x = read_hobotemp(),
                      main = "Temperature at Depth",
                      xlabel = "Date",
                      ylabel = "Temperature (degrees C)",
                      alpha = 0.2){

  ggplot2::ggplot(data = x, ggplot2::aes(x = .data$DateTime, y = .data$Temp)) +
  ggplot2::geom_point(na.rm = TRUE, alpha = alpha, shape = 4) +
  ggplot2::labs(title = main, x = xlabel, y = ylabel) +
  suppressMessages(ggplot2::geom_smooth(na.rm = TRUE, se = FALSE))

}


