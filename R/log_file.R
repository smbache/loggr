# Declare the .addCondHands function to inform R CMD check about it.
globalVariables(".addCondHands")

#' Activate a log file
#'
#' @param file_name character: path to the log file.
#' @param ... list of quoted or unquoted events to log. In none are
#'   provided all log events will be captured.
#' @param .warning logical: capture regular warnings (\code{simpleWarning})?
#' @param .error logical: capture regular errors (\code{simpleError})?
#' @param .message logical: capture regular messages (\code{simpleMessage})?
#' @param .formatter logical: the formatting function to use to convert
#'   a log event to its character representation.
#' @return NULL invisibly
#' @export
log_file <- function(file_name, ...,
                     .warning   = TRUE, .error = TRUE, .message = TRUE,
                     .formatter = format_log_entry)
{

  # Setup a new log file, or continue with existing.
  action <- ifelse(!file.exists(file_name), "created", "continued with")
  if (action == "created") {
    file.create(file_name)
  }
  init_event <- log_event("INFO",
                          sprintf("R session %s this log file.\n", action))
  cat(.formatter(init_event), "\n", file = file_name, append = TRUE)

  # capture arguments defining the classes
  classes  <- unlist(as.character(eval(substitute(alist(...)))))

  if (length(classes) == 0){
    classes <- c("DEBUG", "INFO", "WARN", "ERROR", "CRITITCAL")
  }

  # The actual function triggered by log events that writes to file.
  event_writer <- function(e) {
    le <- as_log_event(e)
    msg <- .formatter(le)
    # The logging itself should not break the program(s).
    try({
      cat(msg, "\n", file = file_name, append = TRUE)
    })
  }

  # Setup the arguments for condition handler assignment.
  writer_list <- vector("list", length(classes))
  names(writer_list) <- classes
  for (i in seq_along(classes)){
    writer_list[[i]] <- log_event_writer
  }

  writer_list <- c(writer_list, list(simpleMessage = event_writer,
                                     simpleWarning = event_writer,
                                     simpleError   = event_writer)[c(.message, .warning, .error)])
  global_environment <- .GlobalEnv

  # Make R CMD check ignore the use of .Internal.
  internal <- eval(as.name(".Internal"))

  # Assign the handlers upon exiting this function. Direct
  # call would reset the handlers on exit.
  on.exit(internal(.addCondHands(names(writer_list), writer_list, global_environment, global_environment, TRUE)))

  invisible()
}
