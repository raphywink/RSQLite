\docType{methods}
\name{transactions}
\alias{dbBeginTransaction,SQLiteConnection-method}
\alias{dbCommit,SQLiteConnection-method}
\alias{dbRollback,SQLiteConnection-method}
\alias{sqliteTransactionStatement}
\alias{transactions}
\title{SQLite transaction management.}
\usage{
\S4method{dbCommit}{SQLiteConnection}(conn, ...)

\S4method{dbRollback}{SQLiteConnection}(conn, ...)

\S4method{dbBeginTransaction}{SQLiteConnection}(conn, ...)

sqliteTransactionStatement(con, statement)
}
\arguments{
  \item{conn,con}{a \code{\linkS4class{SQLiteConnection}}
  object, produced by \code{\link[DBI]{dbConnect}}}

  \item{...}{Ignored. Needed for compatibility with
  generic.}

  \item{statement}{SQL transaction statement to execute}
}
\description{
By default, SQLite is in auto-commit mode.
\code{dbBeginTransaction} starts a SQLite transaction and
turns auto-commit off. \code{dbCommit} and
\code{dbRollback} commit and rollback the transaction,
respectively and turn auto-commit on.
}
\examples{
con <- dbConnect(SQLite(), dbname = tempfile())
data(USArrests)
dbWriteTable(con, "arrests", USArrests)
dbGetQuery(con, "select count(*) from arrests")[1, ]

dbBeginTransaction(con)
rs <- dbSendQuery(con, "DELETE from arrests WHERE Murder > 1")
do_commit <- if (dbGetInfo(rs)[["rowsAffected"]] > 40) FALSE else TRUE
dbClearResult(rs)
dbGetQuery(con, "select count(*) from arrests")[1, ]
if (!do_commit) dbRollback(con)
dbGetQuery(con, "select count(*) from arrests")[1, ]

dbBeginTransaction(con)
rs <- dbSendQuery(con, "DELETE FROM arrests WHERE Murder > 5")
dbClearResult(rs)
dbCommit(con)
dbGetQuery(con, "SELECT count(*) FROM arrests")[1, ]

dbDisconnect(con)
}

