## Parses the default log format.
parse_log <- function(x) {
  re <- "^(.*) - ([A-Z]+) - (.*)$"
  if (!all(grepl(re, x))) {
    stop("Malformed log")
  }
  cbind(time=sub(re, "\\1", x),
        level=sub(re, "\\2", x),
        message=sub(re, "\\3", x))
}

## Generates a random string to test that logging worked as expected
random_string <- function(n=30) {
  paste(sample(c(LETTERS, letters, 0:9), n, replace=TRUE), collapse="")
}

last_msg <- function(filename) {
  dat <- readLines(filename)
  drop(parse_log(dat[length(dat)]))
}
