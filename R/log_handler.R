#' Condition handler for log events
#'
#' The handler will deal with log events for log files setup to receive
#' notice.
#'
#' @param condition A condition object.
log_handler <- function(condition)
{
  valid <- c("log_event", "simpleMessage", "simpleWarning", "simpleError")

  if (inherits(condition, "log_ping")) {
    options(loggr_active = TRUE)
  } else if (inherits(condition, valid)) {
    loggr_files <- getOption("loggr_files")
    for (lf in loggr_files) {
      if (any(lf$subscriptions %in% class(condition))) {
        try(write_log_entry(lf$file_name, condition, lf$formatter))
      }
    }
  }
}
