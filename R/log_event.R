#' Create a log event
#'
#' A log event is a condition and can be signalled as such.
#' In addition to the classic "simpleMessage", "simpleWarning", and
#' "simpleError" conditions, loggr allows for levels "INFO", "WARN",
#' "DEBUG", "ERROR", "CRITICAL".
#'
#' @param level character: the event level.
#' @param message character: the event message
#' @param ... further elements to add to the condition.
#'
#' @return A log event (condition)
log_event <- function(level, message, ...)
{
  event_types   <- c("INFO", "WARN", "DEBUG", "ERROR", "CRITICAL")
  classic_types <- c("SIMPLEERROR", "SIMPLEWARNING", "SIMPLEMESSAGE")

  msg <- paste("Invalid subclass. Possible choices are: %s; ",
               "along with the classic types %s.", sep = "")

  level <- toupper(level)

  if (!level %in% event_types &&
      !level %in% classic_types) {
    stop(sprintf(msg,
                 paste(event_types, collapse = ", "),
                 paste(classic_types, collapse = ", ")),
         call. = FALSE)
  }

  structure(
    class = c(level, "log_event", "condition"),
    list(level = level, message = message, time = Sys.time(), ...)
  )
}

#' Log event conversion methods.
#'
#' Methods for coersing conditions to log events. Methods are predefined
#' for \code{simpleMessage}, \code{simpleWarning}, \code{simpleError}
#' classes, but others can be defined. The default method will raise
#' an error.
#'
#' @param event a \code{condition} to be coersed to a \code{log_event}.
#' @param ... Currently not used.
#'
#' @return a \code{log_event} condition object.
#' @export
as_log_event <- function(event, ...) {
  UseMethod("as_log_event")
}

#' @rdname as_log_event
#' @export
as_log_event.simpleError <- function(event, ...) {
  log_event("simpleError", event$message)
}

#' @rdname as_log_event
#' @export
as_log_event.simpleWarning <- function(event, ...) {
  log_event("simpleWarning", event$message)
}

#' @rdname as_log_event
#' @export
as_log_event.simpleMessage <- function(event, ...) {
  log_event("simpleMessage", event$message)
}

#' @rdname as_log_event
#' @export
as_log_event.log_event <- function(event, ...) event

#' @rdname as_log_event
#' @export
as_log_event.default <- function(event, ...)
{
  simpleWarning("Unable to convert event to a log event.")
}
