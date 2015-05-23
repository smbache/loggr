# NOTE: this probably wants a better name, so I have not exposed it
# yet.
log_stop <- function(names = loggr_list())
{
  all_names <- loggr_list()

  if (!all(names %in% loggr_list())) {
    stop("Unknown loggers: ",
         paste(setdiff(names, all_names), collapse=", "))
  }

  loggr_files <- getOption("loggr_files")[!(all_names %in% names)]
  if (length(loggr_files) == 0L) {
    loggr_files <- NULL
  }
  options(loggr_files = loggr_files)

  if (is.null(loggr_files)) {
    hooks <- c("warning", "stop", "signalCondition")
    success <- vapply(hooks, unset_loggr_hook, logical(1))
    if (!all(success)) {
      stop("Failed to remove loggr hooks.", call. = FALSE)
    }
  }

  invisible()
}

# List active loggr targets:
loggr_list <- function() {
  vapply(getOption("loggr_files"), "[[", character(1), i = "file_name")
}
