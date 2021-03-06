\docType{methods}
\name{fetch,SQLiteResult-method}
\alias{fetch,SQLiteResult-method}
\alias{sqliteFetch}
\title{Fetch records from a previously executed query}
\usage{
\S4method{fetch}{SQLiteResult}(res, n = 0, ...)

sqliteFetch(res, n = 0, ...)
}
\arguments{
  \item{res}{an \code{\linkS4class{SQLiteResult}} object.}

  \item{n}{maximum number of records to retrieve per fetch.
  Use \code{-1} to retrieve all pending records; use
  \code{0} for to fetch the default number of rows as
  defined in \code{\link{SQLite}}}

  \item{...}{Ignored. Needed for compatibility with
  generic.}
}
\description{
The \code{RSQLite} implementations retrieves all records
into a buffer internally managed by the RSQLite driver
(thus this memory in not managed by R but its part of the R
process), and \code{fetch} simply returns records from this
internal buffer.
}
\examples{
con <- dbConnect(SQLite(), dbname = tempfile())
data(USJudgeRatings)
dbWriteTable(con, "jratings", USJudgeRatings)

res <- dbSendQuery(con, statement = paste(
                      "SELECT row_names, ORAL, DILG, FAMI",
                      "FROM jratings"))

# we now fetch the first 10 records from the resultSet into a data.frame
data1 <- fetch(res, n = 10)
dim(data1)

dbHasCompleted(res)

# let's get all remaining records
data2 <- fetch(res, n = -1)
}

