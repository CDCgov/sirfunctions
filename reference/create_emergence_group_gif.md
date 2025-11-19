# Generate Emergence Group Movement Gifs

Generate the figures and stitch together a GIF to evaluate emergence
group movement over time, generally aggregated as cumulative per month

## Usage

``` r
create_emergence_group_gif(
  emergence_group,
  pos,
  dist,
  ctry,
  output_dir,
  include_env = TRUE,
  cumulative = TRUE,
  fps = 2
)
```

## Arguments

- emergence_group:

  `str` Designation of the emergence group to review.

- pos:

  `tibble` Positives data set. This is `raw.data$pos`, which is part of
  the output of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md).

- dist:

  `sf` Shapefile of all districts.

- ctry:

  `sf` Shapefile of all countries.

- output_dir:

  `str` Directory where gif should be saved.

- include_env:

  `bool` To include environmental detections in analysis. Defaults to
  `TRUE`.

- cumulative:

  `bool` To display cases as cumulative. Defaults to `TRUE`.

- fps:

  `int` Frames per second. Defaults to 2.

## Value

GIF written out to location of `output_dir`.

## Examples

``` r
if (FALSE) { # \dontrun{

data <- get_all_polio_data(size = "medium")
pos <- data$pos
emergence_group <- "NIE-JIS-1"
dist <- data$global.dist
ctry <- data$global.ctry
include_env <- T
cumulative <- F
output_dir <- getwd()

create_emergence_group_gif(
  emergence_group, pos, dist, ctry, include_env,
  cumulative, output_dir
)
} # }
```
