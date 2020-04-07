load"$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load"$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
time = 43470
do n=1,1
FILENAME2  = "CCPL_dir/run/data/cpl/mitgcm/WRF_MITgcm.mitgcm.r.20180721-"+time+".nc"
file1 = addfile(FILENAME2,"r")

t2 = file1->$"t2.MITgcm_H2D_grid.MITgcm_decomp.0"$
q2 = file1->$"q2.MITgcm_H2D_grid.MITgcm_decomp.0"$
u10 = file1->$"u10.MITgcm_H2D_grid.MITgcm_decomp.0"$
v10 = file1->$"v10.MITgcm_H2D_grid.MITgcm_decomp.0"$

lat = file1->grid_0_lat
nlat = dimsizes(lat)
lon = file1->grid_0_lon
nlon = dimsizes(lon)

res						  = True
res@tiMainString          = "T2 obtained by MITgcm"
res@gsnMaximize          = True     ; maximize plot in frame
res@cnFillOn             = True     ; turn on contour fill
res@cnLinesOn            = False    ; turn off contour lines
res@cnLineLabelsOn       = False    ; turn off line labels
res@gsnAddCyclic         = False    ; set to False if plotting regional data
res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = 256.
res@cnMaxLevelValF = 304.
res@cnLevelSpacingF = 4.
res@sfXArray	      = lon
res@sfYArray		  = lat
res@mpMinLatF         = 30.0   ;min(lat)
res@mpMaxLatF         = max(lat)
res@gsnPolar   = "NH"                          ; specify the hemisphere
wks=gsn_open_wks("png","t2-20180107-"+time+"-mitgcm")
plot=gsn_csm_contour_map_polar(wks,t2,res)    ; create the plot

res@tiMainString		= "Q2 obtained by MITgcm"
res@cnMinLevelValF = 0.0
res@cnMaxLevelValF = 0.02
res@cnLevelSpacingF = 0.0004
wks=gsn_open_wks("png","q2-20180107-"+time+"-mitgcm")
plot=gsn_csm_contour_map_polar(wks,q2,res)    ; create the plot

res@tiMainString        = "U10 obtained by MITgcm"
res@cnMinLevelValF = -20.0
res@cnMaxLevelValF = 20.0
res@cnLevelSpacingF = 2.0
wks=gsn_open_wks("png","u10-20180107-"+time+"-mitgcm")
plot=gsn_csm_contour_map_polar(wks,u10,res)    ; create the plot

res@tiMainString        = "V10 obtained by MITgcm"
res@cnMinLevelValF = -20.0
res@cnMaxLevelValF = 20.0
res@cnLevelSpacingF = 2.0
wks=gsn_open_wks("png","v10-20180107-"+time+"-mitgcm")
plot = gsn_csm_contour_map_polar(wks,v10,res)    ; create the plot

time = time + 135
end do

end

