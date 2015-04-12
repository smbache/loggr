#' Default log entry formatter.
#'
#' This function serves as the default formatter for loggr and will
#' use the format
#'
#'   time - event type - message
#'
#' @param event The log event to format
#' @return character A string representation of the event for logging.
#'
#' @export
format_log_entry <- function(event)
{
  paste(c(format(event$time, "%Y-%m-%d %H:%M:%OS3"),
          event$level,
          gsub("[\r\n]", " ", event$message)),
        collapse = " - ")
}
