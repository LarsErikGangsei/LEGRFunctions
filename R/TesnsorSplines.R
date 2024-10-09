#' @title TensorSplines: Returns Spline matrix for for a 3D tensor product. 
#' @description The function \code{TensorSplines} returns a (sparse) matrix 
#' with tensor product for B-splines in 3 dimensions. 
#' @details ...
#' @param XYZ [\code{numeric matrix}] with 3 columns.
#' @param df [\code{integer}] vector with 3 elements.Passed to 
#' \code{splines2::bSpline()}, where first element is passed to first column of 
#' \code{XYZ} etc. Not used if \code{knots !=NULL}.
#' @param knots [\code{list}], with three elements. Each element passed to 
#' \code{splines2::bSpline()}, first element to first column of \code{XYZ} etc.
#' The elements of \code{knots} are numeric vectors. The first and last element
#' are used as argument \code{Boundary.knots} and the remaing elements as argument 
#' \code{knots} in \code{splines2::bSpline()} 
#' @param degree [\code{integer}] passed directly to \code{splines2::bSpline()}
#' @param intercept [\code{logical}] passed directly to \code{splines2::bSpline()}
#' @param sparce [\code{logical}] set til \code{TRUE} if a sparce matrix is to be returned.
#' @param dimnames [code{character}] naming of the 'X', 'Y' and 'Z' variable
#' 
#' @return A (possibly) sparce matrix returning the outer product defined by input, 
#' and evaluation of B(asic) splines as defined either by the knot sequenses and 
#' df (degrees of freedom).
#' 
#'
#' @author Lars Erik Gangsei\cr
#' lars.erik.gangsei@@vetinst.no\cr
#' +47 950 61 231
#' 
#' @import splines
#' @import Matrix
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
TensorSplines <- function(XYZ,df = c(5,5,5),knots = NULL,degree = 3,
                          intercept = TRUE,sparce = FALSE,
                          dimnames = c('X','Y','Z')) 
{
  if(is.null(knots))
  {
    if(sum(df>0,na.rm=TRUE)!=3){stop('"knots" or "df" have to be defined correctly')}
    BX <- bSpline(XYZ[,1],df = df[1],degree = degree,intercept = intercept)
    BY <- bSpline(XYZ[,2],df = df[2],degree = degree,intercept = intercept)
    BZ <- bSpline(XYZ[,3],df = df[3],degree = degree,intercept = intercept)
  }else{
    BX <- bSpline(XYZ[,1],knots = knots[[1]][2:(length(knots[[1]])-1)],
                  Boundary.knots = knots[[1]][c(1,length(knots[[1]]))],
                  intercept = intercept)
    BY <- bSpline(XYZ[,2],knots = knots[[2]][2:(length(knots[[2]])-1)],
                  Boundary.knots = knots[[2]][c(1,length(knots[[2]]))],
                  intercept = intercept)
    BZ <- bSpline(XYZ[,3],knots = knots[[3]][2:(length(knots[[3]])-1)],
                  Boundary.knots = knots[[3]][c(1,length(knots[[3]]))],
                  intercept = intercept)

  }
  
  attributes(BX) <-attributes(BX)["dim"]
  attributes(BY) <-attributes(BY)["dim"]
  attributes(BZ) <-attributes(BZ)["dim"]
  
  if(sparce == TRUE)
  {BX <- as(BX, "sparseMatrix")
  BY <- as(BY, "sparseMatrix")
  BZ <- as(BZ, "sparseMatrix")}
  
  colnames(BX) <- paste(dimnames[1],1:dim(BX)[2],sep = '')
  colnames(BY) <- paste(dimnames[2],1:dim(BY)[2],sep = '')
  colnames(BZ) <- paste(dimnames[3],1:dim(BZ)[2],sep = '')
  
  
  # Make the outer products.
  nn <- dim(XYZ)[1]
  BXYZ <- t(mapply(kronecker,split(BX,f = 1:nn),split(BY,f = 1:nn),
                 MoreArgs = list(make.dimnames = TRUE)))
  
  BXYZ <- t(mapply(kronecker,split(BXYZ,f = 1:nn),split(BZ,f = 1:nn),
                   MoreArgs = list(make.dimnames = TRUE)))
  
  #BXYZ <- kronecker(kronecker(BX, BY,make.dimnames = TRUE), 
  #                 BZ,make.dimnames = TRUE)
  
  colnames(BXYZ) <- apply(expand.grid(colnames(BZ),colnames(BY),
                      colnames(BX))[,c(3,2,1)],1,paste,collapse = '-')
  
  # If "sparce ==TRUE", return as sparce matrix
  if(sparce == TRUE)
  {BXYZ <- as(BXYZ, "sparseMatrix")}
 
  return(BXYZ) 
}


