#' Set up a loggr hook
#'
#' This is an internal function used by loggr to set the hooks.
#'
#' @param which character: the function to hook up; one of
#'   "message", "warning", "stop", "signalCondition".
#' @return logical indicating success.
set_loggr_hook <- function(which)
{
  call_notifier <-
    switch(which,
      warning = quote(`_notify_loggr`(..., call. = call., immediate. = immediate.,
                                      noBreaks.  = noBreaks., domain = domain,
                                      type = "warning")),
      stop    = quote(`_notify_loggr`(..., call. = call., domain = domain,
                                      type = "error")),
      signalCondition = quote(`_notify_loggr`(cond)),
      stop("Invalid argument `which`.", call. = FALSE))

  tryCatch({
    # Reference to the environment in which
    base_env <- asNamespace("base")

    # Fetch the relevant function, and hook it up if it hasn't been done
    # already.
    fun <- getFromNamespace(which, base_env)
    if (identical(body(fun)[[2L]][[1L]], quote(`_notify_loggr`))) {
      TRUE
    } else {
      # Prepare for hooking up the notifier
      prepareForHook <- call("unlockBinding", which, base_env)
      eval(prepareForHook)

      # always lock the binding again.
      on.exit(lockBinding(which, base_env))

      environment(fun)[["_notify_loggr"]] <- notify_loggr

      # Add the notifying call
      body(fun) <- call("{", call_notifier, body(fun))

      # Update the function
      assign(which, fun, envir = base_env)

      TRUE
    }
  }, error = function(e) {
    warning(e)
    return(FALSE)
  })
}

unset_loggr_hook <- function(which)
{
  tryCatch({
    base_env <- asNamespace("base")
    fun <- getFromNamespace(which, base_env)
    if (identical(body(fun)[[2L]][[1L]], quote(`_notify_loggr`))) {
      prepareForHook <- call("unlockBinding", which, base_env)
      eval(prepareForHook)

      # always lock the binding again.
      on.exit(lockBinding(which, base_env))

      # NOTE: This is not possible!
      # rm(list="_notify_loggr", envir=environment(fun))

      # Drop the call
      body(fun) <- body(fun)[[3]]

      # Update the function
      assign(which, fun, envir = base_env)
      TRUE
    } else {
      TRUE
    }
  }, error = function(e) {
    warning(e)
    return(FALSE)
  })
}
