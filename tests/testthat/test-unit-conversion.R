context("Unit scaling")

# Basic unit scaling ====

test_that("common SI prefixes are supported", {

  # finding base units
  expect_error(get_base_unit(c("A", "V")), "cannot determine")
  expect_error(get_base_unit(c("kA", "xA")), "unsupported prefixes.*x")
  expect_equal(get_base_unit(c("mV", "V")), "V")
  expect_equal(get_base_unit(c("mVs/m2", "Vs/m2")), "Vs/m2")

  # parameters missing
  expect_error(get_si_prefix_scaling(unit = "km"), "no unit suffix specified")
  expect_error(get_si_prefix_scaling(suffix = "m"), "no unit supplied")

  # prefix mismatch
  expect_error(get_si_prefix_scaling("lm", "m"), "unrecognized unit")

  # suffix mismatch
  expect_error(get_si_prefix_scaling("km", "V"), "unrecognized unit")

  # specific values
  expect_equal(get_si_prefix_scaling("m", "m"), 1)
  expect_equal(get_si_prefix_scaling(c("mm", "km"), "m"), c(0.001, 1000))
  expect_equal(get_si_prefix_scaling(c("mm", "km"), "m"), c(0.001, 1000))
  expect_equal(
    get_si_prefix_scaling(
      c("fm", "pm", "nm", "\U00B5m", "mm", "m", "km", "Mm", "Gm", "Tm"), "m"),
    10^(3*c(-5:4)))

  # suffix independence
  expect_equal(
    get_si_prefix_scaling("fA", "A"),
    get_si_prefix_scaling("fV", "V"))

  # parameter order
  expect_equal(
    get_si_prefix_scaling(unit = "fA", suffix = "A"),
    get_si_prefix_scaling(suffix = "A", unit = "fA"))

  # scaling by figuring out base units directly
  expect_equal(get_si_prefix_scaling(c("mVs", "Vs")), c(0.001, 1))
  expect_equal(get_si_prefix_scaling(c("mVs", "mVs")), c(1, 1))

  # conversion factor
  expect_equal(get_unit_conversion_factor(c("mVs", "kA"), c("Vs", "nA")), c(1e-3, 1e12))

  # double with units scaling
  expect_equal(
    iso_double_with_units(1:10, "mV") %>% iso_scale_double_with_units("V"),
    iso_double_with_units( (1:10) / 1000, "V")
  )
  expect_equal(
    iso_double_with_units(1:10, "kV") %>% iso_scale_double_with_units("mV"),
    iso_double_with_units( (1:10) * 1e6, "mV")
  )
})

test_that("test that proper units can be found", {
  expect_error(get_unit_scaling(), "missing parameters")
  expect_error(get_unit_scaling("mV"), "missing parameters")
  expect_error(get_unit_scaling(c("mV", "V"), "V"), "can only find scaling for one unit")
  expect_error(get_unit_scaling("mV", "A"), "encountered invalid unit")
  expect_error(get_unit_scaling("blaV", "V"), "Encountered unrecognized unit")
  expect_equal(get_unit_scaling("mV", c("A", "V")),
               list(base_unit = "V", si_scaling = 1e-3))
  expect_equal(get_unit_scaling("nA", c("A", "V")),
               list(base_unit = "A", si_scaling = 1e-9))
})

# TIme conversions ====

test_that("test that time scaling works", {
  time <- 1:60

  # direct numbers
  expect_error(scale_time(time, to = "s"), "requires specifying from unit")
  expect_equal(scale_time(time, from = "min", to = "s"), time*60)
  expect_equal(scale_time(time, from = "min", to = "hour"), time/60)
  expect_equal(scale_time(time, from = "hours", to = "seconds"), time*60*60)
  expect_equal(scale_time(time, from = "second", to = "days"), time/60/60/24)

  # with duration object
  expect_warning(scale_time(lubridate::duration(time, "hours"), from = "s", to = "minutes"), "ignored")
  expect_equal(scale_time(lubridate::duration(time, "hours"), to = "minutes"), time*60)
})

test_that("test that time conversion works for iso_files", {
  expect_error(iso_convert_time(42), "can only convert time in continuous flow iso_files")
  cf <- isoreader:::make_cf_data_structure("NA")
  expect_error(iso_convert_time(cf), "no time unit to convert to specified")
  expect_warning(iso_convert_time(cf, to = "min"), "read without extracting the raw data")

  # test data
  cf$read_options$raw_data <- TRUE
  cf$raw_data <- tibble(tp = 1:10, time.s = tp*0.2)
  expect_message(result <- iso_convert_time(cf, to = "min", quiet = FALSE), "converting time")
  expect_true(iso_is_file(result))
  expect_silent(iso_convert_time(cf, to = "min", quiet = TRUE))
  expect_equal(iso_convert_time(cf, to = "min")$raw_data$time.min, cf$raw_data$time.s/60)
  expect_equal(iso_convert_time(cf, to = "s")$raw_data$time.s, cf$raw_data$time.s)

  # multiple files
  iso_files <- c(modifyList(cf, list(file_info = list(file_id = "a"))),
                modifyList(cf, list(file_info = list(file_id = "b"))))
  iso_files$b$raw_data$time.min <- iso_files$b$raw_data$time.s/60
  iso_files$b$raw_data$time.min <- NULL
  expect_true(iso_is_file_list(iso_files_in_hrs <- iso_convert_time(iso_files, to = "hours")))
  expect_equal(iso_files_in_hrs$a$raw_data$time.hours, cf$raw_data$time.s/3600)
  expect_equal(iso_files_in_hrs$b$raw_data$time.hours, cf$raw_data$time.s/3600)

})

# Voltage/current conversion ====

context("Voltage/Current conversion")

test_that("test that singal scaling works", {
  #data frame supplied
  expect_error(scale_signals(), "data has to be supplied as a data frame")
  expect_error(scale_signals(5), "data has to be supplied as a data frame")

  # other parameters  supplied
  expect_error(scale_signals(tibble()), ".* parameters required")
  expect_error(scale_signals(tibble(), c()), ".* required")
  expect_error(scale_signals(tibble(), "v44.mV"), ".* required")
  expect_error(scale_signals(tibble(), "v44.mV", "nA", c()), "resistance values have to be a named numeric vector")
  expect_error(scale_signals(tibble(), "v44.mV", "nA", c(1)), "resistance values have to be a named numeric vector")
  expect_error(scale_signals(tibble(), "v44.mV", "nA", c(R2 = "text")), "resistance values have to be a named numeric vector")

  # signal columns
  test_data <-
    tibble(
      v44.mV = c(1:10)*1000,
      v45.mV = c(1:10)*5000,
      v46.V = c(1:10),
      i47.nA = c(1:10)
    )
  Rs <- c(R44 = 1, R45 = 1e3)

  expect_error(scale_signals(test_data, c("v44", "44.mV"), to = "nA", R = Rs),
               "some signal columns do not fit the expected pattern")
  expect_error(scale_signals(test_data, c("v44.mV", "v46.mV", "v47.mV"), to = "nA", R = Rs),
               "some signal columns do not exist")
  expect_error(scale_signals(
    rename(test_data, v44.blaV = v44.mV), "v44.blaV", to = "nA", R = Rs),
    "Encountered unrecognized units")
  expect_error(scale_signals(test_data, "v44.mV", to = "blaA", R = Rs),
               "Encountered unrecognized units")
  expect_error(scale_signals(test_data, "v44.mV", to = "blaA", R = Rs, R_units = "blaOhm"),
               "Encountered unrecognized units")
  expect_error(scale_signals(test_data, c("v44.mV", "v46.V", "i47.nA"), to = "nA", R = Rs),
               "not all resistors required .* missing: R46")
  expect_error(scale_signals(test_data, c("v44.mV", "v46.V", "i47.nA"), to = "mV", R = Rs),
               "not all resistors required .* missing: R47")

  # test conversion - mixed voltage to current conversion and scaling
  Rs <- c(R44 = 5, R45 = 1e3, R46 = 10, R47 = 10)
  expect_is(
    conv_data <- scale_signals(
      test_data, c("v44.mV", "v46.V", "i47.nA"), to = "pA", R = Rs), "tbl_df")
  expect_equal(conv_data$i44.pA, test_data$v44.mV*1e-3/(5*1e9 * 1e-12)) # mV to pA
  expect_equal(conv_data$v45.mV, conv_data$v45.mV) # no convertion, was not included
  expect_equal(conv_data$i46.pA, test_data$v46.V/(10*1e9 * 1e-12)) # mV to pA
  expect_equal(conv_data$i47.pA, test_data$i47.nA*1000) # simple scaling

  # test conversion - mixed current to voltage and scaling
  expect_is(
    conv_data <- scale_signals(
      test_data, c("v45.mV", "v46.V", "i47.nA"), to = "kV", R = Rs, R_units = "MOhm"), "tbl_df")
  expect_equal(conv_data$v44.mV, test_data$v44.mV) # no convertion, was not included
  expect_equal(conv_data$v45.kV, test_data$v45.mV/1e6) # mV to kV, scaling
  expect_equal(conv_data$v46.kV, test_data$v46.V/1e3) # V to kV, scaling
  expect_equal(conv_data$v47.kV, test_data$i47.nA*1e-9*10*1e6/1e3) # nA to kV

  # test - scaling only
  expect_is(conv_data <- scale_signals(test_data, c("v44.mV", "v45.mV", "v46.V"), to = "V"), "tbl_df")
  expect_equal(conv_data$v44.V, test_data$v44.mV/1e3) # mV to V, scaling
  expect_equal(conv_data$v45.V, test_data$v45.mV/1e3) # mV to V, scaling
  expect_equal(conv_data$v46.V, test_data$v46.V) # V to V, scaling
  expect_equal(conv_data$i47.nA, test_data$i47.nA) # no conversion, was not included not included

})

test_that("test that signal conversion works in iso_files", {

  expect_error(iso_convert_signals(42), "can only convert signals in .* iso_files")
  cf <- isoreader:::make_cf_data_structure("NA") # use continuous flow example, but dual inlet would work too
  expect_error(iso_convert_signals(cf), "no unit to convert to specified")

  cf$read_options$raw_data <- TRUE
  cf$raw_data <- tibble(tp = 1:10, time.s = tp*0.2, v44.mV = runif(10), v46.mV = runif(10), `r46/44` = v46.mV/v44.mV)
  expect_error(iso_convert_signals(cf, to = "42"), "encountered invalid unit")
  expect_error(iso_convert_signals(cf, to = "blaV"), "Encountered unrecognized units")

  # test scaling without resistors
  expect_message(result <- iso_convert_signals(cf, to = "nV", quiet = FALSE), "converting signals")
  expect_true(iso_is_file(result))
  expect_silent(iso_convert_signals(cf, to = "nV", quiet = TRUE))
  expect_equal(result$raw_data$v44.nV, cf$raw_data$v44.mV*1e6)
  expect_true(is.null(cf$bgrd_data)) # no background involved
  expect_true(is.null(result$bgrd_data)) # no background involved

  ## with background
  cf2 <- cf
  cf2$bgrd_data <- tibble(v44.mV = runif(10), v46.mV = runif(10))
  expect_message(result2 <- iso_convert_signals(cf2, to = "nV", quiet = FALSE), "converting signals")
  expect_equal(result2$raw_data$v44.nV, cf2$raw_data$v44.mV*1e6)
  expect_equal(result2$bgrd_data$v44.nV, cf2$bgrd_data$v44.mV*1e6)

  # FIXME: continug here - conversion with resistors

})

# Peak Table unit conversion ====

context("Peak table unit conversion")

test_that("test that peak table unit conversion works", {

  df <- tibble(x = iso_double_with_units(1:5, "mV"), y = iso_double_with_units(1:5, "V"), z = iso_double_with_units(1:5, "V"))
  expect_equal(iso_convert_peak_table_units(df), df)
  expect_error(iso_convert_peak_table_units(df, 1), "must be named")
  expect_error(iso_convert_peak_table_units(df, list(a = "1")), "must be named")
  expect_error(iso_convert_peak_table_units(df, c(a = 1)), "must be named")
  expect_error(iso_convert_peak_table_units(df, "1"), "must be named")

  # test conversions
  expect_silent(iso_convert_peak_table_units(df, kV = "mV", kV = "V", quiet = TRUE))
  expect_message(
    out <- iso_convert_peak_table_units(df,  kV = "mV", kV = "V"),
    "converting.*mV.*V.*V.*kV.*everything"
  )
  expect_equal(
    out,
    mutate(
      df,
      x = iso_scale_double_with_units(x, "kV"),
      y = iso_scale_double_with_units(y, "kV"),
      z = iso_scale_double_with_units(z, "kV")
    )
  )
  expect_equal(out, iso_convert_peak_table_units(df,kV = mV, kV = V))
  expect_message(
    out2 <- iso_convert_peak_table_units(df, kV = mV, kV = V, select = NULL),
    "converting.*mV.*V.*V.*kV.*NULL"
  )
  expect_equal(out2, df)
  expect_equal(
    iso_convert_peak_table_units(df, kV = mV, kV = V, select = c(x, y)),
    mutate(
      df,
      x = iso_scale_double_with_units(x, "kV"),
      y = iso_scale_double_with_units(y, "kV")
    )
  )
  expect_equal(
    iso_convert_peak_table_units(df, kV = mV),
    mutate(
      df,
      x = iso_scale_double_with_units(x, "kV")
    )
  )

  # in iso_files
  iso_file_a <- isoreader:::make_cf_data_structure("a")
  iso_file_a$peak_table <- df
  expect_equal(iso_convert_peak_table_units(iso_file_a, kV = mV, kV = V)$peak_table, out)

  iso_file_b <- isoreader:::make_cf_data_structure("b")
  iso_file_b$peak_table <- df
  expect_equal(iso_convert_peak_table_units(c(iso_file_a, iso_file_b), kV = mV, kV = V) %>% iso_get_peak_table() %>% select(-file_id), vctrs::vec_rbind(out, out))

})
