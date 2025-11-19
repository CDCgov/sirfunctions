# Validate connection to EDAV

Generate token which connects to CDC EDAV resources and validates that
the individual still has access. The current tenant ID is hard coded for
CDC resources.

## Usage

``` r
get_azure_storage_connection(
  app_id = "04b07795-8ddb-461a-bbee-02f9e1bf7b46",
  auth = "authorization_code",
  posit_yaml_path = NULL,
  ...
)
```

## Arguments

- app_id:

  `str` Application ID defaults to
  `"04b07795-8ddb-461a-bbee-02f9e1bf7b46"`, this can be changed if you
  have a service principal.

- auth:

  `str` Authorization type defaults to `"authorization_code"`, this can
  be changed if you have a service principal.

  Valid values are:`"authorization_code"`, `"device_code"`,
  `"client_credentials"`, `"resource_owner"`, `"on_behalf_of"`.

  See **Details** of
  [`AzureAuth::get_azure_token()`](https://rdrr.io/pkg/AzureAuth/man/get_azure_token.html)
  for further details.

- posit_yaml_path:

  `str` Path to the YAML file in Posit workbench. If `NULL`, the path
  will be in `"~/credentials/posit_workbench_creds.yaml"`.

- ...:

  additional parameters passed to
  [`AzureAuth::get_azure_token()`](https://rdrr.io/pkg/AzureAuth/man/get_azure_token.html).

## Value

Azure container verification

## Examples

``` r
if (FALSE) { # \dontrun{
azcontainer <- get_azure_storage_connection()
} # }
```
