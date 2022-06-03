Hobotemp
================

## Hobotemp

This is for managing and understanding your HOBO temperature data

## Requirements

-   [R v4+](https://www.r-project.org/)
-   [dplyr](https://CRAN.R-project.org/package=dplyr)
-   [readr](https://CRAN.R-project.org/package=readr)
-   [stringr](https://CRAN.R-project.org/package=stringr)
-   [ggplot2](https://CRAN.R-project.org/package=ggplot2)
-   [lubridate](https://CRAN.R-project.org/package=lubridate)

## Installation

    remotes::install_github("rfrancolini/hobotemp")

## Read Example Data

``` r
library(hobotemp)
x <- read_hobotemp()
x
```

    ## # A tibble: 9,025 x 5
    ##    Reading DateTime             Temp Intensity Site        
    ##      <int> <dttm>              <dbl>     <dbl> <chr>       
    ##  1      53 2021-05-15 00:04:32  8.18         0 LittleDrisko
    ##  2      54 2021-05-15 00:19:32  8.18         0 LittleDrisko
    ##  3      55 2021-05-15 00:34:32  8.08         0 LittleDrisko
    ##  4      56 2021-05-15 00:49:32  8.18         0 LittleDrisko
    ##  5      57 2021-05-15 01:04:32  8.08         0 LittleDrisko
    ##  6      58 2021-05-15 01:19:32  8.08         0 LittleDrisko
    ##  7      59 2021-05-15 01:34:32  7.98         0 LittleDrisko
    ##  8      60 2021-05-15 01:49:32  7.88         0 LittleDrisko
    ##  9      61 2021-05-15 02:04:32  7.88         0 LittleDrisko
    ## 10      62 2021-05-15 02:19:32  7.88         0 LittleDrisko
    ## # ... with 9,015 more rows

## Read Example Data with User Defined Site

``` r
library(hobotemp)
x <- read_hobotemp(site = "Little Drisko Island")
x
```

    ## # A tibble: 9,025 x 5
    ##    Reading DateTime             Temp Intensity Site                
    ##      <int> <dttm>              <dbl>     <dbl> <chr>               
    ##  1      53 2021-05-15 00:04:32  8.18         0 Little Drisko Island
    ##  2      54 2021-05-15 00:19:32  8.18         0 Little Drisko Island
    ##  3      55 2021-05-15 00:34:32  8.08         0 Little Drisko Island
    ##  4      56 2021-05-15 00:49:32  8.18         0 Little Drisko Island
    ##  5      57 2021-05-15 01:04:32  8.08         0 Little Drisko Island
    ##  6      58 2021-05-15 01:19:32  8.08         0 Little Drisko Island
    ##  7      59 2021-05-15 01:34:32  7.98         0 Little Drisko Island
    ##  8      60 2021-05-15 01:49:32  7.88         0 Little Drisko Island
    ##  9      61 2021-05-15 02:04:32  7.88         0 Little Drisko Island
    ## 10      62 2021-05-15 02:19:32  7.88         0 Little Drisko Island
    ## # ... with 9,015 more rows

## Draw Example Plot

``` r
tempplot_x <- draw_scatter_plot(x)
tempplot_x
```

![](README_files/figure-gfm/tempplot-1.png)<!-- -->

## Draw example ridgeline plot

``` r
ridgelineplot <- draw_ridgeline_plot()
ridgelineplot
```

![](README_files/figure-gfm/ridgeline-1.png)<!-- -->

## Read Example Data With User Defined Start/Stop Dates

``` r
ss <- as.POSIXct(c("2021-05-20", "2021-06-01"), tz = "UTC")
xud <- read_hobotemp(clipped = "user", startstop = ss)
xud
```

    ## # A tibble: 1,152 x 5
    ##    Reading DateTime             Temp Intensity Site        
    ##      <int> <dttm>              <dbl>     <dbl> <chr>       
    ##  1     533 2021-05-20 00:04:32  8.38         0 LittleDrisko
    ##  2     534 2021-05-20 00:19:32  8.48         0 LittleDrisko
    ##  3     535 2021-05-20 00:34:32  8.48         0 LittleDrisko
    ##  4     536 2021-05-20 00:49:32  8.48         0 LittleDrisko
    ##  5     537 2021-05-20 01:04:32  8.58         0 LittleDrisko
    ##  6     538 2021-05-20 01:19:32  8.58         0 LittleDrisko
    ##  7     539 2021-05-20 01:34:32  8.68         0 LittleDrisko
    ##  8     540 2021-05-20 01:49:32  8.68         0 LittleDrisko
    ##  9     541 2021-05-20 02:04:32  8.78         0 LittleDrisko
    ## 10     542 2021-05-20 02:19:32  8.78         0 LittleDrisko
    ## # ... with 1,142 more rows

## Draw Example Plot User Defined Start/Stop Dates

``` r
tempplot_xud <- draw_scatter_plot(xud)
tempplot_xud
```

![](README_files/figure-gfm/tempplot_ud-1.png)<!-- -->

## Read Example Data Without Clipping Data

``` r
xna <- read_hobotemp(clipped = "none")
xna
```

    ## # A tibble: 9,165 x 5
    ##    Reading DateTime             Temp Intensity Site        
    ##      <int> <dttm>              <dbl>     <dbl> <chr>       
    ##  1       1 2021-05-14 11:19:32  20.1         1 LittleDrisko
    ##  2       3 2021-05-14 11:34:32  20.5        36 LittleDrisko
    ##  3       4 2021-05-14 11:49:32  20.5        37 LittleDrisko
    ##  4       5 2021-05-14 12:04:32  15.5        26 LittleDrisko
    ##  5       6 2021-05-14 12:19:32  14.0        25 LittleDrisko
    ##  6       7 2021-05-14 12:34:32  14.7        38 LittleDrisko
    ##  7       8 2021-05-14 12:49:32  14.7       123 LittleDrisko
    ##  8       9 2021-05-14 13:04:32  13.9        60 LittleDrisko
    ##  9      10 2021-05-14 13:19:32  15.3        35 LittleDrisko
    ## 10      11 2021-05-14 13:34:32  14.6        38 LittleDrisko
    ## # ... with 9,155 more rows

## Draw Example Plot Without Clipping Data

``` r
tempplot_na <- draw_scatter_plot(xna)
tempplot_na
```

![](README_files/figure-gfm/tempplot_na-1.png)<!-- -->
