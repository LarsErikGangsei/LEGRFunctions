#' @title DLM_Get_W: Construct System matrix Covariance for Dynamic Linear Model (DLM). 
#' @description The function \code{DLM_Get_W} constructs the W matrice. It is (by now) 
#' possible to include a multivariate response (dimention q), with matern covariance together 
#'  with common trend and common seasonality modeled as harmonic waves. 
#' @details ...
#' @param q [\code{numeric}]. The number/ length of the multivariate response.
#' @param matern [\code{logical}]. If covariance between multivariate should modelled as matern Covariances
#' @param dist [\code{matrix}]. Either a distance matrix [q x q] between the q multivariate levels, 
#' or a data frame/ matrix with two columns giving longnitude (first column), and latitude (second column).
#' @param kappa [\code{numeric}] Range parameter passed directly to \code{rSPDE::matern.covariance()}.
#' @param nu [\code{numeric}] Range parameter passed directly to \code{rSPDE::matern.covariance()}.
#' @param sigma [\code{numeric}] Range parameter passed directly to \code{rSPDE::matern.covariance()}.
#' @param sigma_d2 [\code{numeric}] Scaling variance parameter for the "matern block"
#' @param sigma_t2 [\code{numeric}] Scaling variance parameter for the "trend/ season block"
#' @param trend [\code{logical}]. Set till "TRUE" if (one common) trend is to be included.
#' @param harmonic [\code{logical}]. Set till "TRUE" if (one common) seasonal effect is yto be included.
#' @param n_waves [\code{numeric}]. The number of harmonic waves.
#' @param regions [\code{factor}]. Vector giving different regions. Ignored if set to \code{NULL}
#' @return A block diagonal matrix whose upper left element has dimension [q x q], 
#' with structure \eqn{sigma_d^2} \eqn{C[nu](d)}, where \eqn{C[nu](d)} is the matern 
#' Covariance function and \eqn{sigma_d^2} is a positive scalar. The lower right
#' element is equal to  \eqn{sigma_t^2 I[trend == TRUE + 2 x n_waves]}. 
#'
#' @author Lars Erik Gangsei\cr
#' lars.erik.gangsei@@vetinst.no\cr
#' +47 950 61 231
#' 
#' @import Matrix
#' @import rSPDE
#' @import sp
#' 
#' @examples
#' \dontrun{
#'
#' }
#'
#'
#' @export
DLM_Get_W <- function(q=1,matern = FALSE,dist = NULL,kappa = 10,nu=1/5,
                    sigma_d2 = 1, sigma_t2=1,trend = FALSE,harmonic = FALSE,
                    n_waves = 1,regions = FALSE)
  {
  # The first block, if not matern, then Identety(q)
  if(matern == TRUE)
    {
    if((dim(as.matrix(dist))[2]==2)&&(dim(as.matrix(dist))[1]!=dim(as.matrix(dist))[2]))
    {
      dist <- sp::spDists(dist,longlat=TRUE)
    }
    WW <- rSPDE::matern.covariance(dist,kappa = kappa, nu = nu, sigma = sqrt(sigma_d2))
    q <- dim(WW)[1]
  }else{WW <- sigma_d2*diag(q)} 
  
  
  
  # Add trend
  WW <- Matrix::bdiag(WW,sigma_t2*diag(as.numeric(trend)+2*as.numeric(harmonic)*n_waves))
  return(WW)
}
