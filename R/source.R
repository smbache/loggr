#' Read R Code from a File or a Connection
#'
#' This wrapper around \code{\link[base]{source}} allows \code{loggr} to hook
#' up the log condition handler when files are sourced. Once the handler is
#' set up, control is handed over to \code{\link[base]{source}}.
#'
#' @param file as in \code{base::source}
#' @param local as in \code{base::source}
#' @param echo as in \code{base::source}
#' @param print.eval as in \code{base::source}
#' @param verbose as in \code{base::source}
#' @param prompt.echo as in \code{base::source}
#' @param max.deparse.length as in \code{base::source}
#' @param chdir as in \code{base::source}
#' @param encoding as in \code{base::source}
#' @param continue.echo as in \code{base::source}
#' @param skip.echo as in \code{base::source}
#' @param keep.source as in \code{base::source}
#' @export
source <- function(file,
                   local         = FALSE,
                   echo          = verbose,
                   print.eval    = echo,
                   verbose       = getOption("verbose"),
                   prompt.echo   = getOption("prompt"),
                   max.deparse.length = 150,
                   chdir         = FALSE,
                   encoding      = getOption("encoding"),
                   continue.echo = getOption("continue"),
                   skip.echo     = 0,
                   keep.source   = getOption("keep.source"))
{
  cl <- match.call()
  cl[[1L]] <- eval.parent(call("::", "base", "source"))

  parent <- parent.frame()

  # Make R CMD check ignore the use of .Internal.
  internal <- eval(as.name(".Internal"))

  # Assign the handlers upon exiting this function. Direct
  # call would reset the handlers on exit.

  if (!handler_is_set())
    on.exit({
      internal(.addCondHands("condition", list(condition = log_handler),
                             .GlobalEnv, .GlobalEnv, TRUE))
      eval(cl, parent, parent)
    })

  invisible()
}
