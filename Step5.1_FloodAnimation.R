# Task:
# Convert the surface water ponding to flood inundation map.
# .eleysurf.dat file is required.
# Output is geotiff file with multiple layers.
# 
source('GetReady.R')
pp = PIHM(prjname = prjname, inpath = dir.pihmin, outpath = dir.pihmout)
wbd=readOGR(file.path(pp$inpath, 'gis', 'domain.shp'))
crs.pcs = crs(wbd)
cfg.para = readpara()
vns= c("eleysurf", "eleygw")
xl=BasicPlot(varname = vns, plot=F, imap=F, iRDS = FALSE)

fx <- function(x, key, outdir=file.path(dir.pihmout, 'vis'), crs){
  dir.create(outdir, showWarnings = F, recursive = T)
  
  x.mon=apply.monthly(x, function(x, func){apply(x, 2, func)}, func = max)
  rs=MeshData2Raster(x.mon, stack = T, crs=crs)
  cn=paste0(key, strftime(time(x.mon), '%Y-%m') )
  cn
  names(rs) = cn
  # cellStats(rs, range)
  xm=rs;
  # xm[xm<0.05]=0
  writeRaster(xm, file.path(outdir, paste0(key, '.tif')), stack=T, overwrite=T)
  
  nx=dim(xm)[3]
  
  for(i in 1:nx){
    fn=paste0(cn[i], '.png')
    message(i,'/', nx, '\t', fn)
    png.control(fn, path = outdir)
    par(mar=c(1,1,1,2))
    plot(xm[[i]], axes=FALSE)
    title(cn[i])
    dev.off()
  }
}
fx(xl$eleysurf, key='Flood_surf', crs=crs.pcs)
fx(xl$eleygw, key='Flood_GW', crs=crs.pcs)

# plot(rm, breaks=seq(0, 0.1, length.out = 10))
