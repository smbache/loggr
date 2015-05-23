#' Notify loggr about an event.
#'
#' This is an internal function used by loggr to hook into the relevant
#' events.
#'
#' @param ... arguments passed to the original event.
#' @param type character: either "warning", "error", or "other"
notify_loggr <- function(..., type = "other")
{
  # Convert information in ... to a log_event
  args <- list(...)
  if (inherits(args[[1L]], "condition")) {
    cond <- args[[1L]]
  } else if (type == "error") {
      # Can we get the call here?
      cond <- simpleError(.makeMessage(args[[1L]], domain = args[["domain"]]))
  } else if (type == "warning") {
      # Can we get the call here?
      cond <- simpleWarning(.makeMessage(args[[1L]], domain = args[["domain"]]))
  } else {
      cond <- simpleCondition(.makeMessage(args[[1L]], domain = args[["domain"]]))
  }
  le <- as_log_event(cond)

  # Send log entry to subscribed log files.
  loggr_objects <- getOption("loggr_objects")
  for (lo in loggr_objects) {
    if (any(toupper(lo$subscriptions) %in% toupper(class(le)))) {
      try(write_log_entry(lo, le))
    }
  }

  invisible()
}
