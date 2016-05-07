## internal function
verifydata <- function(data) {
  if (is.null(data)) stop("missing values (no data supplied)")
  if (!is.wiener(data)) {
    if (!(is.data.frame(data) | is.numeric(data))) 
      stop("supplied data in wrong format")
  }
}

is.wiener <- function(x) {
  res <- (inherits(x, "data.wiener") | inherits(x, "numdata.wiener"))
  return(res)
}

as.wiener <- function(data, yvar=c("q", "resp")) {
  if(is.data.frame(data) & (sum(as.numeric(colnames(data) == yvar))==2) )
  {
    class(data) <- c("data.wiener", "data.frame")
  }
  else if(is.numeric(data) | is.vector(data))
  {
    class(data) <- c("numdata.wiener", "numeric")
  }
  else stop("can only convert vectors (with + / - values for upper/lower bound) or data.frames (with 2 columns: 'q' and 'resp').")
  return(data)
}

## redefine reshape function to be generic
reshape <- function(data, ...) UseMethod("reshape")

## save default reshape method from stats package
reshape.default <- stats::reshape

## wiener reshape methods
reshape.wiener <- function(data, yvar=c("q", "resp"), direction="auto") {
  verifydata(data)

  if(is.data.frame(data) & (direction %in% c("wide", "auto")))
  {
    res <- data[,yvar[1]]
    for (i in 1:(length(data[,1])))
    {
      if(data[i,yvar[2]] == "upper") res[i] <- data[i,yvar[1]]
      else res[i] <- -data[i,yvar[1]]
    }
    class(res) <- c("numdata.wiener", "numeric")
  }
  else if ((is.vector(data) | is.numeric(data)) 
           & (direction %in% c("long", "auto"))) {
    res <- data.frame(as.numeric(abs(data)), factor((data>0), levels=c("TRUE", "FALSE"),
             labels=c("upper", "lower")))
    colnames(res) <- yvar[1:2]
    class(res) <- c("data.wiener", "data.frame")
  }
  else if(("numdata.wiener" %in% class(data) & direction=="wide" )
          | ("data.wiener" %in% class(data) & direction=="long")) {
    res <- data
  }
  else warning("argument(s) not valid")

  return(res)
}

reshape.numdata.wiener <- function(data, yvar=c("q", "resp"),
  direction="long") {
  reshape.wiener(data, yvar=yvar, direction=direction)
}
reshape.data.wiener <- function(data, yvar=c("q", "resp"), direction="wide") {
  reshape.wiener(data, yvar=yvar, direction=direction)
}

print.wdm <- function(x, ...) {
  cat("Call:\n")
  print(x$call)
  cat("\n")
  cat("Parameters:\n")
  print(x$par)
  cat("\n")
  cat("Hessian:\n")
  print(x$hessian)
  cat("\n")
  cat("log-Likelihood: ")
  print(x$loglik)
  cat("Convergence: ")
  print(x$convergence)
}