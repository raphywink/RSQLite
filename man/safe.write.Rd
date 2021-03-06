\name{safe.write}
\alias{safe.write}
\title{Write a data.frame avoiding exceeding memory limits}
\usage{
safe.write(value, file, batch, row.names = TRUE, ..., sep = ",",
  eol = "\\n", quote.string = FALSE)
}
\arguments{
  \item{value}{a data.frame;}

  \item{file}{a file object (connection, file name, etc).}

  \item{batch}{maximum number of rows to write at a time.}

  \item{...,sep,eol,quote.string,row.names}{arguments are
  passed to \code{write.table}.}
}
\value{
\code{NULL}, invisibly.
}
\description{
This function batches calls to \code{write.table} to avoid
exceeding memory limits for very large data.frames.
}
\details{
The function has a while loop invoking
\code{\link{write.table}} for subsets of \code{batch} rows
of \code{value}.  Since this is a helper function for
\code{\link[RMySQL]{mysqlWriteTable}} has hardcoded other
arguments to \code{write.table}.
}
\note{
No error checking whatsoever is done.
}
\examples{
\dontrun{
   ctr.file <- file("dump.sqloader", "w")
   safe.write(big.data, file = ctr.file, batch = 25000)
}
}
\seealso{
\code{\link{write.table}}
}

