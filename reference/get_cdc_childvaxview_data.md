# Pull CDC NCIRD childvaxview immunization coverage data

Pull coverage data from API and filter by desired geographic level and
vaccines.

## Usage

``` r
get_cdc_childvaxview_data(
  geo_level = NULL,
  vaccines = NULL,
  limit = 1000,
  base_url = "https://data.cdc.gov/resource/fhky-rtsk.json"
)
```

## Arguments

- geo_level:

  `str` Geographic categories of coverage data. Choose from: 'national',
  'regional', 'state', or 'substate'.

- vaccines:

  `str` A string or vector of strings of vaccines for which to provide
  coverage data. Choose from: 'DTaP', 'Polio', 'Hep B', 'PCV',
  'Varicella', 'MMR', 'Hib', 'Hep A', 'Influenza', 'Rotavirus',
  'Combined 7 series'.

- limit:

  `int` Number of rows to download, defaults to max allowed (1000).

- base_url:

  `str` URL to US CDC NCIRD API endpoint. Defaults to
  "https://data.cdc.gov/resource/fhky-rtsk.json".

## Value

`tibble` Dataframe of vaccine coverage estimates for all VPDs.

## Examples

``` r
if (FALSE) { # \dontrun{
cdc_data <- get_cdc_childvaxview_data(geo_level="substate")
cdc_data <- get_cdc_childvaxview_data(geo_level="national", vaccines=c("Polio","MMR"))
} # }
```
