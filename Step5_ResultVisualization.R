# Task:
# 1. Configure the Model input/output path and project names.
# 2. The values of your interest.
# 3. Load the time-series (TS) data 
# 4. Do the TS-plot
# 5. 2D spatial plot.
# 6. Water balance calculation.
# 7.
# 8.
source('GetReady.R')
wb2csv <- function(wb, fn){
  x = data.frame( 'JDN'=strftime(time(wb), '%Y%j'), wb)
  write.table(x, fn, quote = FALSE, row.names = FALSE)
}

pp = PIHM(prjname = prjname, inpath = dir.pihmin, outpath = dir.pihmout)
dir.csv = file.path(dir.pihmout, 'CSV')
dir.create(dir.csv, showWarnings = FALSE, recursive = TRUE)

#===== Model Information ===================
spr=rgdal::readOGR(file.path(PIHM.filein()['inpath'], 'gis', 'river.shp'))
ModelInfo(crs.pcs = raster::crs(spr), spr=spr)

#=====EXPORT Discharge at Outlet ===================
oid=getOutlets()
qq=readout('rivqdown')
p=rowMeans(readout('elevprcp'))
qout =qq[,oid]; time(qout)=as.Date(time(qout))
pq=cbind('Precipitation_m/d'=p, 'Discharge_m3/d'=qout)
write.xts(pq, file = file.path(dir.csv, 'Precip_Discharge.csv'))
#=====EXPORT Discharge at Critical Rivers ===================
id=getCriticalRiver()
y=qq[,id]; colnames(y) = paste0('X', id, '_m3/d')
wb2csv(y, file.path(dir.csv, 'CriticalRiver_m3d.csv'))

#=====Load data and basic plot ===================
vns= c("eleysurf","eleyunsat","eleygw",
       "elevprcp","elevetp",
       "elevinfil","elevrech",
       "elevetic", "elevettr", "elevetev",'elevetp',
       "rivqdown","rivqsub", "rivqsurf","rivystage")
debug(BasicPlot)
xl=BasicPlot(varname = vns, imap = TRUE, plot=TRUE)
# xl=BasicPlot(varname = vns, imap = FALSE, plot = FALSE)
xl=readRDS(file.path(pp$outpath, 'BasicPlot.RDS'))

#===== Waterbalance ===================
png.control('WaterBalance.png', path=pp$anapath)
wb=wb.all(xl=xl, apply.weekly, plot = T)
dev.off()
png.control('WaterBalance_River.png', path=pp$anapath)
wbr = wb.riv(xl=xl, fun = apply.weekly)
dev.off()
wb2csv(wb, file.path(pp$anapath, 'waterbalance.csv'))
wb2csv(wbr, file.path(pp$anapath, 'waterbalance_river.csv'))

