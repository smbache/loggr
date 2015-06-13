#' @title Activate a log file
#'
#' @description \code{log_file} creates an active instance
#' of a log file to which loggr can pass errors, warnings and messages.
#' If this file already exists, it will be appended
#' to unless \code{overwrite} is set to TRUE.
#'
#' @param file_name the path to the log file.
#'
#' @param ... list of quoted or unquoted events to log. In none are
#'   provided all log events will be captured.
#'
#' @param .warning logical: capture regular warnings (\code{simpleWarning})?
#'
#' @param .error logical: capture regular errors (\code{simpleError})?
#'
#' @param .message logical: capture regular messages (\code{simpleMessage})?
#'
#' @param .formatter function: the formatting function used to convert
#'   a log event to its character representation for the log file.
#'
#' @param subscriptions character vector: optional list of
#' subscriptions to use (in place of specifying with \code{...}).
#'
#' @param overwrite logical: whether or not to overwrite the file at
#' \code{file_name} if it already exists. Set to FALSE by default.
#'
#' @param log_muffled logical: Log messages and warnings
#'   even if muffled? This affects only logging as result of
#'   \code{warning} and \code{message}.
#'
#' @return \code{NULL}, invisibly.
#'
#' @examples
#' \dontrun{
#' #Create a "default" log file instance
#' log_file()
#'
#' #Create a log file instance that only checks errors
#' log_file("errors_only_thanks.log", ERROR, CRITICAL,
#'          .warning = FALSE, .message = FALSE)
#' }
#' @export
log_file <- function(file_name,
                     ...,
                     .warning       = TRUE,
                     .error         = TRUE,
                     .message       = TRUE,
                     .formatter     = format_log_entry,
                     subscriptions  = NULL,
                     overwrite      = TRUE,
                     log_muffled    = FALSE)
{
  # capture arguments defining the subscriptions
  subscriptions <- loggr_subscriptions(.warning, .error, .message, ...,
                                       subscriptions = subscriptions)

  if (missing(file_name)) {
    file_name <- "console"
  }

  if (identical(file_name, "stdout") || identical(file_name, "stderr")) {
    return(log_connection(get(file_name, baseenv())(),
                          .formatter = .formatter,
                          subscriptions = subscriptions,
                          flush = FALSE,
                          log_muffled = log_muffled))
  }

  if (!is.character(file_name) || length(file_name) != 1L) {
    stop("Please provide a valid file name.", call. = FALSE)
  }

  name <- file_name
  if (file_name == "console") {
    file_name <- ""
  } else if (!file.exists(file_name)) {
    file.create(file_name)
  } else if (file.exists(file_name) && overwrite) {
    file.remove(file_name)
    file.create(file_name)
  }

  obj <- list(name = name, file_name = file_name, write = write_file)

  loggr_start(obj, subscriptions, .formatter, log_muffled = log_muffled)
}

log_connection <- function(con,
                           ...,
                           .warning      = TRUE,
                           .error        = TRUE,
                           .message      = TRUE,
                           .formatter    = format_log_entry,
                           subscriptions = NULL,
                           flush         = TRUE,
                           log_muffled   = FALSE)
{
  subscriptions <- loggr_subscriptions(.warning, .error, .message, ...,
                                       subscriptions = subscriptions)

  if (!inherits(con, "connection")) {
    stop("Expected a connection object")
  }

  closed_on_entry <- !isOpen(con)
  if (closed_on_entry) {
    open(con, "a")
  }

  obj <- list(name  = summary(con)[["description"]],
              con   = con,
              write = write_connection,
              flush = flush)

  # Don't try and close anything that was given to us open (which
  # includes standard connections - stdout and stderr)
  if (closed_on_entry) {
    obj$close <- log_connection_close
  }

  loggr_start(obj, subscriptions, .formatter, log_muffled)
}

log_connection_close <- function(obj) {
  close(obj$con)
}

## Helper functions to make the above work:
loggr_start <- function(object, subscriptions, formatter = format_log_entry,
                        log_muffled = FALSE)
{
  if (is.null(object$name) ||
     !is.character(object$name) ||
      length(object$name) != 1L) {
    stop("Log object must have a name (scalar character value).", call. = FALSE)
  }

  if (is.null(object$write) || !is.function(object$write)) {
    stop("Log object must include a `write` function.", call. = FALSE)
  }

  # Make sure logging hooks have been setup.
  use_logging()

  object$subscriptions <- subscriptions
  object$formatter <- formatter
  object$log_muffled <- log_muffled

  loggr_objects <- getOption("loggr_objects", list())
  loggr_objects[[object$name]] <- object
  options(loggr_objects = loggr_objects)

  if ("INFO" %in% toupper(subscriptions)) {
    init_msg <- sprintf("Activating logging to %s", object$name)
    on.exit(log_info(init_msg))
  }

  invisible()
}

loggr_subscriptions <- function(.warning, .error, .message, ..., subscriptions)
{
  if (is.null(subscriptions)) {
    subscriptions <- unlist(as.character(eval(substitute(alist(...)))))
  }
  if (length(subscriptions) == 0) {
    subscriptions <- c("DEBUG", "INFO", "WARN", "ERROR", "CRITICAL")
  }
  # Append the classic conditions, if not deselected.
  c(subscriptions,
    c("simpleMessage",
      "simpleWarning",
      "simpleError")[c(.message, .warning, .error)])
}
