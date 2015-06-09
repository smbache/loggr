#' Determine Whether a Warning or Message is Muffled
#'
#' @noRd
#' @param frames the parent frames of the call to \code{warning}.
#' @param type character: either "message" or "warning"
#' @return logical
muffled <- function(frames, type)
{
  if (identical(type, "message")) {
    muffle <- quote(invokeRestart("muffleMessage"))
  } else if (identical(type, "warning")) {
    muffle <- quote(invokeRestart("muffleWarning"))
  } else {
    stop('Type must be either "warning" or "message"')
  }

  handlers <-
    lapply(sys.frames(), `[[`, i = "handlers")

  type_handlers <-
    lapply(handlers, `[[`, i = type)

  bodies <-
    lapply(type_handlers, body)

  muffles <-
    lapply(bodies, identical, y = muffle)

  any(vapply(muffles, isTRUE, logical(1)))
}
