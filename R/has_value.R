#' Check Log Function Arguments for Value
#'
#' To allow using log_* in pipeline expressions,
#' they check whether first ellipsis argument is a valid loggr
#' formula of the form \code{. ~ message}.
#'
#' @param args ellipsis arguments passed to a log_* function.
#' @return logical indicating whether a loggr formula is detected.
#' @noRd
has_loggr_formula <- function(args)
{
  length(args) > 0 &&
  inherits(args[[1L]], "formula") &&
  length(args[[1L]]) == 3L &&
  identical(args[[1L]][[2L]], quote(.))
}
