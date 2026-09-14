###############################################################################
# Covariance Discriminant Analysis of the MCOM and SOM experiments
#
# Run this script from the repository's top-level directory:
#   source("examples/CallCDACode.R")
#
# Required input:
#   data/EOF_STmonNS_NAtl_MCOM_SOM_truncated.nc
#
# Outputs (when write.pdf is TRUE):
#   output/CDA.NAtl_MCOM_SOM.space.time.mode_XX.pdf
#   output/CDA.NAtl_MCOM_SOM.ratios.pdf
#   output/cda_results.rds
###############################################################################

rm(list = ls())

# ---- User settings -----------------------------------------------------------

input.file <- file.path(
  "data",
  "EOF_STmonNS_NAtl_MCOM_SOM_truncated.nc"
)
output.dir <- "output"

trun.eof <- 30L
break.point <- 5400L
ntime.to.plot <- 2000L

# Mode 1 has the largest variance ratio (MCOM/SOM). The final mode has the
# smallest ratio; its reciprocal highlights the strongest SOM/MCOM contrast.
modes.to.plot <- c(1L, trun.eof)

# Set FALSE to draw figures in the active R graphics device instead of PDFs.
write.pdf <- TRUE

# Geographic domain for the spatial loading patterns.
xlim.image <- c(-100, 20)
ylim.image <- c(0, 70)

# ---- Dependencies and CDA functions -----------------------------------------

required.packages <- c("ncdf4", "fields", "maps")
missing.packages <- required.packages[
  !vapply(required.packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing.packages) > 0L) {
  stop(
    "Install the required package(s) before running this example: ",
    paste(missing.packages, collapse = ", ")
  )
}

source(file.path("R", "gev.R"))
source(file.path("R", "cda.R"))

if (!file.exists(input.file)) {
  stop(
    "Input file not found: ", input.file, "\n",
    "Place EOF_STmonNS_NAtl_MCOM_SOM_truncated.nc in the data directory."
  )
}

if (!dir.exists(output.dir)) {
  dir.create(output.dir, recursive = TRUE)
}

# ---- Read the EOF/PC data ----------------------------------------------------

# The MCOM and SOM PC time series are concatenated in the NetCDF file. The
# first 1:break.point rows are MCOM and the remaining rows are SOM. A common
# set of EOFs represents both experiments.
nc.data <- ncdf4::nc_open(input.file)

eof <- ncdf4::ncvar_get(nc.data, "EOF")
pc <- ncdf4::ncvar_get(nc.data, "PC")
fexpvar <- ncdf4::ncvar_get(nc.data, "fexpvar")
sval <- ncdf4::ncvar_get(nc.data, "sval")
weight <- ncdf4::ncvar_get(nc.data, "weight")

lon <- ncdf4::ncvar_get(nc.data, "LON")
lat <- ncdf4::ncvar_get(nc.data, "LAT")
tstep <- ncdf4::ncvar_get(nc.data, "tstep")

ncdf4::nc_close(nc.data)

nlon <- length(lon)
nlat <- length(lat)
ntime <- length(tstep)

if (length(eof) %% (nlon * nlat) != 0L) {
  stop("The EOF array size is inconsistent with the longitude/latitude grid.")
}

neof <- length(eof) / (nlon * nlat)

if (!all(dim(eof)[1:2] == c(nlon, nlat))) {
  stop("Expected EOF dimensions [longitude, latitude, mode].")
}
if (nrow(pc) != ntime) {
  stop("Expected PC dimensions [time, mode].")
}
if (trun.eof > neof || trun.eof > ncol(pc)) {
  stop("trun.eof exceeds the number of EOF/PC modes in the input file.")
}
if (break.point < 1L || break.point >= ntime) {
  stop("break.point must divide the MCOM and SOM portions of the PC series.")
}
if (any(modes.to.plot < 1L) || any(modes.to.plot > trun.eof)) {
  stop("Every entry in modes.to.plot must lie between 1 and trun.eof.")
}

# Convert EOF[longitude, latitude, mode] to EOF[space, mode], as required by
# cda(). R stores arrays column-major, so this preserves the ordering used when
# the patterns are reshaped below.
dim(eof) <- c(nlon * nlat, neof)

# ---- Calculate CDA -----------------------------------------------------------

n.mcom <- seq_len(break.point)
n.som <- seq.int(break.point + 1L, ntime)

cda.list <- cda(
  xdata = pc[n.mcom, seq_len(trun.eof), drop = FALSE],
  ydata = pc[n.som, seq_len(trun.eof), drop = FALSE],
  eof = eof,
  num.eof = trun.eof
)

# pmat is returned as [space, mode]; restore [longitude, latitude, mode].
pmat.map <- array(
  cda.list$pmat,
  dim = c(nlon, nlat, cda.list$neof.pic)
)

saveRDS(cda.list, file.path(output.dir, "cda_results.rds"))

# ---- Plot selected loading patterns and variate time series -----------------

n.available <- min(length(n.mcom), length(n.som))
if (ntime.to.plot > n.available) {
  warning("ntime.to.plot exceeds one series length; using ", n.available)
  ntime.to.plot <- n.available
}

year <- (seq_len(ntime.to.plot) - 1L) / 12

# Use one symmetric color scale for all selected modes so their amplitudes are
# visually comparable.
pattern.limit <- max(abs(pmat.map[, , modes.to.plot]), na.rm = TRUE)
if (!is.finite(pattern.limit) || pattern.limit == 0) {
  stop("The selected loading patterns contain no finite nonzero values.")
}
pattern.breaks <- seq(-pattern.limit, pattern.limit, length.out = 21L)
pattern.colors <- grDevices::colorRampPalette(c("blue", "white", "red"))(
  length(pattern.breaks) - 1L
)

for (mode in modes.to.plot) {
  figure.file <- file.path(
    output.dir,
    sprintf("CDA.NAtl_MCOM_SOM.space.time.mode_%02d.pdf", mode)
  )

  if (write.pdf) {
    grDevices::pdf(figure.file, height = 8, width = 8.5)
  }

  graphics::par(mfrow = c(2, 1), mar = c(5, 5, 3, 1))
  graphics::par(cex.axis = 1.3, cex.lab = 1.3, cex.main = 1.3)

  fields::image.plot(
    lon,
    lat,
    pmat.map[, , mode],
    col = pattern.colors,
    breaks = pattern.breaks,
    xlab = "",
    ylab = "",
    main = "",
    xlim = xlim.image,
    ylim = ylim.image,
    legend.lab = "SST loading",
    smallplot = c(0.80, 0.83, 0.18, 0.82),
    legend.mar = 4,
    legend.line = 4
  )
  maps::map("world", add = TRUE, col = "black", lwd = 0.5)
  graphics::title(main = "CDA of MCOM/SOM SST Variability", line = 2.0)
  graphics::title(
    main = paste("Discriminant", mode, "of", trun.eof),
    line = 0.5
  )

  graphics::par(mar = c(5, 5, 3, 1))
  yrange <- range(
    cda.list$rx[seq_len(ntime.to.plot), mode],
    cda.list$ry[seq_len(ntime.to.plot), mode]
  )
  graphics::plot(
    range(year),
    yrange,
    type = "n",
    xlab = "year",
    ylab = "variate"
  )
  graphics::lines(
    year,
    cda.list$rx[seq_len(ntime.to.plot), mode],
    col = "blue"
  )
  graphics::lines(
    year,
    cda.list$ry[seq_len(ntime.to.plot), mode],
    col = "red"
  )
  graphics::title(
    paste0(
      "Variance ratio = ", signif(cda.list$discr.ratio[mode], 3),
      "; reciprocal = ", signif(1 / cda.list$discr.ratio[mode], 3)
    ),
    line = 0.5
  )
  graphics::legend(
    "top",
    legend = c("MCOM", "SOM"),
    col = c("blue", "red"),
    lwd = 2,
    ncol = 2,
    cex = 0.8
  )

  if (write.pdf) {
    grDevices::dev.off()
  }
}

# ---- Plot all discriminant ratios -------------------------------------------

ratio.file <- file.path(output.dir, "CDA.NAtl_MCOM_SOM.ratios.pdf")
if (write.pdf) {
  grDevices::pdf(ratio.file, height = 5, width = 8.5)
}

graphics::par(mfrow = c(1, 1), mar = c(5, 5, 3, 1))
graphics::par(cex.axis = 1.3, cex.lab = 1.3, cex.main = 1.3)
graphics::plot(
  cda.list$discr.ratio,
  type = "b",
  pch = 19,
  xlab = "mode",
  ylab = "discriminant ratio"
)
graphics::abline(h = 1, col = "gray50", lty = 2)
graphics::title("Discriminant Ratios of MCOM/SOM SST Variability", line = 0.5)

if (write.pdf) {
  grDevices::dev.off()
}

message("CDA calculation complete.")
if (write.pdf) {
  message("Results and figures were written to: ", output.dir)
}
