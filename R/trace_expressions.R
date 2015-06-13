#' Generate Trace Expression for Simple Warnings
#'
#' @return An unevalueated expression for trace which will call notify_loggr.
#'
#' @noRd
catch_warning_expr <- function()
{
  substitute(f(...,
               call.      = call.,
               immediate. = immediate.,
               noBreaks.  = noBreaks.,
               domain     = domain,
               type       = "warning",
               muffled    = m(sys.frames(), "warning")),
             list(f = call(":::", quote(loggr), quote(notify_loggr)),
                  m = call(":::", quote(loggr), quote(muffled))))
}

#' Generate Trace Expression for Simple Errors
#'
#' @return An unevalueated expression for trace which will call notify_loggr.
#'
#' @noRd
catch_stop_expr <- function()
{
  substitute(f(...,
               call.  = call.,
               domain = domain,
               type   = "error"),
             list(f = call(":::", quote(loggr), quote(notify_loggr))))
}

#' Generate Trace Expression for Signals
#'
#' @return An unevalueated expression for trace which will call notify_loggr.
#'
#' @noRd
catch_signal_expr <- function()
{
  substitute(f(cond,
               type    = if(inherits(cond, "message")) "message" else "other",
               muffled = if(inherits(cond, "message")) m(sys.frames(), "message")
                         else FALSE),
             list(f = call(":::", quote(loggr), quote(notify_loggr)),
                  m = call(":::", quote(loggr), quote(muffled))))
}
