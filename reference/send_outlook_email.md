# Send email through Outlook

Function to send an email through Outlook from R.

## Usage

``` r
send_outlook_email(title, body, recipient, attachment = NULL)
```

## Arguments

- title:

  `str` Subject of message to be sent.

- body:

  `str` Long string of body of message to be sent.

- recipient:

  `str` A semicolon separated list of recipients.

- attachment:

  `str` Path to local document to be attached to email. Defaults to
  `NULL`.

## Value

Status message whether the operation was a success or an error message.

## Examples

``` r
if (FALSE) { # \dontrun{
title_message <- "Test"
body_message <- "this is a test"
recipient_list <- c("ab123@email.com")
send_outlook_email(title_message, body_message, recipient_list)
} # }
```
