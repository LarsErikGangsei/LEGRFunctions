#' @title DLM_Get_GF: Construct System matrix (G) and Design matrix (F) DGLM for Dynamic Linear Model (DLM). 
#' @description The function \code{DLM_Get_G} constructs the G and F matrices. It is (by now) 
#' possible to include a multivariate response with common trend and common seasonality 
#' modeled as harmonic waves.
#' @details ...
#' @param q [\code{numeric}]. The number/ length of the multivariate response.
#' @param trend [\code{logical}]. Set till "TRUE" if (one common) trend is to be included.
#' @param harmonic [\code{logical}]. Set till "TRUE" if (one common) seasonal 
#' effect is to be included.
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
DLM_matrices_construct <- function(modform = formula(.~ trend + harmonic + 
                                                       factors + matern), 
                                   sigmas = list(main = 1,
                                                 trend = 10^-3,
                                                 harmonic = 10^-3,
                                                 factors = NULL,
                                                 matern = list(kappa = 10,
                                                               nu = 1/5),
                                                 sigma_v = 1),
                                   data = list(p = 1,
                                               factors = NULL,
                                               harmonic = c(2*pi/365,2*2*pi/365),
                                               matern = NULL))
  {
  # Find the terms in the formula
  modterms <- as.character(attributes(terms(modform))$variables)
  
  # Check if trend, harmonic, factors should be included
  if(!any(is.element(c("trend","harmonic","factors","matern"),modterms)))
  {
    GG <- FF <- diag(data$p)
    WW <- sigmas$main * diag(data$p)
    VV <-  sigmas$sigma_v * diag(data$p)
  }else{
    if(any(is.element(c("factors","matern"),modterms)))
    {pp <- max(c(dim(data$factors)[1],dim(data$matern)[1]))}else{pp <- data$p}
 
    # Set the first block
    if(is.element("trend",modterms))
    {
      GG <- matrix(c(1,1,0,1),2,2,byrow = TRUE)
      FF <- matrix(c(1,0),2,pp,byrow = FALSE)
      WW <- diag(c(sigmas$main,sigmas$trend))
    }else{
      GG <- as.matrix(1)
      FF <- t(as.matrix(rep(1,pp)))
      WW <- as.matrix(sigmas$main)
    }
    
    # Set the second block, i.e. harmonics
    if(is.element("harmonic",modterms))
    {
      # The number of waves 
      nn_h <- length(data$harmonic)
      for(hh in 1:nn_h)
      {
      GG <- Matrix::bdiag(GG,
                          matrix(
                            c(cos(data$harmonic[hh]),-sin(data$harmonic[hh]),
                              sin(data$harmonic[hh]),cos(data$harmonic[hh])),
                                  byrow=FALSE,2,2))
      }
      WW <- Matrix::bdiag(WW,sigmas$harmonic*diag(2*nn_h))
      FF <- rbind(FF,matrix(rep(c(1,0),nn_h),
                            2*nn_h,pp,byrow = FALSE))
    }
    
    # Set the factors, this code is not to good, so far only for two nested
    # factors. LEG 17.01.2025
    if(is.element("factors",modterms))
    {
      if(dim(data$factors)[2]!=2){stop('Factor element only valid for 
                                       two nested factors')}
        data$factors[,1] <- as.factor(data$factors[,1])
        data$factors[,2] <- as.factor(data$factors[,2])
        nn_f <- sapply(data$factors,nlevels)
        GG <- Matrix::bdiag(GG,diag(nn_f[2]-1))
        WW <- Matrix::bdiag(WW,sigmas$factors[1]*diag(nn_f[1]-1),
                            sigmas$factors[2]*diag(nn_f[2]-nn_f[1]))
        
        FF <- rbind(FF,t(model.matrix(lm(1:pp~data$factors[,1],
                              contrast = list(`data$factors[, 1]` = 'contr.sum'),
                              ))[,-1]))
        lev1 <- levels(data$factors[,1])
        FFb <- t(model.matrix(lm((1:sum(data$factors[,1]==lev1[1]))~
                                   data$factors[data$factors[,1]==lev1[1],2],
                                 contrast = list(`data$factors[data$factors[, 1] == lev1[1], 2]` = 'contr.sum'),
                              ))[,-1])
        for(ii in 2:length(lev1))
        {
          FFb <- Matrix::bdiag(FFb,
                    cbind(diag(sum(data$factors[,1]==lev1[ii])-1),-1))
        }
        FF <- rbind(FF,as.matrix(FFb))
      }
  }
  
  # Set the matern covariance 
  if(is.element("matern",modterms))
    {
    if(is.element("factors",modterms))
    {
      idx_ww <- dim(WW)[1]+seq(-nn_f[2]+nn_f[1]+1,0,by = 1)
      idx_dist <- which(rowSums(as.matrix(FFb)==1)==1)
    }
    else{
      idx_ww <- c(1,(dim(WW)[1]-pp+2):dim(WW)[1])
      idx_dist <- 1:pp
    }
      dist <- sp::spDists(data$matern[idx_dist,],longlat=TRUE)
      WW[idx_ww,idx_ww] <- rSPDE::matern.covariance(dist,kappa = sigmas$matern$kappa, 
                                              nu = sigmas$matern$nu,
                                              sigma = sigmas$factors[2]) 
    }
  
    
    # Set the last block if no factors and no matern
    if(!any(is.element(c("factors","matern"),modterms)))
    {
      GG <- Matrix::bdiag(GG,diag(pp-1))
      FF <- rbind(FF,cbind(rep(0,pp-1),diag(rep(1,pp-1))))
      WW <- Matrix::bdiag(WW,sigmas$main*diag(pp-1))
    }
    
    # Set the error variance, just constant and independent so far. 
  
    VV <-  sigmas$sigma_v * diag(pp)


  
  return(list(GG=as.matrix(GG),FF = as.matrix(FF),WW = as.matrix(WW),VV = VV))
}
