# Upload file to Sharepoint

Helper function to upload file to MS SharePoint

## Usage

``` r
upload_to_sharepoint(
  file_to_upload,
  sharepoint_file_loc,
  site = "https://cdc.sharepoint.com/teams/CGH-GID-PEB-SIR283",
  drive = "Documents"
)
```

## Arguments

- file_to_upload:

  `str` Local path of files to be uploaded.

- sharepoint_file_loc:

  `str` Location in SharePoint to upload file. Must include the file
  name and extension (i.e., folder/file_name.csv).

- site:

  `str` SharePoint site location. Defaults to `"CGH-GID-PEB"` or the
  site URL: `"https://cdc.sharepoint.com/teams/CGH-GID-PEB-SIR283"`.

- drive:

  `str` SharePoint drive to upload data to.

## Value

Status message whether the operation was a success or an error message.

## Examples

``` r
if (FALSE) { # \dontrun{
file_path <- "C:/Users/ABC1/df1.csv"
sp_path <- "test_folder/df1.csv"
upload_to_sharepoint(file_path, sp_path)
} # }
```
