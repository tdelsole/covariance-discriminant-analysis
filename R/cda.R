cda = function(xdata,ydata,eof,num.eof=NA) {
### PERFORMS COVARIANCE DISCRIMINANT ANALYSIS ON X AND Y
### INPUT:
###   XDATA[NX,MDIM] 
###   YDATA[NY,MDIM]
###   EOF[SPACE,MDIM]: EOFs 
###	  NUM.EOF: NUMBER OF EOFS TO INCLUDE IN CDA; SET TO NA TO SELECT BASED ON MIC
### OUTPUT:
###   MIC[NEOF]: MIC AS A FUNCTION OF NUMBER OF PCS
###   NMIN: LOCATION OF MINIMUM MIC
###   DISCR.RATIO[NEOF]: DISCRIMINANT RATIOS VS. NUMBER OF PCS
###   RX[NX,NMIN]: VARIATE TIME SERIES FOR X
###   RY[NY,NMIN]: VARIATE TIME SERIES FOR Y
###   PMAT[SPACE,NMIN]: LOADING VECTOR
### matrix of projection vectors

xdata      = as.matrix(xdata)
ydata      = as.matrix(ydata)
eof        = as.matrix(eof)
nx         = dim(xdata)[1]
ny         = dim(ydata)[1]
neof       = dim(xdata)[2]
if (dim(xdata)[2] != dim(ydata)[2]) stop('xdata and ydata should have the same number of columns')

nmax       = min(nx-1,ny-1,neof)
if (!is.na(num.eof)) if (num.eof > nmax) stop("number of EOFs exceeds the maximum allowed")

nt         = nx + ny
cov.x      = cov(xdata) * (nx-1)/nx
cov.y      = cov(ydata) * (ny-1)/ny
cov.t      = (nx * cov.x + ny * cov.y)/nt

mic        = as.numeric(rep(NA,nmax))
penalty    = as.numeric(rep(NA,nmax))
for (ne in 1:nmax) penalty[ne] = ne * ( nx*(nx+1)/(nx-ne-2) + ny*(ny+1)/(ny-ne-2) - nt*(nt+1)/(nt-ne-2))
for (ne in 1:nmax) {
	mic[ne] = nx * log(det(cov.x[1:ne,1:ne,drop=FALSE])) +
	          ny * log(det(cov.y[1:ne,1:ne,drop=FALSE])) -
	          nt * log(det(cov.t[1:ne,1:ne,drop=FALSE])) + penalty[ne]
}

penalty = penalty / nt
mic     = mic     / nt
nmin    = which.min(mic)

### rescale covariances to be unbiased
cov.x   = cov.x * nx / (nx-1)
cov.y   = cov.y * ny / (ny-1)
if (is.na(num.eof)) neof.pic = nmin else neof.pic = num.eof 

gev.list    = gev(cov.x[1:neof.pic,1:neof.pic],cov.y[1:neof.pic,1:neof.pic])

discr.ratio = gev.list$lambda
rx          = xdata[,1:neof.pic] %*% gev.list$q
ry          = ydata[,1:neof.pic] %*% gev.list$q
pmat        = eof[,1:neof.pic] %*% cov.y[1:neof.pic,1:neof.pic] %*% gev.list$q

list(mic=mic,neof.pic=neof.pic,discr.ratio=discr.ratio,rx=rx,ry=ry,pmat=pmat, q=gev.list$q, nmin=nmin)

}
