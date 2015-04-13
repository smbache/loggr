#' Check if loggr's handler is set.
#'
#' @return logical
handler_is_set <- function()
{
  options(loggr_active = FALSE)
  log_ping <-structure(
    class = c("log_ping", "condition"),
    list(message = "Pinging loggr's condition handler.")
  )
  signalCondition(log_ping)
  isTRUE(getOption("loggr_active"))
}
