#' Signal Event to Log File Handlers.
#'
#' Create and signal an DEBUG, INFO, WARN, ERROR or CRITICAL
#' condition. The appropriate condition handlers listening
#' for the type of event signalled will be notified.
#' The message can be wrapped in a one sided formula, in which case
#' string interpolation will be used.
#'
#' The function \code{log_with_level} is not intended for direct use.
#' Rather the other functions redirect to this function with the
#' appropriate level set.
#'
#' @section Using log functions in pipeline expressions:
#' It is possible to use logging as part of a pipeline by specifying the
#' message as a two-sided formula with the dot placeholder as
#' left-hand side, i.e. \code{. ~ message}. In this case the value can
#' be referenced in string interpolations as `.`. Since the piped
#' object is placed as the first argument, the message is now technically
#' the first element in \code{...} and is identified if this is
#' a formula in the appropriate form.
#'
#' @param message character: the message to log.
#' @param ... additional data to log (ignored by default formatter)
#' @export
#' @rdname logfunctions
#' @examples
#' log_file("console")
#' log_info("Basic information.")
#'
#' dollars <- 10
#' log_info(~ "I have ${dollars} dollars.")
#'
#' \dontrun{
#' library(magrittr)
#' log_file("console")
#'
#' iris_sub <-
#'   iris %>%
#'   subset(Species == "versicolor") %>%
#'   log_info(. ~ "Keeping ${NROW(.)} versicolor rows.") %>%
#'   transform(Ratio = Sepal.Length/Sepal.Width)
#' }
log_info <- function(message, ...)
{
  cl <- match.call()
  cl[[1L]] <- call("::", quote(loggr), quote(log_with_level))
  cl[[".level"]] <- "INFO"
  eval(cl, parent.frame(), parent.frame())
}

#' @export
#' @rdname logfunctions
log_error <- function(message, ...)
{
  cl <- match.call()
  cl[[1L]] <- call("::", quote(loggr), quote(log_with_level))
  cl[[".level"]] <- "ERROR"
  eval(cl, parent.frame(), parent.frame())
}

#' @export
#' @rdname logfunctions
log_debug <- function(message, ...)
{
  cl <- match.call()
  cl[[1L]] <- call("::", quote(loggr), quote(log_with_level))
  cl[[".level"]] <- "DEBUG"
  eval(cl, parent.frame(), parent.frame())
}

#' @export
#' @rdname logfunctions
log_warn <- function(message, ...)
{
  cl <- match.call()
  cl[[1L]] <- call("::", quote(loggr), quote(log_with_level))
  cl[[".level"]] <- "WARN"
  eval(cl, parent.frame(), parent.frame())
}

#' @export
#' @rdname logfunctions
log_critical <- function(message, ...)
{
  cl <- match.call()
  cl[[1L]] <- call("::", quote(loggr), quote(log_with_level))
  cl[[".level"]] <- "CRITICAL"
  eval(cl, parent.frame(), parent.frame())
}

#' @export
#' @param .level character the logging level.
#' @rdname logfunctions
log_with_level <- function(message, ..., .level)
{
  args <- list(...)

  has_formula <- has_loggr_formula(args)

  if (has_formula) {
    # In this case message is actually a value.
    env <- new.env(parent = environment(args[[1L]]))
    env[["."]] <- message
    event <- log_event(.level, log_message(args[[1L]], env), args[-1L])
    result <- message
  } else {
    message <- log_message(message, parent.frame())
    event <- log_event(.level, message, ...)
    result <- NULL
  }

  # Determine whether to break or only signal the event.
  if (!identical(.level, "CRITICAL")) {
    signalCondition(event)
    invisible(result)
  } else {
    stop(event)
  }
}
