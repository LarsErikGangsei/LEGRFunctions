#' @title ContrastSplines: Returns Spline matrix for full rank design matrix. 
#' @description The function \code{ContrastSplines}  returns a matrix with spline base 
#' similar to "contr.sum", i.e. spline regression parameters sum to zewro. I.e. 
#' the sums of rows in the input does not all sum to one. 
#' @details ...
#' @param SB [\code{numeric}] raw (Spline) base. Matrix whose rows all sum to one
#'
#'
#' @author Lars Erik Gangsei\cr
#' lars.erik.gangsei@@vetinst.no\cr
#' +47 950 61 231
#' 
#' 
#' @examples
#' \dontrun{
#'
#' # Might come
#' 
#' }
#'
#'
#' @export
ContrastSplines <- function(SB) 
{
  nn <- dim(SB)[1]
  mm <- dim(SB)[2]
  SB <- SB - SB[,mm]*matrix(1,nn,mm)
  SB <- SB[,-mm]
  return(SB)
}


