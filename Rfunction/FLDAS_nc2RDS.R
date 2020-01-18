# read the orginal fldas data and save to .RDS file.

#install.packages('ncdf4')
require(ncdf4)
source('GetReady.R')
source('Rfunction/Fun.readnc.R')

fixNA <- function(x){
  for(i in 1:ncol(x)){
    cv=x[,i]
    cv[is.na(cv)] = mean(cv, na.rm=TRUE)
    x[,i] = cv
  }
  x
}

fl=readOGR(file.path(dir.pihmgis, 'FLDAS_GCS.shp'))@data
head(fl)
# years=2017:2018
dirs = file.path(dir.ldas, years)

ndir = length(dirs)
fn=list.files(dir.ldas, pattern=glob2rx('*.nc'), recursive = TRUE, full.names = T)[1]
fn
fid=nc_open(fn)
xloc = round(fid$dim$X$vals,2)
yloc = round(fid$dim$Y$vals, 2)
nx=length(xloc)
ny = length(yloc)

#===================================================
xc = fl[,'xcenter']
yc = fl[,'ycenter']

xid = match(round(xc, 2), xloc)
yid = match(round(yc,2), yloc)
xyid=cbind(xid,yid)

sn = paste0('X',xc*100, 'Y', yc*100)
ns = length(sn)

vns = names(fid$var)
vns = vns[!(vns %in% 'time_bnds')] # don't need the time_bnds

mat=ncvar_get(fid, vns[2])
mat=mat*0+1
png.control(fn=paste0('Rawdata','_FLDAS_location.png'), path = file.path(dir.png), ratio=1)
image(xloc, yloc, mat, xlab='Lon', ylab='Lat', main='Coverage of FLDAS') ; grid()
points(xloc[xid], yloc[yid], col=3)
plot(wbd.gcs, add=T)
dev.off()

nv=length(vns)
for(idd  in 1:ndir){ # for each year dir
  # library(foreach)
  # library(doMC)
  # library(doParallel)
  # registerDoMC(4)
  # foreach (idd = 1:ndir) %dopar%{
  cdir <- dirs[idd]
  fn.rds = file.path(dir.pihmgis, paste0(prjname,'-', basename(cdir), '.RDS'))
  
  if(!file.exists(fn.rds)){
    fns = list.files(cdir, pattern=glob2rx('*.nc'), recursive = T, full.names = T)
    nf = length(fns)
    x.arr = array(0, dim=c(ns, nv, nf) )
    x.t= character(nf)
    for(j  in 1:nf){  # files in each year
      fn=fns[j]
      t=substr(basename(fn), 22, 29)
      message(j, '/', nf, '\t', t)
      x.mat = readnc(fn, xyid=xyid, vns=vns)
      x.mat = fixNA(x.mat)
      x.t[j] = t
      x.arr[,,j ] = x.mat 
      if(sum(is.na(x.mat))>1){
        message('NA value exist in data, at ', j)
      }
    }
    dimnames(x.arr) = list(sn, vns,  x.t)
    saveRDS(x.arr, file=fn.rds)
  }
}
