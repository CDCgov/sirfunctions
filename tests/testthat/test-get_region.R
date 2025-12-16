library(testthat)

test_that("get_region returns correct region for known countries", {
  expect_equal(get_region("Kenya"), "AFRO")
  expect_equal(get_region("Brazil"), "AMRO")
  expect_equal(get_region("Egypt"), "EMRO")
  expect_equal(get_region("France"), "EURO")
  expect_equal(get_region("India"), "SEARO")
  expect_equal(get_region("Japan"), "WPRO")
})

test_that("get_region handles different cases and whitespace", {
  expect_equal(get_region("  kenya  "), "AFRO")
  expect_equal(get_region("brazil"), "AMRO")
  expect_equal(get_region("  EGYPT"), "EMRO")
})

test_that("get_region returns NA for unknown country", {
  expect_true(is.na(get_region("Atlantis")))
})

test_that("get_region handles alternative country names", {
  expect_equal(get_region("Cote D'Ivoire"), "AFRO")
  expect_equal(get_region("Cote D Ivoire"), "AFRO")
})
