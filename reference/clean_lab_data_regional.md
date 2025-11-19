# Clean lab data from the regional offices.

Regional data have different columns compared to the WHO lab data. The
cleaning of the regional data is adapted from the lab data cleaning code
from the GPSAP indicator script.

## Usage

``` r
clean_lab_data_regional(
  lab_data,
  start_date,
  end_date,
  afp_data = NULL,
  ctry_name = NULL,
  lab_locs_path = NULL,
  use_edav = TRUE
)
```

## Arguments

- lab_data:

  `tibble` Lab dataset.

- start_date:

  `str` Start date of analysis.

- end_date:

  `str` End date of analysis.

- afp_data:

  `tibble` AFP linelist. Either `ctry.data$afp.all.2` or `raw.data$afp`.

- ctry_name:

  `str` or `list` Name or a list of countries. Defaults to `NULL`.

- lab_locs_path:

  `str` Location of testing lab locations. Default is `NULL`. Will
  download from EDAV, if necessary.

- use_edav:

  `logical` Whether to obtain data from EDAV. Defaults to `TRUE`.

## Value

`tibble` Cleaned lab data.

## Examples

``` r
if (FALSE) { # \dontrun{
lab_path <- "C:/Users/XRG9/lab_data_region.csv"
ctry.data <- init_dr("algeria", lab_data_path = lab_path)
ctry.data$lab_data <- clean_lab_data_regional(
  lab.data, "2021-01-01", "2023-12-31",
  ctry.data$afp.all.2, "algeria"
)

# Not using the desk review pipeline
raw.data <- get_all_polio_data()
ctry.data <- extract_country_data("algeria", raw.data)
ctry.data$lab_data <- read_csv(lab_path)
ctry.data$lab_data <- clean_lab_data_regional(ctry.data, "2021-01-01", "2023-12-31")
} # }
```
