#' Convert Message Input to its Character Representation
#'
#' @noRd
#' @param message character or formula for string interpolation.
#' @return character string
log_message <- function(message)
{
  if (inherits(message, "formula"))
    str_interp(message, environment(message))
  else
    as.character(message)
}
