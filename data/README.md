# Input data

Place the following file in this directory before running the worked example:

`EOF_STmonNS_NAtl_MCOM_SOM_truncated.nc`

The file is approximately 1.5 MB and contains EOFs and PCs derived from the
MCOM and SOM experiments analyzed by Buckley, DelSole, Kwon, Larson, Shin, and
McMonigal (2026), *Ocean dynamics mediates the response of Atlantic sea surface
temperatures to the North Atlantic Oscillation*, *Scientific Reports*.

Expected NetCDF variables:

| Variable | Expected dimensions | Purpose |
| --- | --- | --- |
| `EOF` | longitude x latitude x mode | EOF spatial patterns |
| `PC` | time x mode | Concatenated MCOM and SOM PC series |
| `fexpvar` | mode | Fraction of variance explained |
| `sval` | mode | PCA singular values |
| `weight` | longitude x latitude | PCA area weights |
| `LON` | longitude | Longitude coordinates |
| `LAT` | latitude | Latitude coordinates |
| `tstep` | time | Time coordinate |

The worked example assumes that time steps 1--5400 are from MCOM and all
remaining time steps are from SOM. If a different file is used, edit
`break.point` in `examples/CallCDACode.R` accordingly.

Before publishing this data file, confirm that its provenance and license allow
redistribution, and describe any preprocessing used to create the truncated
file.
