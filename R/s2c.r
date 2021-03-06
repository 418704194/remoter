#' Server-to-Client Object Transfer
#' 
#' Localize R objects.
#' 
#' @description
#' This function allows you to pass an object from the server to
#' the local R session behind the client.
#' 
#' @details
#' A \code{newname}, if specified, must be passed as a string
#' (not a literal; i.e., \code{"mynewname"}, not \code{mynewname}).
#' The name must also be syntactically valid (see \code{?make.names}).
#' 
#' @param object 
#' A remote R object.
#' @param newname
#' The name the object should take when it is stored on the local
#' client's R session. Must be the form of a character string.
#' If left blank, the local name will be the same as the original
#' (remote) object's name.
#' @param env
#' The environment into which the assignment will take place. The
#' default is the global environment.
#' 
#' @return
#' Returns \code{TRUE} invisibly on successful exit.
#' 
#' @examples
#' \dontrun{
#' ### Prompts are listed to clarify when something is eval'd locally vs remotely
#' > library(remoter)
#' > y
#' ###  Error: object 'y' not found
#' > remoter::connect("my.remote.server")
#' remoter> x
#' ### Error: object 'x' not found
#' remoter> x <- "some data"
#' remoter> x
#' ###  [1] "some data" 
#' remoter> s2c(x, "y")
#' remoter> q()
#' > y
#' ###  [1] "some data"
#' }
#' 
#' @export
s2c <- function(object, newname, env=.GlobalEnv)
{
  if (missing(object))
  {
    if (iam("local"))
      remoter_client_stop("must pass an object")
    
    return(invisible())
  }
  
  test <- tryCatch(is.environment(env), error=identity)
  if (isFALSE(test) || inherits(test, "error"))
  {
    if (iam("local"))
    {
      if (isFALSE(test))
        remoter_client_stop("invalid environment")
      else
        remoter_client_stop(gsub(test, pattern="(.*: |\\n)", replacement=""))
    }
    
    return(invisible())
  }
  
  if (!missing(newname))
  {
    # test if 'newname' is a string or literal
    test <- try(is.character(newname), silent=TRUE)
    if (inherits(test, "try-error") || !test || !identical(make.names(newname), newname))
    {
      if (iam("local"))
        remoter_client_stop("invalid 'newname'")
      
      return(invisible())
    }
  }
  
  
  name <- as.character(substitute(object))
  err <- ".__remoter_s2c_failure"
  
  if (iam("local"))
  {
    value <- remoter_receive()
    
    if (identical(value, err))
    {
      cat(paste0("Error: object '", name, "' not found on the server\n"))
      return(invisible(FALSE))
    }
    
    if (!missing(newname))
      name <- newname
    
    assign(x=name, value=value, envir=env)
  }
  else if (iam("remote"))
  {
    val <- get0(name, envir=sys.frame(-1), ifnotfound=err)
    remoter_send(data=val, send.more=TRUE)
  }
  
  return(invisible(TRUE))
}
