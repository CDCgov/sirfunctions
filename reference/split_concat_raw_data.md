# Split or concatenate raw.data by year

Split or concatenate raw.data by year

## Usage

``` r
split_concat_raw_data(
  action,
  split.years = NULL,
  raw.data.all = NULL,
  raw.data.small.pull = NULL,
  raw.data.medium.pull = NULL,
  raw.data.large.pull = NULL
)
```

## Arguments

- action:

  `str` Can either be to `"concat"` or `"split"`.

- split.years:

  `array` A numeric array of years by which data should be split.

- raw.data.all:

  `list` A list of data objects to be split.

- raw.data.small.pull:

  `list` A list of data objects to be concatenated. This is the 'small'
  dataset, which consists of data from the past 6 years.

- raw.data.medium.pull:

  `list` A list of data objects to be concatenated. This is the 'small'
  dataset, which consists of data since 2016.

- raw.data.large.pull:

  `list` A list of data objects to be concatenated. This is the 'small'
  dataset, which consists of data since 2000.

## Value

`list` A list of lists or a single concatenated list.
