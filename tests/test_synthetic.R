# Lightweight numerical checks using synthetic data. No contributed R packages
# are required. Run from the repository root with:
#   Rscript tests/test_synthetic.R

source(file.path("R", "gev.R"))
source(file.path("R", "cda.R"))

set.seed(20260914)

nx <- 1200L
ny <- 1000L
k <- 3L

x <- matrix(rnorm(nx * k), nrow = nx) %*% diag(c(3, 2, 1))
y <- matrix(rnorm(ny * k), nrow = ny)
eof <- diag(k)

fit <- cda(x, y, eof, num.eof = k)

stopifnot(
  identical(dim(fit$rx), c(nx, k)),
  identical(dim(fit$ry), c(ny, k)),
  identical(dim(fit$pmat), c(k, k)),
  length(fit$discr.ratio) == k,
  all(diff(fit$discr.ratio) <= 0)
)

# The reported generalized eigenvalues must equal the sample variance ratios
# of the corresponding CDA variates.
observed.ratios <- apply(fit$rx, 2, var) / apply(fit$ry, 2, var)
stopifnot(isTRUE(all.equal(
  unname(fit$discr.ratio),
  unname(observed.ratios),
  tolerance = 1e-10
)))

# gev() normalizes q so t(q) %*% B %*% q is the identity matrix.
cov.y <- cov(y)
stopifnot(isTRUE(all.equal(
  t(fit$q) %*% cov.y %*% fit$q,
  diag(k),
  tolerance = 1e-10
)))

message("All synthetic CDA checks passed.")
