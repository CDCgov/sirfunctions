# Send a message on Microsoft Teams

Helper function to send message to validated MS Teams interface.

## Usage

``` r
send_teams_message(
  msg,
  team_id = "CGH-GID-PEB-SIR",
  channel = "CORE 2.0",
  attach = NULL,
  type = "text"
)
```

## Arguments

- msg:

  `str` Message to be sent.

- team_id:

  `str` Teams ID. Defaults to `"CGH-GID-PEB-SIR"`.

- channel:

  `str` Channel where message should be sent.

- attach:

  `str` Local path of files to be attached in message.

- type:

  `str` Type of message to be sent. Either `"text"` or `"html"`.

## Value

Status message whether the operation was a success or an error message.

## Examples

``` r
if (FALSE) { # \dontrun{
message <- "this is a test"
send_teams_message(message)
} # }
```
