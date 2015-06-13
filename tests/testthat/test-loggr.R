context("loggr")

test_that("start and stop logging", {
  expect_that(loggr_list(), equals(character(0)))
  filename <- "mylog.log"
  suppressWarnings(file.remove(filename))
  log_file(filename)
  on.exit(file.remove(filename))

  dat <- parse_log(readLines(filename))
  expect_that(nrow(dat), equals(1L))
  expect_that(unname(dat[, "level"]), equals("INFO"))
  expect_that(unname(dat[, "message"]), matches(filename))

  str <- random_string()
  log_info(str)
  expect_that(last_msg(filename)[["message"]], matches(str))

  expect_that(loggr_list(), equals(filename))
  deactivate_log()
  expect_that(loggr_list(), equals(character(0)))

  str <- random_string()
  log_info(str)
  expect_that(last_msg(filename)[["message"]], not(matches(str)))

  expect_that(deactivate_log("nofile"),
              throws_error("Unknown loggers: nofile"))
})

test_that("to file", {
  deactivate_log()
  filename <- "mylog.log"
  suppressWarnings(file.remove(filename))
  log_file(filename, log_muffled = TRUE)
  on.exit(file.remove(filename))

  str <- random_string()
  message(str)

  dat <- parse_log(readLines(filename))
  expect_that(nrow(dat), equals(2L))
  expect_that(unname(dat[2, "level"]), equals("SIMPLEMESSAGE"))
  # NOTE: this is only matches() not equals() because two trailing
  # whitespaces are added
  expect_that(unname(dat[2, "message"]), matches(str))

  loggr <- getOption("loggr_objects")
  expect_that(length(loggr), equals(1))
  expect_that(loggr[[1]]$name, equals(filename))

  all_subs <- c("DEBUG", "INFO", "WARN", "ERROR", "CRITICAL",
                "simpleMessage", "simpleWarning", "simpleError")
  expect_that(sort(loggr[[1]]$subscriptions),
              equals(sort(all_subs)))

  log_debug(str <- random_string())
  msg <- last_msg(filename)
  expect_that(msg[["level"]], equals("DEBUG"))
  expect_that(msg[["message"]], matches(str))

  log_info(str <- random_string())
  msg <- last_msg(filename)
  expect_that(msg[["level"]], equals("INFO"))
  expect_that(msg[["message"]], matches(str))

  log_warn(str <- random_string())
  msg <- last_msg(filename)
  expect_that(msg[["level"]], equals("WARN"))
  expect_that(msg[["message"]], matches(str))

  log_error(str <- random_string())
  msg <- last_msg(filename)
  expect_that(msg[["level"]], equals("ERROR"))
  expect_that(msg[["message"]], matches(str))

  ## This one can't be tested apparently:
  ## log_critical(str <- random_string()), throws_error()
  ## msg <- last_msg(filename)
  ## expect_that(msg[["level"]], equals("CRITICAL"))
  ## expect_that(msg[["message"]], matches(str))

  ## replace that log:
  log_file(filename, INFO, .error=FALSE, .message=FALSE, .warning=FALSE)
  loggr <- getOption("loggr_objects")
  expect_that(length(loggr), equals(1)) # replaced original
  expect_that(loggr[[1]]$subscriptions, equals("INFO"))

  str <- random_string()
  message(str)
  expect_that(last_msg(filename)[["message"]], not(matches(str)))

  log_info(str)
  expect_that(last_msg(filename)[["message"]], matches(str))

  # Add a new log, to the console:
  expect_that(log_file("console", log_muffled = TRUE),
              prints_text("INFO"))
  str <- random_string()

  dat <- parse_log(capture.output(message(str)))
  expect_that(unname(dat[1, "message"]), matches(str))
  expect_that(unname(dat[1, "level"]), equals("SIMPLEMESSAGE"))

  loggr <- getOption("loggr_objects")
  expect_that(length(loggr), equals(2)) # added a new log
  expect_that(loggr[[2]]$name, equals("console"))

  str <- random_string()
  tryCatch(log_info(str))
  expect_that(last_msg(filename)[["message"]], matches(str))

  deactivate_log("console")
  expect_that(loggr_list(), equals(filename))
})

test_that("connection", {
  deactivate_log()
  filename <- "mylog.log"
  suppressWarnings(file.remove(filename))
  writeLines("HEADER", filename)
  on.exit(file.remove(filename))
  ## NOTE: connection closed on entry:
  file <- file(filename)
  expect_that(isOpen(file), is_false())
  log_connection(file, flush=TRUE)

  loggr <- getOption("loggr_objects")
  expect_that(isOpen(loggr[[filename]]$con), is_true())
  expect_that(isOpen(file), is_true())

  dat <- readLines(filename)
  expect_that(length(dat), equals(2L))
  expect_that(dat[[1]], equals("HEADER")) # not overwritten
  expect_that(drop(parse_log(dat[[2]]))[["message"]], matches(filename))

  str <- random_string()
  log_info(str)
  expect_that(last_msg(filename)[["message"]], matches(str))

  deactivate_log()
  ## Not sure why this is the case, but it seems to be how R does things:
  ##   con <- file(filename)
  ##   open(con, "a")
  ##   close(con)
  expect_that(isOpen(file), throws_error("invalid connection"))
})
