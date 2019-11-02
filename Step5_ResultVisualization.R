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

prjname='pongo'
dir.pihmin = '/Users/leleshu/Downloads/output/input/pongo/'
dir.pihmout = '/Users/leleshu/Downloads/output/output/pongo.out/'
pp = PIHM(prjname = prjname, inpath = dir.pihmin, outpath = dir.pihmout)

dir.csv = file.path(dir.pihmout, 'CSV')
dir.create(dir.csv, showWarnings = FALSE, recursive = TRUE)

#===== Model Information ===================
spr=rgdal::readOGR(file.path(pp$inpath, 'gis', 'river.shp'))
ModelInfo( crs.pcs = raster::crs(spr))

#=====EXPORT Discharge at Outlet ===================
oid=getOutlets()
qq=readout('rivqdown')
p=rowMeans(readout('elevprcp'))
qout =qq[,oid]; time(qout)=as.Date(time(qout))
pq=cbind('Precipitation_m/d'=p, 'Discharge_m3/d'=qout)
write.xts(pq, file = file.path(dir.csv, 'Precip_Discharge.csv'))

#=====Load data and basic plot ===================
vns= c("eleysurf","eleyunsat","eleygw",
       "elevprcp","elevetp",
       "elevinfil","elevrech",
       "elevetic", "elevettr", "elevetev",'elevetp',
       "rivqdown","rivqsub", "rivqsurf","rivystage")

xl=BasicPlot(varname = vns, imap = T)
# xl=readRDS('/Users/leleshu/Downloads/output/output/pongo.out/BasicPlot.RDS')

#===== Waterbalance ===================
png.control('WaterBalance.png', path=pp$anapath)
wb=wb.all(xl=xl, apply.weekly, plot = T)
dev.off()
