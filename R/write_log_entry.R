#' Write a log entry to a log file.
#'
#' @param file_name character: the name of the file to write to.
#' @param condition a condition which can be coersed to a log_event.
#' @param formatter function that returns the character representation of a
#'   log event.
#'
write_log_entry <- function(file_name, condition, formatter)
{
  use_file <- if (file_name %in% c("stdout", "console")) "" else file_name
  log_event <- as_log_event(condition)
  cat(formatter(log_event), "\n", file = use_file, append = TRUE)
}
