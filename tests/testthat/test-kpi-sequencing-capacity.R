kpi_test_lab_locations <- function() {
  data.frame(
    country = c("NIGERIA", "UGANDA", "ETHIOPIA"),
    who.region = "AFRO",
    culture.itd.lab = c("Nigeria", "Uganda", "Ethiopia"),
    seq.lab = c("Nigeria", "Uganda", "Ethiopia"),
    wgs.lab = c("Nigeria", "Uganda", "Ethiopia"),
    culture.itd.cat = "In-country culture/ITD",
    seq.capacity = "yes", seq.cat = "Not shipped for sequencing",
    num.ship.seq.samples = 1
  )
}

test_that("sequencing capacity uses each caller's date column at the 2025 cutoff", {
  countries <- rep(c("NIGERIA", "UGANDA", "ETHIOPIA"), each = 2)
  dates <- rep(as.Date(c("2025-01-31", "2025-02-01")), 3)
  schemas <- list(
    c(country = "place.admin.0", date = "dateonset"),
    c(country = "ctry", date = "date"),
    c(country = "ADM0_NAME", date = "collect.date")
  )
  for (schema in schemas) {
    country_col <- unname(schema[["country"]])
    date_col <- unname(schema[["date"]])
    input <- data.frame(row_id = seq_along(countries))
    input[[country_col]] <- countries
    input[[date_col]] <- dates
    args <- list(df = input, ctry_col = country_col,
                 lab_locs = kpi_test_lab_locations())
    # The existing dateonset default must still work for C1 and positive samples.
    if (date_col != "dateonset") args$date_col <- date_col
    result <- do.call(add_seq_capacity, args)
    expect_identical(result$row_id, input$row_id)
    expect_identical(result[[date_col]], dates)
    expect_identical(result$seq.lab, c("CDC-Atlanta", "Nigeria", "Noguchi-Ghana",
                                      "Uganda", "CDC-Atlanta", "Ethiopia"))
    expect_identical(result$seq.capacity, c("no", "yes", "no", "yes", "yes", "yes"))
  }
})

test_that("C3 calculates environmental timeliness without an AFP onset column", {
  dates <- as.Date(c("2024-01-01", "2024-12-31", "2025-01-31", "2025-02-01"))
  es <- data.frame(
    ADM0_NAME = "NIGERIA", site.name = "Test site", lat = 1, lng = 1,
    collect.date = dates, date.received.in.lab = dates + 2,
    date.notification.to.hq = dates + 40, sample.condition = "Good",
    ev.detect = 1, wpv = 1, vdpv = 0
  )
  risk <- data.frame(Country = "NIGERIA", Region = "AFRO",
                     `SG Priority Level` = "HIGH", check.names = FALSE)
  result <- generate_c3_table(
    es, "2024-01-01", "2025-12-31",
    lab_locs = kpi_test_lab_locations(), risk_table = risk
  )
  result <- result[order(result$year_label), ]
  expect_identical(result$year_label, c("Year 1", "Year 2"))
  expect_equal(result$prop_timely_det_wpv_vdpv, c(100, 50))
  expect_equal(result$es_samples, c(2, 2))
})
