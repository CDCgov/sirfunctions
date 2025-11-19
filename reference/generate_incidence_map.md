# Generate incidence map timeline

Generates an incidence map and an epicurve showing positive detections
for emergence groups.

## Usage

``` r
generate_incidence_map(
  pos_data,
  ctry_sf,
  emergence_group = NULL,
  emergence_colors = NULL,
  sources = c("AFP", "ENV"),
  start_date = NULL,
  end_date = NULL,
  monthly_rolling_window = 12,
  output_dir = NULL,
  fps = 2,
  drop_legend = FALSE,
  drop_ctry_labels = FALSE,
  drop_description = FALSE,
  pt_size = 0.7
)
```

## Arguments

- pos_data:

  `tibble` Positives dataset.

- ctry_sf:

  `ctry_sf` Global country shapefile.

- emergence_group:

  `str` An emergence group or a vector of emergence group names.

- emergence_colors:

  `list` A named list where each emergence group is mapped its own
  color. Names correspond to the emergence group, while values are the
  colors. If no colors are passed, then colors are randomly selected for
  each emergence group.

- sources:

  `str` Source of detection or a vector of source names. Valid values
  are: "AFP", "Community", "Contact", "ENV", "Healthy", "iVDPV".

- start_date:

  `str` Start date of the map. By default, it will be the earliest date
  of detection.

- end_date:

  `str` End date of the map. By default, it will be the latest
  detection.

- monthly_rolling_window:

  `int` Monthly rolling window to show. Defaults to 12.

- output_dir:

  `str` Local path to the directory to output the figure. Defaults to
  NULL, which does not export the figure.

- fps:

  `int` Frames per second. To increase the speed of the GIF, increase
  the fps. By default, it is set to 2.

- drop_legend:

  `logical` Drop legends of the figure or not.

- drop_ctry_labels:

  `logical` Drop country labels for the map.

- drop_description:

  `logical` Drop the case counts of the map caption.

- pt_size:

  `int` Size of the points in the map. Defaults to 5.

## Value

`gif` A GIF showing the emergence over time.

## Examples

``` r
if (FALSE) { # \dontrun{
raw_data <- get_all_polio_data
generate_incidence_map(raw_data$pos,
raw_data$global.ctry,
emergence_group = c("YEM-TAI-1", "SOM-BAN-1", "ETH-TIG-1"))
} # }
```
