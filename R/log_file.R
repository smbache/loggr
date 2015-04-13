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

  # capture arguments defining the subscriptions
  subscriptions  <- unlist(as.character(eval(substitute(alist(...)))))

  # If none are given, all are used.
  if (length(subscriptions) == 0){
    subscriptions <- c("DEBUG", "INFO", "WARN", "ERROR", "CRITICAL")
  }

  # Append the classic conditions, if not deselected.
  subscriptions <- c(subscriptions,
                     c("simpleMessage",
                       "simpleWarning",
                       "simpleError")[c(.message, .warning, .error)])

  # Create a loggr_file object
  loggr_file <- structure(class = "loggr_file",
                          list(subscriptions = subscriptions,
                               file_name     = file_name,
                               formatter     = .formatter))

  # Ectract any existing active loggr_files
  loggr_files <- getOption("loggr_files")
  file_names  <- vapply(loggr_files, `[[`, character(1L), i = "file_name")

  # If the file is already active, overwrite with new setup.
  if (file_name %in% file_names)
    loggr_files[[which(file_names == file_name)]] <- loggr_file
  else # otherwise append it
    loggr_files <- append(loggr_files, list(loggr_file))

  # Replace the list
  options(loggr_files = loggr_files)

  # Make R CMD check ignore the use of .Internal.
  internal <- eval(as.name(".Internal"))

  # Assign the handler upon exiting this function if currently inactive. Direct
  # call would reset the handlers on exit.
  if (!handler_is_set())
    on.exit({
      internal(.addCondHands("condition",
                             list(condition = log_handler),
                             .GlobalEnv,
                             .GlobalEnv,
                             TRUE))
      })


  invisible()
}
