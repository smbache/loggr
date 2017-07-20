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

  # In R 3.4.x body throws a warning if fun == NULL. Avoid this
  # by checking if input is NULL before body evaluates result.
  type_handlers_helper <- function(x){
    if(is.null(x)){
      NULL
    } else {
      body(x)
    }
  }

  bodies <-
    lapply(type_handlers, type_handlers_helper)

  muffles <-
    lapply(bodies, identical, y = muffle)

  any(vapply(muffles, isTRUE, logical(1)))
}
