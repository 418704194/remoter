% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/exit.r
\name{exit}
\alias{exit}
\alias{exit}
\alias{shutdown}
\alias{kill}
\title{exit}
\usage{
exit(client.only = TRUE, q.server = TRUE)

shutdown()

kill(addr = "localhost", port = 55555)
}
\arguments{
\item{client.only}{Logical; if \code{TRUE}, then the client disconnects from
the server.  Otherwise, the server is shut down together 
with the client.}

\item{q.server}{Logical; if \code{TRUE}, then the server calls \code{q("no")}
after shuting down with the client.  This is useful for cases
where the server is running in an interactive R session, and you
wish to shut the entire thing down.}

\item{addr, port}{The server address and port, as in \code{server()}.}
}
\value{
Returns \code{TRUE} invisibly on successful exit.
}
\description{
This function cleanly shuts down the remoter server the client
is currently connected to, as well as shutting down the client.
One can also use \code{q()} (while the client is running), and
this will not close the active R session on the client.
}
\details{
Exit the remoter client/server.


The \code{shutdown()} function is shorthand for 
\code{exit(FALSE, TRUE)}.  The \code{kill()} function is shorthand
for running \code{batch()} with \code{script="shutdown()"}.
}
\seealso{
\code{\link{server}} and \code{\link{batch}}
}
