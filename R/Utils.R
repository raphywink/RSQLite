#' Return an entire column from a SQLite database
#' 
#' Return an entire column from a table in a SQLite database as an R vector of
#' the appropriate type.  This function is experimental and subject to change.
#' 
#' This function relies upon the SQLite internal \code{ROWID} column to
#' determine the number of rows in the table.  This may not work depending on
#' the table schema definition and pattern of update.
#' 
#' @param con a \code{SQLiteConnection} object as produced by
#' \code{sqliteNewConnection}.
#' @param table a string specifying the name of the table
#' @param column a string specifying the name of the column in the specified
#' table to retrieve.
#' @return an R vector of the appropriate type (based on the type of the column
#' in the database).
#' @author Seth Falcon
#' @keywords interface
#' @export sqliteQuickColumn
sqliteQuickColumn <- function(con, table, column) {
  .Call("RS_SQLite_quick_column", con@Id, as.character(table),
    as.character(column), PACKAGE="RSQLite")
}

sqliteFetchOneColumn <- function(con, statement, n=0, ...) {
  rs <- dbSendQuery(con, statement)
  on.exit(dbClearResult(rs))
  n <- as.integer(n)
  rsId <- rs@Id
  rel <- .Call("RS_SQLite_fetch", rsId, nrec = n, PACKAGE = .SQLitePkgName)
  if (length(rel) == 0 || length(rel[[1]]) == 0)
    return(NULL)
  rel[[1]]
}

sqliteResultInfo <- function(obj, what = "", ...) {
  if(!isIdCurrent(obj))
    stop(paste("expired", class(obj)))
  id <- obj@Id
  info <- .Call("RS_SQLite_resultSetInfo", id, PACKAGE = .SQLitePkgName)
  flds <- info$fieldDescription[[1]]
  if(!is.null(flds)){
    flds$Sclass <- .Call("RS_DBI_SclassNames", flds$Sclass,
      PACKAGE = .SQLitePkgName)
    flds$type <- .Call("RS_SQLite_typeNames", flds$type,
      PACKAGE = .SQLitePkgName)
    ## no factors
    info$fields <- structure(flds, row.names = paste(seq(along.with=flds$type)),
      class="data.frame")
  }
  if(!missing(what))
    info[what]
  else
    info
}

## from ROracle, except we don't quote strings here.
## safe.write makes sure write.table don't exceed available memory by batching
## at most batch rows (but it is still slowww)


#' Write a data.frame avoiding exceeding memory limits
#' 
#' This function batches calls to \code{write.table} to avoid exceeding memory
#' limits for very large data.frames.
#' 
#' The function has a while loop invoking \code{\link{write.table}} for subsets
#' of \code{batch} rows of \code{value}.  Since this is a helper function for
#' \code{\link[RMySQL]{mysqlWriteTable}} has hardcoded other arguments to
#' \code{write.table}.
#' 
#' @param value a data.frame;
#' @param file a file object (connection, file name, etc).
#' @param batch maximum number of rows to write at a time.
#' @param ...,sep,eol,quote.string,row.names 
#'   arguments are passed to \code{write.table}.
#' @return \code{NULL}, invisibly.
#' @note No error checking whatsoever is done.
#' @seealso \code{\link{write.table}}
#' @examples
#' \dontrun{
#'    ctr.file <- file("dump.sqloader", "w")
#'    safe.write(big.data, file = ctr.file, batch = 25000)
#' }
#' @export
safe.write <- function(value, file, batch, row.names = TRUE, ..., sep = ',',
  eol = '\n', quote.string = FALSE) {
  N <- nrow(value)
  if(N<1){
    warning("no rows in data.frame")
    return(NULL)
  }
  if(missing(batch) || is.null(batch))
    batch <- 10000
  else if(batch<=0)
    batch <- N
  from <- 1
  to <- min(batch, N)
  while(from<=N){
    write.table(value[from:to,, drop=FALSE], file = file,
      append = from>1,
      quote = quote.string, sep=sep, na = .SQLite.NA.string,
      row.names=row.names, col.names=(from==1), eol = eol, ...)
    from <- to+1
    to <- min(to+batch, N)
  }
  invisible(NULL)
}



#' Copy a SQLite database
#' 
#' This function copies a database connection to a file or to another database
#' connection.  It can be used to save an in-memory database (created using
#' \code{dbname = ":memory:"}) to a file or to create an in-memory database as
#' a copy of anothe database.
#' 
#' This function uses SQLite's experimental online backup API to make the copy.
#' 
#' @param from A \code{SQLiteConnection} object.  The main database in
#' \code{from} will be copied to \code{to}.
#' @param to Either a string specifying the file name where the copy will be
#' written or a \code{SQLiteConnection} object pointing to an empty database.
#' If \code{to} specifies an already existing file, it will be overwritten
#' without a warning.  When \code{to} is a database connection, it is assumed
#' to point to an empty and unused database; the behavior is undefined
#' otherwise.
#' @return Returns \code{NULL}.
#' @author Seth Falcon
#' @references \url{http://www.sqlite.org/backup.html}
#' @examples
#' 
#' ## Create an in memory database
#' db <- dbConnect(SQLite(), dbname = ":memory:")
#' df <- data.frame(letters=letters[1:4], numbers=1:4, stringsAsFactors = FALSE)
#' ok <- dbWriteTable(db, "table1", df, row.names = FALSE)
#' stopifnot(ok)
#' 
#' ## Copy the contents of the in memory database to
#' ## the specified file
#' backupDbFile <- tempfile()
#' sqliteCopyDatabase(db, backupDbFile)
#' diskdb <- dbConnect(SQLite(), dbname = backupDbFile)
#' stopifnot(identical(df, dbReadTable(diskdb, "table1")))
#' 
#' ## Copy from one connection to another
#' db2 <- dbConnect(SQLite(), dbname = ":memory:")
#' sqliteCopyDatabase(db, db2)
#' stopifnot(identical(df, dbReadTable(db2, "table1")))
#' 
#' ## cleanup
#' dbDisconnect(db)
#' dbDisconnect(diskdb)
#' dbDisconnect(db2)
#' unlink(backupDbFile)
#' 
#' @export sqliteCopyDatabase
sqliteCopyDatabase <- function(from, to) {
  if (!is(from, "SQLiteConnection"))
    stop("'from' must be a SQLiteConnection object")
  destdb <- to
  if (!is(to, "SQLiteConnection")) {
    if (is.character(to) && length(to) == 1L && !is.na(to) && nzchar(to)) {
      if (":memory:" == to)
        stop("invalid file name for 'to'.  Use a SQLiteConnection",
          " object to copy to an in-memory database")
      destdb <- dbConnect(SQLite(), dbname = path.expand(to))
      on.exit(dbDisconnect(destdb))
    } else {
      stop("'to' must be SQLiteConnection object or a non-empty string")
    }
  }
  .Call("RS_SQLite_copy_database", from@Id, destdb@Id, PACKAGE = .SQLitePkgName)
  invisible(NULL)
}
