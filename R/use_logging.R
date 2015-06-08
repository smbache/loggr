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
  #
  # re-tracing here is fine as it replaces the original trace (so no
  # effect).
  #
  # NOTE: using quote() here triggers a false-positive NOTE in R CMD
  # check about use of ':::' to refer to a package variable.
  catch_signal  <- parse(text="loggr:::notify_loggr(cond)")
  catch_stop    <- parse(text="loggr:::notify_loggr(..., call.=call., domain=domain, type=\"error\")")
  catch_warning <- parse(text="loggr:::notify_loggr(..., call.=call., immediate.=immediate., noBreaks.=noBreaks., domain=domain, type=\"warning\")")

  suppressMessages({
    trace(base::signalCondition, catch_signal,  print=FALSE)
    trace(base::stop,            catch_stop,    print=FALSE)
    trace(base::warning,         catch_warning, print=FALSE)
  })

  invisible()
}
