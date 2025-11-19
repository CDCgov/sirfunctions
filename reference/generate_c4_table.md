# Laboratory surveillance KPIs

**\[experimental\]**

Summarizes the timeliness of samples as it arrives in the lab and to
sequencing results. Samples may come from both AFP and ES samples.

## Usage

``` r
generate_c4_table(lab_data, afp_data, start_date, end_date)
```

## Arguments

- lab_data:

  `tibble` Lab data containing information of ES or AFP samples.

- afp_data:

  `tibble` AFP surveillance data.

- start_date:

  `str` Start date of the analysis in YYYY-MM-DD format.

- end_date:

  `str` End date of the analysis in YYYY-MM-DD format.

## Value

`list` A summary of timeliness KPIs for lab data.

## Examples

``` r
if (FALSE) { # \dontrun{
raw_data <- get_all_polio_data(attach.spatial.data = FALSE)
lab_data <- readr::read_csv("C:/Users/ABC1/Desktop/lab_data.csv")
c4 <- generate_c4_table(lab_data, raw_data$afp, "2021-01-01", "2024-12-31")
} # }
```
