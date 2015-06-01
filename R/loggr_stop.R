# NOTE: this probably wants a better name, so I have not exposed it
# yet.
log_stop <- function(names = loggr_list())
{
  all_names <- loggr_list()

  if (!all(names %in% loggr_list())) {
    stop("Unknown loggers: ",
         paste(setdiff(names, all_names), collapse=", "))
  }

  loggr_objects <- getOption("loggr_objects")
  for (x in loggr_objects[all_names %in% names]) {
    if (is.function(x$close)) {
      x$close(x)
    }
  }
  loggr_objects <- loggr_objects[!(all_names %in% names)]
  if (length(loggr_objects) == 0L) {
    loggr_objects <- NULL
  }
  options(loggr_objects = loggr_objects)

  if (is.null(loggr_objects)) {
    hooks <- c("warning", "stop", "signalCondition")
    suppressMessages({
      untrace(base::signalCondition)
      untrace(base::stop)
      untrace(base::warning)
    })
  }

  invisible()
}

# List active loggr targets:
loggr_list <- function() {
  vapply(getOption("loggr_objects"), "[[", character(1), i = "name",
         USE.NAMES=FALSE)
}
