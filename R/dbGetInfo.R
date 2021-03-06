#' Get metadata about a database object.
#' 
#' @param dbObj,obj,res An object of class \code{\linkS4class{SQLiteDriver}},
#'   \code{\linkS4class{SQLiteConnection}} or 
#'   \code{\linkS4class{SQLiteResult}}
#' @param what character vector. If supplied used to subset output.
#' @param ... Ignored. Included for compatibility with generic.
#' @name dbGetInfo
NULL

#' @rdname dbGetInfo
#' @export
setMethod("dbGetInfo", "SQLiteDriver",
  definition = function(dbObj, ...) sqliteDriverInfo(dbObj, ...),
  valueClass = "list"
)
#' @rdname dbGetInfo
#' @export
sqliteDriverInfo <- function(obj, what="", ...) {
  if(!isIdCurrent(obj))
    stop(paste("expired", class(obj)))
  drvId <- obj@Id
  info <- .Call("RS_SQLite_managerInfo", drvId, PACKAGE = .SQLitePkgName)
  info$managerId <- obj
  ## connection IDs are no longer tracked by the manager.
  info$connectionIds <- list()
  if(!missing(what))
    info[what]
  else
    info
}

#' @rdname dbGetInfo
#' @export
setMethod("dbGetInfo", "SQLiteConnection",
  definition = function(dbObj, ...) sqliteConnectionInfo(dbObj, ...),
  valueClass = "list"
)
#' @rdname dbGetInfo
#' @export
sqliteConnectionInfo <- function(obj, what="", ...) {
  if(!isIdCurrent(obj))
    stop(paste("expired", class(obj)))
  id <- obj@Id
  info <- .Call("RSQLite_connectionInfo", id, PACKAGE = .SQLitePkgName)
  if(length(info$rsId)){
    rsId <- vector("list", length = length(info$rsId))
    for(i in seq(along.with = info$rsId))
      rsId[[i]] <- new("SQLiteResult",
        Id = .Call("DBI_newResultHandle",
          id, info$rsId[i], PACKAGE = .SQLitePkgName))
    info$rsId <- rsId
  }
  if(!missing(what))
    info[what]
  else
    info
}

#' @rdname dbGetInfo
#' @export
setMethod("dbGetInfo", "SQLiteResult",
  definition = function(dbObj, ...) sqliteResultInfo(dbObj, ...),
  valueClass = "list"
)
#' @rdname dbGetInfo
#' @export
setMethod("dbGetStatement", "SQLiteResult",
  definition = function(res, ...) dbGetInfo(res, "statement")[[1]],
  valueClass = "character"
)
