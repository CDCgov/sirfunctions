# Create adhoc maps for emergences

Creates a map of recent emergences. The default will display outbreaks
from the past 13 months.

## Usage

``` r
generate_adhoc_map(
  raw.data,
  country,
  virus_type = "cVDPV 2",
  vdpv = T,
  new_detect = T,
  surv = c("AFP", "ES", "OTHER"),
  labels = "YES",
  owner = "CDC-GID-PEB",
  new_detect_expand = F,
  start_date = NULL,
  end_date = NULL,
  emg_cols = NULL,
  output = NULL,
  image_size = NULL,
  height = 6.2,
  width = 4.5,
  scale = 1.25,
  dpi = 300
)
```

## Arguments

- raw.data:

  `list` Global polio data. The output of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md).
  Make sure the spatial data is attached, otherwise, it will not work.

- country:

  `str` or `list` Country name or a list of country names.

- virus_type:

  `str` or `list`. Virus type to include. Valid values are:

  `"cVDPV 1", "cVDPV 2", "cVDPV 3", "WILD 1".`

  Can pass as a list.

- vdpv:

  `logical` Whether to include VPDV in maps. Default `TRUE`.

- new_detect:

  `logical` Whether to highlight new detections based on WHO HQ report
  date. Default `TRUE`.

- surv:

  `str` or `list` Surveillance options. Valid values are:

  `"AFP", "ES", "OTHER"`

  `"OTHER"` includes Case Contact, Community, Healthy Children Sampling.
  Can pass as a list.

- labels:

  `str` Include labels for regions with virus detections. Options:

  - `"ALL"`: All regions

  - `"YES"`: Recent Detections - \<13 months

- owner:

  `str` Who produced the map. Defaults to `"CDC-GID-PEB"`.

- new_detect_expand:

  `logical` Whether to expand the reporting window. Defaults to `FALSE`.

- start_date:

  `str` Start date. If not specified, defaults to 13 months prior to the
  download date of raw.data.

- end_date:

  `str` End date. If not specified, defaults to the download date of
  raw.data.

- emg_cols:

  `list` A named list with all of the emergence colors. Defaults to
  `NULL`, which will download using
  [`set_emergence_colors()`](https://cdcgov.github.io/sirfunctions/reference/set_emergence_colors.md).

- output:

  `str` Either a path to a local folder to save the map to,
  `"sharepoint"`, or `NULL`. Defaults to `NULL`.

- image_size:

  `str` Standard sizes of the map outputs. Options are:

  - `"full_slide"`

  - `"soco_slide"`

  - `"half_slide"`

  Defaults to `NULL`.

- height:

  `numeric` Height of the map. Defaults to `6.2`.

- width:

  `numeric` Width of the map. Defaults to `4.5`.

- scale:

  `numeric` Scale of the map. Defaults to `1.25`.

- dpi:

  `numeric` DPI of the map. Defaults to `300`.

## Value

`ggplot` A map of outbreaks.

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data()
p1 <- generate_adhoc_map(raw.data, "algeria")
# Put colors in emergences that don't have a mapped color
emg_cols <- set_emergence_colors(raw.data, c("nigeria", "chad"))
emg_cols["NIE-BOS-1"] <- "yellow"
emg_cols["NIE-YBS-1"] <- "green"
p2 <- generate_adhoc_map(raw.data, c("nigeria", "chad"), emg_cols = emg_cols)
} # }
```
