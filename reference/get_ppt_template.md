# Get path of the PowerPoint template

The desk review PowerPoint template is used to build the desk review
slide deck. The function will either download the template from the
sg-desk-reviews GitHub page or get it locally.

## Usage

``` r
get_ppt_template(path = NULL)
```

## Arguments

- path:

  `str` Path to the PowerPoint template. If `NULL`, uses the default
  template inside sirfunctions.

## Value

`str` Local path of the PowerPoint template.

## Examples

``` r
if (FALSE) { # \dontrun{
get_ppt_template()

# If present locally
template_path <- "C:/Users/ABC1/Desktop/deskreview_template.pptx"
ppt_template <- get_ppt_template(template_path)
} # }
```
