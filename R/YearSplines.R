#' @title YearSplines: Spline Basis for Days in year. 
#' @description The function \code{YearSplines}  returns a matrix with spline base for days in year
#' so that there is a smooth transition from new years eve till new years day.
#' @details ...
#' @param x [\code{numeric}] or [\code{Date}]. Defining days/ months 
#' for which spline basis is to be calculated. If the class of \code{x} is 
#' [\code{Date}] then x is recalculated till [\code{numeric}] by 
#' \code{x <- lubridate::yday(x)}.
#' @param df [\code{integer}] the number of splines (the rank of the returned spline matrix).
#' @param contrasts [\code{logical}]. If \code{contrasts = TRUE} the dimension of the returned 
#' spline base 
#' @return A list with element \cr
#' \item SB: Matrix [\code{numeric}] of dimension [\code{length(x)}, \code{length(df)-1}] if 
#' \code{contrasts = TRUE} or [\code{length(x)}, \code{length(df)}] if  
#' \code{contrasts = FALSE}\cr
#' \item DateLims. Matrix [\code{character, "mm-dd"}]  of dimension  [\code{length(df),3}],
#' defining which timeperiod the different splines are active
#'
#'
#' @author Lars Erik Gangsei\cr
#' lars.erik.gangsei@@vetinst.no\cr
#' +47 950 61 231
#' 
#' @import splines
#' @import lubridate
#' 
#' @examples
#' \dontrun{
#'
#' # Simulate data
#' set.seed(22)
#' demoDf <- data.frame(y = sin(seq(1,365,length.out = 24)*2*pi/365)+rnorm(24,0,sqrt(0.1)),
#'                     x = as.Date(seq(1,365,length.out = 24))) 
#' # Plot data
#' plot(demoDf$x,demoDf$y,ylab = 'y',xlab = 'Date',main = 'Demo YearSplines',
#' pch = 19,col = 'red')
#' # Add the true underlaying model
#' curve(sin(2*pi*x/365),col = 'green',lwd = 3,lty = 2,add=TRUE)
#' 
#' # Spline model with 6 splines
#' demoDf$SplineBase <- I(YearSplines(demoDf$x,df = 6,contrasts = TRUE)$SB)
#' Mod_6 <- lm(y~SplineBase,data = demoDf)
#' summary(Mod12)
#' 
#' # Make data frame with all dates in a year
#' testDf <- data.frame(x = as.Date(1:365)) 
#' testDf$SplineBase <- I(YearSplines(testDf$x,df = 6,contrasts = TRUE)$SB)
#' 
#' points(testDf$x,predict(Mod_6,newdata = testDf),type = 'l',lwd = 3)
#' 
#' # Overfitting by setting df till 20
#' demoDf$SplineBase <- I(YearSplines(demoDf$x,df = 20,contrasts = TRUE)$SB)
#' Mod_12 <- lm(y~SplineBase,data = demoDf)
#' 
#' testDf$SplineBase <- I(YearSplines(testDf$x,df = 20,contrasts = TRUE)$SB)
#' 
#' points(testDf$x,predict(Mod_12,newdata = testDf),type = 'l',lwd = 3,col = 'blue')
#' 
#' }
#'
#'
#' @export
YearSplines <- function(x = 1:365,df = 12,contrasts = TRUE) 
  {
  # Make x numeric on interval 1-365
  if(class(x)=='integer'){x <- as.numeric(x)}
  if(class(x)!='numeric'){x <- lubridate::yday(x)}
  if(class(x)!='numeric'){stop('Wrong format for "x"')}
  
  delta_t <- 365/df
  SplineKnots <- seq(from = -3*delta_t,to = 365+3*delta_t,length.out = df + 7)
  
  SB <- splines::bs(x,knots = SplineKnots,Boundary.knots = range(SplineKnots))
  for(kk in 4:6){SB[,kk] <- SB[,kk]+SB[,kk+df]}
  
  SB <- SB[,c(5:(df+3),4)]
  SB <- SB/max(rowSums(SB))
  
  if(contrasts==TRUE){
    SB <- SB - SB[,df]*matrix(1,length(x),df)
    SB <- SB[,-df]
    #SB <- ContrastSplines(SB)
  }
    
  DateLims <- lapply(data.frame(Start = round(SplineKnots[2:(df+1)]),
                         Midpoint = round(SplineKnots[4:(df+3)]),
                         Stop = round(SplineKnots[6:(df+5)]),
                         row.names = paste('Spline',1:df,sep = '_')),
                     function(x) substr(as.character(as.Date(x)),6,11))
  
return(list(SB = SB,DateLims = DateLims))
  }
