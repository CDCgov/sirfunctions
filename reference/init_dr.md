# Set up the folders and load polio data for the desk review

Prepares the folders and files required for the desk review. The
function primarily serves to organize the files used for the desk review
and set standardized environmental variables (i.e.,
[`Sys.getenv()`](https://rdrr.io/r/base/Sys.getenv.html), where values
for `x` related to the desk review is prefixed with `"DR"`) . The
function only supports running one country at a time.

## Usage

``` r
init_dr(
  country_name,
  start_date = NULL,
  end_date = NULL,
  local_dr_folder = getwd(),
  lab_data_path = NULL,
  iss_data_path = NULL,
  attach_spatial_data = T,
  branch = "main",
  source = F,
  data_folder = "GID/PEB/SIR/Data",
  polis_folder = "GID/PEB/SIR/POLIS",
  use_edav = TRUE
)
```

## Arguments

- country_name:

  `str` Name of the country.

- start_date:

  `str` Start date of the desk review. If `NULL`, defaults to four years
  from when the function was ran on January 1st.

- end_date:

  `str` End date of the desk review. If `NULL`, defaults to six weeks
  from when the function is ran.

- local_dr_folder:

  `str` Folder where the desk review code is located. Defaults to the
  current working directory.

- lab_data_path:

  `str` Location of the lab data. Defaults to `NULL`.

- iss_data_path:

  `str` Location of the ISS data. Defaults to `NULL`.

- attach_spatial_data:

  `logical` Whether to include spatial data. Defaults to `TRUE`.

- branch:

  `str` What branch to download the DR functions from GitHub. `"main"`
  is the default, which contains the official version of the package.
  Other branches, like `"dev"` may contain experimental features not yet
  available in the `"main"` branch.

- source:

  `logical` Whether to source local functions or use sirfunctions.
  Defaults to `FALSE`.

- data_folder:

  `str` Location of the data folder containing pre-processed POLIS data,
  spatial files, coverage data, and population data. Defaults to
  `"GID/PEB/SIR/Data"`.

- polis_folder:

  `str` Location of the POLIS folder. Defaults to `"GID/PEB/SIR/POLIS"`.

- use_edav:

  `logical` Build raw data list using EDAV files. Defaults to `TRUE`.

## Value

`list` A list containing all dataframe for all polio data.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria", source = F) # Sets up folder in the current working directory
ctry.data <- init_dr("algeria", branch = "dev") # Use functions from the dev branch
} # }
```
