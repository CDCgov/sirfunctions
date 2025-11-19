# Compress PNG files using pngquant

Compress PNG files. The software pngquant is required to use this
function. It attempts to reduce the file size of images without major
loss in image quality. Files sizes can be reduced from 30-60% using this
function. The compressed file will be outputted to the same folder as
the original image.

## Usage

``` r
compress_png(img, pngquant_path = NULL, suffix = "")
```

## Arguments

- img:

  `str` File path to the png file.

- pngquant_path:

  `str` File path to pngquant executable file (pngquant.exe).

- suffix:

  `str` Optional parameter to add a suffix to the compressed image.

## Value

None. Will output compressed image to the local folder.

## Examples

``` r
if (FALSE) { # \dontrun{
img_path <- "C:/Users/ABC1/Desktop/pic1.png"
pngquant_path <- "C:/Users/ABC1/Downloads/pngquant.exe"
compress_png(img_path, pngquant_path, "_compressed")
} # }
```
