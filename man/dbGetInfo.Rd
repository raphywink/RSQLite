\docType{methods}
\name{dbGetInfo}
\alias{dbGetInfo}
\alias{dbGetInfo,SQLiteConnection-method}
\alias{dbGetInfo,SQLiteDriver-method}
\alias{dbGetInfo,SQLiteResult-method}
\alias{dbGetStatement,SQLiteResult-method}
\alias{sqliteConnectionInfo}
\alias{sqliteDriverInfo}
\title{Get metadata about a database object.}
\usage{
\S4method{dbGetInfo}{SQLiteDriver}(dbObj, ...)

sqliteDriverInfo(obj, what = "", ...)

\S4method{dbGetInfo}{SQLiteConnection}(dbObj, ...)

sqliteConnectionInfo(obj, what = "", ...)

\S4method{dbGetInfo}{SQLiteResult}(dbObj, ...)

\S4method{dbGetStatement}{SQLiteResult}(res, ...)
}
\arguments{
  \item{dbObj,obj,res}{An object of class
  \code{\linkS4class{SQLiteDriver}},
  \code{\linkS4class{SQLiteConnection}} or
  \code{\linkS4class{SQLiteResult}}}

  \item{what}{character vector. If supplied used to subset
  output.}

  \item{...}{Ignored. Included for compatibility with
  generic.}
}
\description{
Get metadata about a database object.
}

