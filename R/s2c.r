#' Server-to-Client Object Transfer
#' 
#' Localize R objects.
#' 
#' @description
#' This function allows you to pass an object from the server to
#' the local R session behind the client.
#' 
#' @param object 
#' A remote R object.
#' @param newname
#' The name the object should take when it becomes local. If left blank,
#' the local name will have the original (remote) object's name.
#' @param env
#' The environment into which the assignment will take place. The
#' default is the global environment.
#' 
#' @examples
#' \dontrun{
#' ### Prompts are listed to clarify when something is eval'd locally vs remotely
#' > library(remoter)
#' > y
#' ###  Error: object 'y' not found
#' > remoter::connect("my.remote.server")
#' remoteR> x
#' ### Error: object 'x' not found
#' remoteR> x <- "some data"
#' remoteR> x
#' ###  [1] "some data" 
#' remoteR> s2c(x, "y")
#' remoteR> q()
#' > y
#' ###  [1] "some data"
#' }
#' 
#' @export
s2c <- function(object, newname, env=.GlobalEnv)
{
  err <- ".__remoter_s2c_failure"
  name <- as.character(substitute(object))
  
  if (pbdenv$whoami == "local")
  {
    value <- receive.socket(pbdenv$socket)
    
    if (value == err)
    {
      cat(paste0("Error: object '", name, "' not found on the server\n"))
      return(invisible(FALSE))
    }
    
    if (!missing(newname))
      name <- newname
    
    assign(x=name, value=value, envir=env)
    
    ret <- TRUE
  }
  else if (pbdenv$whoami == "remote")
  {
    val <- get0(name, envir=sys.frame(-1), ifnotfound=err)
    
    ret <- send.socket(pbdenv$socket, data=val, send.more=TRUE)
  }
  
  return(invisible(TRUE))
}

