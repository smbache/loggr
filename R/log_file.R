# Declare the .addCondHands function to inform R CMD check about it.
globalVariables(".addCondHands")

#' @title Activate a log file
#'
#' @description \code{log_file} creates an active instance
#' of a log file that loggr can pass errors, warnings and messages
#' on to. If this file already exists, it will be appended
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
#' @param .formatter logical: the formatting function to use to convert
#'   a log event to its character representation.
#'
#' @param overwrite whether or not to overwrite the file at \code{file_name}
#' if it already exists. Set to FALSE by default.
#'
#' @return NULL invisibly
#'
#' @examples
#'
#' #Create a "default" log file instance
#' log_file()
#'
#' #Create a log file instance that only checks errors
#' log_file("errors_only_thanks.log", .warning = FALSE, .message = FALSE)
#'
#' @export
log_file <- function(file_name, ...,
                     .warning   = TRUE, .error = TRUE, .message = TRUE,
                     .formatter = format_log_entry, overwrite = FALSE){

  if (!is.vector(file_name, "character") || file_name == ""){
    stop("Please provide a valid file name.", call. = FALSE)
  }


  # Make sure logging hooks have been setup.
  use_logging()

  if (!file_name %in% c("stdout", "console")) {

    #If the file doesn't exist, create it. If the file
    #does exist, and overwrite is TRUE, delete and replace.
    #If the file does exist and overwrite is FALSE, just append.
    if(!file.exists(file_name)){
      action <- "created"
      file.create(file_name)
    } else if(file.exists(file_name) & overwrite){
      action <- "created"
      file.remove(file_name)
      file.create(file_name)
    } else {
      action <- "continued with"
    }
    init_event <- log_event("INFO", sprintf("R session %s this log file.\n", action))
    cat(.formatter(init_event), "\n", file = file_name, append = TRUE)
  }

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

  invisible()
}
