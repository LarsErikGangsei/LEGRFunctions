#' @title DLM_Multivariate_Normal: DLM for multivariate normal data. 
#' @description The function \code{DGLM_Multivariate_Normal} fits a Dynamic 
#' Linear Model (DLM) to the data input. 
#' @details ...
#' @param Data [\code{data.frame}]. Data frame with three elements:\cr
#' \code{t}: Vector with times/ dates.\cr
#' \code{y}: Matrix, where each row represents the observations for different 
#' levels at associated time step.
#' @param GG [\code{numeric matrix}] System matrix G. Assumed constant for all time elements.
#' @param FF [\code{numeric matrix}] Design matrix F. Assumed constant for all time elements.
#' @param m0 [\code{numeric vector}] Prior mean for (latent) parameter vector \eqn{\theta}.
#' @param C0 [\code{numeric matrix}] Prior variance for (latent) parameter vector \eqn{\theta}.
#' @param W [\code{numeric matrix}] System variance.
#' @param V [\code{numeric matrix}] Error variance.
#' @param delta [\code{numeric scalar}]. Discount factor. Only used if \code{W} is \code{NULL}. 
#' @param smoother_run [\code{logical}]. If the DLM smoother is to be ran
#' @return A list with elements at, Rt,mt,Ct,ft,Qt,pt,etaHat,vHat,Qst
#'
#' @author Lars Erik Gangsei\cr
#' lars.erik.gangsei@@vetinst.no\cr
#' +47 950 61 231
#' 
#' @import dplyr
#' @import mvtnorm
#' 
#' @examples
#' \dontrun{
#'
#' }
#'
#'
#' @export
DLM_Multivariate_Normal <- function(Data,GG,FF,m0, C0, W = NULL,V, delta = 0.75,
                                    smoother_run = FALSE)
  {
  
  Data <- dplyr::arrange(Data,t)
  # m: length of theta (parametervector), n: The number of time steps
  mm <- dim(m0)[1]
  nn <- dim(Data)[1]
  qq <- dim(FF)[2]
  
  # If discount factor is scalar, make it a matrix.
  if(!is.null(delta)){
  if(!is.matrix(delta)){delta <- delta*diag(mm)}
    delta_mat <- diag(mm)+(diag(mm)-as.matrix(delta))%*%solve(as.matrix(delta))
  }
  
  
  # Lists of matrices - initially they are empty, but every time step the new
  # matrices are added
  Res <- list(
    at = matrix(NA,nn,mm),
    Rt = array(NA,dim = c(nn,mm,mm)),
    mt = matrix(NA,nn,mm),
    Ct = array(NA,dim = c(nn,mm,mm)),
    ft = matrix(NA,nn,qq),
    QT = array(NA,dim = c(nn,qq,qq)),
    At = array(NA,dim = c(nn,mm,qq)),
    et = matrix(NA,nn,qq),
    log_like = NULL,
    Qtsmooth = NULL,
    atsmooth = NULL,
    Rtsmooth = NULL,
    log_like <- rep(NA,nn))
  
  oldM <- m0
  oldC <- C0
  
  
  ## Run DGLM
  for (tt in 1:nn) { #n=1
    starttime <- Sys.time()
    
    at <- GG %*% oldM   
    if(!is.null(W))
      {
      Rt <- as.matrix(GG %*%oldC%*%t(GG) + W)
    }else{
      Rt <- as.matrix(GG %*%oldC%*%t(GG)%*%delta_mat)
      }
    
    
    # Save at and Rt
    Res$at[tt,] <- round(as.vector(at),6)
    Res$Rt[tt,,] <- round(Rt,6)
    
    
    yt <- as.matrix(Data$y[tt,])  #observation vector
    
    # Remove observations with no observations of individuals at risk
    idxOK <- which(!is.na(yt))
    
    yt <- as.matrix(yt[idxOK,])
    Ft <- as.matrix(FF[,idxOK])
    qqt <- dim(Ft)[2]
    
    # One step forecast 
    #print(tt)
    ft <- t(Ft)%*%at                                        # Forecast
    Qt <- t(Ft)%*%Rt%*%Ft + V[idxOK,idxOK]                  # Forecast variance
    
    Res$ft[tt,idxOK] <- as.vector(ft)
    Res$QT[tt,idxOK,idxOK] <- Qt
    
    # Posterior for theta at time t
    Qt_inv <- eigen(Qt,symmetric = TRUE)
    Qt_inv$vectors <- Qt_inv$vectors[,Qt_inv$values>10^(-99)]
    Qt_values <- Qt_inv$values[Qt_inv$values>10^(-99)]
    
    Qt_inv <- Qt_inv$vectors%*%diag(1/Qt_values)%*%t(Qt_inv$vectors)
    endtime1 <- Sys.time()
    
    At <- Rt%*%Ft%*%Qt_inv                          # Adaptive coefficient
    et <- matrix(NA,qq,1)
    et[idxOK,] <- as.vector(yt - ft)                # Forecast error
    mt <- at + At%*%et[idxOK,]                      # Filtered (posterior) mean
    
    Res$log_like[tt] <- -(1/2)*(dim(Qt)[1]*log(2*pi)+
                                  sum(log(Qt_values))+
                                  t(et[idxOK,])%*%Qt_inv%*%et[idxOK,])
    
    
    endtime2 <- Sys.time()
    
    Ct <- Rt - At%*%Qt%*%t(At)                      # Filtered (posterior) variance
   
    Res$mt[tt,] <- as.vector(mt)
    Res$Ct[tt,,] <- Ct
    Res$At[tt,,idxOK] <- At
    Res$et[tt,] <- as.vector(et)
    
    oldM <- mt
    oldC <- Ct
    
    endtime3 <- Sys.time()
    #print(starttime-c(endtime1,endtime2,endtime3))
  
  }
  if(smoother_run == TRUE)
  {
   # Res$log_like <- rep(NA,nn)
    Res$Qtsmooth <- array(NA,dim = c(nn,qq,qq))
    Res$Ctsmooth <- array(NA,dim = c(nn,mm,mm))
    Res$Rtsmooth <- array(NA,dim = c(nn,mm,mm))
    Res$mtsmooth <- matrix(NA,nn,mm)
    
    for(tt in seq(nn,1,by = -1))
    {
    
    #print(tt)
      if(tt == nn)
      {
        at <- mt                # Smoothed mean
        Ct <- Ct                # Smoothed system variance 
      }else{
      Rtp1_inv <- eigen(Res$Rt[tt+1,,],symmetric = TRUE)
      Rtp1_inv$vectors <- Rtp1_inv$vectors[,Rtp1_inv$values>10^(-99)]
      Rtp1_inv$values <- Rtp1_inv$values[Rtp1_inv$values>10^(-99)]
      Rtp1_inv <- Rtp1_inv$vectors%*%diag(1/Rtp1_inv$values)%*%t(Rtp1_inv$vectors)
      
      Bt <- Res$Ct[tt,,]%*%t(GG)%*%Rtp1_inv
      Ct <- as.matrix(Res$Ct[tt,,] + Bt%*%(Res$Ctsmooth[tt+1,,] - Res$Rt[tt+1,,])%*%t(Bt)) # Smoothed system variance 
      mt <- Res$mt[tt,] + Bt%*%(Res$mtsmooth[tt+1,] - Res$at[tt+1,])       # Smoothed mean
      }
      Res$Ctsmooth[tt,,] <- Ct
      Res$Rtsmooth[tt,,] <- Rt
      Res$mtsmooth[tt,] <- as.vector(mt)
    
    
      # Calculating log likelihood 
    #  yt <- as.matrix(Data$y[tt,])                      #observation vector
     # idxOK <- which(!is.na(yt))
     # Ft <- as.matrix(FF[,idxOK])
     # qqt <- dim(Ft)[2]
      
     # Qt <- t(Ft)%*%Res$Rt[tt,,]%*%Ft + V[idxOK,idxOK]            # Forecast variance
      #Res$Qtsmooth[tt,idxOK,idxOK] <- Qt
      
    #  Qt_inv <- eigen(Qt,symmetric = TRUE)
     # Qt_vectors <- Qt_inv$vectors[,Qt_inv$values>10^(-99)]
     # Qt_values <- Qt_inv$values[Qt_inv$values>10^(-99)]
      
     # Qt_inv <- Qt_vectors%*%diag(1/Qt_values)%*%t(Qt_vectors)
      
      #Res$log_like[tt] <- mvtnorm::dmvnorm(yt[idxOK],   # log-likelihood
      #                              mean = at[idxOK],
      #                              sigma = Qt,
       #                             log = TRUE)
      
    #  Res$log_like[tt] <- -(1/2)*(dim(Qt)[1]*log(2*pi)+
    #                                sum(log(Qt_values))+
     #                               t(yt[idxOK]-mt[idxOK])%*%Qt_inv%*%(yt[idxOK]-mt[idxOK]))
      
      
     # Rtp1 <- Res$Rt[tt,,]
     # Rtp1_inv <- eigen(Rtp1,symmetric = TRUE)
     # Rtp1_inv$vectors <- Rtp1_inv$vectors[,Rtp1_inv$values>10^(-5)]
     # Rtp1_inv$values <- Rtp1_inv$values[Rtp1_inv$values>10^(-5)]
      
    #  Rtp1_inv <- Rtp1_inv$vectors%*%diag(1/Rtp1_inv$values)%*%t(Rtp1_inv$vectors)
    }
  }
  
  return(Res)
}
