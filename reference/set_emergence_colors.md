# Set the emergence colors

Used in conjunction to
[`generate_adhoc_map()`](https://cdcgov.github.io/sirfunctions/reference/generate_adhoc_map.md).
The function returns a named list with emergence names mapped to a
color.

## Usage

``` r
set_emergence_colors(
  raw.data,
  country,
  start_date = NULL,
  end_date = NULL,
  get_unassigned = FALSE
)
```

## Arguments

- raw.data:

  `list` Global polio data output of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md).

- country:

  `str` or `list` Countries of interest.

- start_date:

  `str` Start date of the time span to look for emergences. Defaults to
  13 months from the end date.

- end_date:

  `str` End date of the time span to look for emergences Defaults to
  download date of `raw.data`.

- get_unassigned:

  `logical` Get a list of emergence without a color mapped. This
  parameter is useful for ensuring that emergences are all accounted for
  when making a map.

## Value

`list` A named list containing the mapping of emergence and
corresponding colors.

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data(attach.spatial.data = FALSE)
emg.cols <- set_emergence_colors(raw.data, "algeria")
} # }
```
