# loggr - Logging for R

The aim of `loggr` is to provide a simple mechanism for logging events in `R`,
without the need to wrap expressions in e.g. `withCallingHandlers` or similar 
and while keeping the possibility of having several active log outputs (files
and/or console) possibly listening for different events.

# Features:
* Multiple log outputs (files, console)
* Capture classic events signalled with `message`, `warning` and `stop`.
* Additional event levels, `DEBUG`, `INFO`, `WARN`, `ERROR`, `CRITICAL`.

# Installation: 
```R
devtools::install_github("smbache/loggr")
```

# Usage:
In your R script/program, activate logging by specifying a log file:
  ```R
log_file("path/to/logfile.log")
```

Then, whenever a log event (by default, `simpleMessage`s, `simpleWarning`s,
and `simpleError`s are considered log events) is signalled, it will be logged
to the specified file.

To listen for log events to show in the console, use of 
```R
logfile("console") # or
logfile("stdout")
```

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

NB: the current enabling/disbling of classic events may be changed to align them
with the other log events.

# Formatting the log entries.
By default, the entries are formatted as e.g. 
```R
2015-04-12 15:10:44.601 - WARN - Something bad happened. 
```
You can change the formatter by specifying it for the log file:
  ```R
log_file("/path/to/file.log", .formatter = my_formatter)
```
Where `my_formatter` should accept a `log_event` object as argument, and
return a character representation.

# How it works
`loggr` adds a hook to `warning`, `stop` and `signalCondition`, so whenever 
these functions are executed, `loggr` will be notified. The event is sent
to any log outputs that subscribe to the type of event.

This means that there is very little code needed in the functions where 
signalling of log events are desired, and the "consumer" only needs to 
specify a `log_file`.

# Bug reports / suggestions
The package is still young and under development,
so if you experience any issues or have suggestions, please file an issue.

