#' @title DLM_Get_GF: Construct System matrix (G) and Design matrix (F) DGLM for Dynamic Linear Model (DLM). 
#' @description The function \code{DLM_Get_G} constructs the G and F matrices. It is (by now) 
#' possible to include a multivariate response with common trend and common seasonality 
#' modeled as harmonic waves.
#' @details ...
#' @param q [\code{numeric}]. The number/ length of the multivariate response.
#' @param trend [\code{logical}]. Set till "TRUE" if (one common) trend is to be included.
#' @param harmonic [\code{logical}]. Set till "TRUE" if (one common) seasonal effect is yto be included.
#' @param period [\code{numeric}]. Time period for the harmonic wave, I.e. the number of 
#' time units in one full cycle.
#' @param freq [\code{numeric}]. The number of peaks within each time period.
#' @param n_waves [\code{numeric}]. The number of harmonic waves.
#' @return A System matrix G with dimension [q + trend == TRUE + 2 x n_waves] x [q + trend == TRUE + 2 x n_waves]
#' and a design matrix F with dimension [q + trend == TRUE + 2 x n_waves] x q 
#'
#' @author Lars Erik Gangsei\cr
#' lars.erik.gangsei@@vetinst.no\cr
#' +47 950 61 231
#' 
#' @import Matrix
#' 
#' @examples
#' \dontrun{
#'
#' }
#'
#'
#' @export
DLM_Get_GF <- function(q=1,trend = FALSE,harmonic = FALSE,period = 365,
                      freq = 1,n_waves = 1)
  {
  # The first block, Identity for the number of levels
  GG <- diag(qq)
  FF <- diag(qq)
  
  # Add trend
  if(trend == TRUE)
  {GG <- cbind(rbind(GG,0),1)
  FF <- rbind(FF,0)}
  
  # Add harmonic waves
  if(harmonic == TRUE)
  {
    period_adj <- period*freq
    for(pp in 1:n_waves)
    {
        omega_adj <- pp*2*pi/period_adj
        GG <- Matrix::bdiag(GG,matrix(c(cos(omega_adj),-sin(omega_adj),
                                        sin(omega_adj),cos(omega_adj)),
                                        byrow=FALSE,2,2))
        FF <- rbind(rbind(FF,1),0)
    }  
    }
  
  
  return(list(GG==GG,FF = FF))
}
