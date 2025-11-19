# Checks for errors in the ISS data

Currently, the function reports the number of missing priority levels.

## Usage

``` r
iss_data_errors(
  iss_data,
  error_path = Sys.getenv("DR_ERROR_PATH"),
  ctry.data = lifecycle::deprecated()
)
```

## Arguments

- iss_data:

  `tibble` ISS data.

- error_path:

  `str` Path to error folder. The function defaults to a global
  environment variable called `DR_ERROR_PATH`, as it is assumed ISS data
  error checking is done as part of the desk review template. The
  setting of desk review environmental variables is automatically
  handled by
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).
  Otherwise, users should manually specify the error folder.

- ctry.data:

  `list` **\[deprecated\]** Please pass the ISS data directly to the
  iss.data parameter.

## Value

Status messages on the checks completed and results.

## Examples

``` r
if (FALSE) { # \dontrun{
iss_path <- "C:/Users/ABC1/Desktop/iss_data.csv"
ctry.data <- init_dr("somalia", iss_data_path = iss_path)
iss_data_errors(ctry.data$iss.data)
} # }
```
