# loggr - Logging for R

NB: The loggr package is currently experimental!

# installation: 
```R
devtools::install_github("smbache/loggr")
```

# usage:
In your R script/program, activate logging by specifying a log file:
```R
log_file("path/to/logfile.log")
```

Then, whenever a log event (by default, `simpleMessage`s, `simpleWarning`s,
and `simpleError`s are considered log events) is signalled, it will be logged
to the specified file, until the handler is removed (this happens when an
error is raised, either `simpleError`, or a `CRITICAL` log event).

To signal a log event, use one of the following
```R
log_debug(message)     # DEBUG
log_info(message)      # INFO
log_warn(message)      # WARN
log_error(message)     # ERROR  (will not break code execution)
log_critical(message)  # CRITICAL   (breaks code execution)
```

# Specifying which events to log
It is possible to log only certain events when they are raised when specifying
the log file:
```R
log_file("/path/to/file.log", WARN, .message = FALSE, .error = FALSE)
```
This will only listen for `WARN` events, and has disabled the classic conditions
`simpleError` and `simpleMessage`, which are logged by default.

# Formatting the log entries.
By default, the entries are formatted as e.g. 
```R
2015-04-12 15:10:44.601 - WARN - Something bad happened. 
```
You can change the formatter by specifying it for the log file:
```R
log_file("/path/to/file.log", .formatter = my_formatter)
```
Where `my_formatter` should accept a `log_event` as argument, and
return a character representation.

# How it works
`loggr` builds on R's existing condition system, and the log functions 
signal special conditions. If a log file is setup (and condition handlers are
activated) then the events are logged. The log functions can therefore be
used regardless of whether a log file is specified or not.
