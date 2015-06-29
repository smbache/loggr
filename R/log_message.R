#' Convert Message Input to its Character Representation
#'
#' @noRd
#' @param message character or formula for string interpolation.
#' @param env Environment used for string interpolation.
#' @return character string
log_message <- function(message, env = parent.frame())
{
  if (inherits(message, "formula"))
    str_interp(message, env)
  else
    as.character(message)
}
