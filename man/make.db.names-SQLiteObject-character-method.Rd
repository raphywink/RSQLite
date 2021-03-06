\docType{methods}
\name{make.db.names,SQLiteObject,character-method}
\alias{SQLKeywords,SQLiteObject-method}
\alias{isSQLKeyword,SQLiteObject,character-method}
\alias{make.db.names,SQLiteObject,character-method}
\title{Make R/S-Plus identifiers into legal SQL identifiers}
\usage{
\S4method{make.db.names}{SQLiteObject,character}(dbObj, snames,
  keywords = .SQL92Keywords, unique = TRUE, allow.keywords = TRUE, ...)

\S4method{SQLKeywords}{SQLiteObject}(dbObj, ...)

\S4method{isSQLKeyword}{SQLiteObject,character}(dbObj, name,
  keywords = .SQL92Keywords, case = c("lower", "upper", "any")[3], ...)
}
\arguments{
  \item{dbObj}{any SQLite object (e.g.,
  \code{SQLiteDriver}).}

  \item{snames}{a character vector of R identifiers
  (symbols) from which to make SQL identifiers.}

  \item{unique}{logical describing whether the resulting
  set of SQL names should be unique.  The default is
  \code{TRUE}. Following the SQL 92 standard, uniqueness of
  SQL identifiers is determined regardless of whether
  letters are upper or lower case.}

  \item{allow.keywords}{logical describing whether SQL
  keywords should be allowed in the resulting set of SQL
  names.  The default is \code{TRUE}.}

  \item{...}{Not used. Included for compatiblity with
  generic.}

  \item{name}{a character vector of SQL identifiers we want
  to check against keywords from the DBMS.}

  \item{keywords}{a character vector with SQL keywords,
  namely \code{.SQL92Keywords} defined in the \code{DBI}
  package.}

  \item{case}{a character string specifying whether to make
  the comparison as lower case, upper case, or any of the
  two.  it defaults to \code{"any"}.}
}
\description{
These methods are straight-forward implementations of the
corresponding generic functions.
}
\examples{
\dontrun{
# This example shows how we could export a bunch of data.frames
# into tables on a remote database.

con <- dbConnect("SQLite", dbname = "sqlite.db")

export <- c("trantime.email", "trantime.print", "round.trip.time.email")
tabs <- make.db.names(con, export, unique = TRUE, allow.keywords = TRUE)

for(i in seq_along(export) )
   dbWriteTable(con, name = tabs[i],  get(export[i]))
}
}

