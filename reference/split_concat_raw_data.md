# Split or concatenate raw.data by year

Split or concatenate raw.data by year

## Usage

``` r
split_concat_raw_data(
  action,
  split.years = NULL,
  raw.data.all = NULL,
  raw.data.post.2019 = NULL,
  raw.data.2016.2019 = NULL,
  raw.data.2001.2016 = NULL
)
```

## Arguments

- action:

  `str` Can either be to `"concat"` or `"split"`.

- split.years:

  `array` A numeric array of years by which data should be split.

- raw.data.all:

  `list` A list of data objects to be split.

- raw.data.post.2019:

  `list` A list of data objects to be concatenated.

- raw.data.2016.2019:

  `list` A list of data objects to be concatenated.

- raw.data.2001.2016:

  `list` A list of data objects to be concatenated.

## Value

`list` A list of lists or a single concatenated list.
