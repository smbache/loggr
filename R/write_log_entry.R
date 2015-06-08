#' Write a log entry to a log file.
#'
#' @param obj A logger obj
#' @param condition a condition which can be coersed to a log_event.
write_log_entry <- function(obj, condition)
{
  obj$write(obj, obj$formatter(as_log_event(condition)))
}

write_file <- function(obj, str)
{
  cat(add_trailing_newline(str), file = obj$file_name, append = TRUE)
}

write_connection <- function(obj, str)
{
  cat(add_trailing_newline(str), file = obj$con, append = TRUE)
  if (obj$flush) {
    flush(obj$con)
  }
}

add_trailing_newline <- function(str)
{
  if (grepl("\n", str)) {
    str
  } else {
    paste0(str, "\n")
  }
}
