import xarray as xr


dates=range(24,29)
dates_str=[str(x) for x in dates]
for idate in range(len(dates))
    ds = xr.open_dataset('wrfout_d01_2019-09-'+dates_str[idate]+'_00:00:00', decode_cf=False)
#print(ds.Time[0]==ds.Time[0])
#print(ds.Times)

    ds2 = ds.where((ds.Time==0),drop=True)
    ds2.to_netcdf(path='wrfout_d01_2019-09-'+dates_str[idate]+'_00:00:00_subset.nc')

