#' Signal an info event to log file handlers.
#'
#' Create and signal an info condition. And condition handlers listening
#' for \code{INFO} log events will be notified.
#'
#' @param message character: the message to log.
#' @export
log_info <- function(message)
{
  event <- log_event("INFO", message)
  invisible(signalCondition(event))
}

#' Signal an error event to log file handlers.
#'
#' Create and signal an error condition. And condition handlers listening
#' for \code{ERROR} log events will be notified.
#'
#' @param message character: the message to log.
#' @export
log_error <- function(message)
{
  event <- log_event("ERROR", message)
  invisible(signalCondition(event))
}

#' Signal a DEBUG event to log file handlers.
#'
#' Create and signal a debug condition. And condition handlers listening
#' for \code{DEBUG} log events will be notified.
#'
#' @param message character: the message to log.
#' @export
log_debug <- function(message)
{
  event <- log_event("DEBUG", message)
  invisible(signalCondition(event))
}

#' Signal a WARN event to log file handlers.
#'
#' Create and signal a WARN condition. And condition handlers listening
#' for \code{WARN} log events will be notified.
#'
#' @param message character: the message to log.
#' @export
log_warn <- function(message)
{
  event <- log_event("WARN", message)
  invisible(signalCondition(event))
}

#' Signal a CRITICAL event to log file handlers.
#'
#' Create and signal a critical condition. And condition handlers listening
#' for \code{CRITICAL} log events will be notified.
#'
#' @param message character: the message to log.
#' @export
log_critical <- function(message)
{
  event <- log_event("CRITICAL", message)

  stop(event)
}
