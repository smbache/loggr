#' Activate logging by loggr
#'
#' This function hooks up \code{loggr}s handler which is activated by calls
#' to \code{\link{message}}, \code{\link{warning}}, \code{\link{stop}}, and
#' \code{\link{signalCondition}}.
#'
#' @export
use_logging <- function()
{
  # message uses signalCondition and is hooked indirectly.
  hooks <- c("warning", "stop", "signalCondition")
  success <- vapply(hooks, set_loggr_hook, logical(1))
  if (!all(success))
    stop("Failed to setup loggr hooks.", call. = FALSE)

  invisible()
}
