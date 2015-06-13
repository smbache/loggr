#' Activate logging by loggr
#'
#' This function hooks up \code{loggr}s handler which is activated by calls
#' to \code{\link{message}}, \code{\link{warning}}, \code{\link{stop}}, and
#' \code{\link{signalCondition}}.
#'
#' @export
use_logging <- function()
{
  # message uses signalCondition and are hooked indirectly.
  #
  # re-tracing here is fine as it replaces the original trace (so no
  # effect).
  catch_signal  <- catch_signal_expr()
  catch_stop    <- catch_stop_expr()
  catch_warning <- catch_warning_expr()

  suppressMessages({
    trace("stop",            catch_stop,    print = FALSE, where = baseenv())
    trace("warning",         catch_warning, print = FALSE, where = baseenv())
    trace("signalCondition", catch_signal,  print = FALSE, where = baseenv())
  })

  invisible()
}
