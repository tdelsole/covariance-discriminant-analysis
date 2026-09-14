# Covariance Discriminant Analysis in R

This repository provides R code for **Covariance Discriminant Analysis (CDA)**,
a method for finding linear combinations of variables that optimize the ratio
of their variances in two datasets. The method is described in Chapter 16 of
DelSole and Tippett (2022), *Statistical Methods for Climate Scientists*.

The worked example applies CDA to EOF/PC data from the MCOM and SOM experiments
used by Buckley, DelSole, Kwon, Larson, Shin, and McMonigal (2026), *Ocean
dynamics mediates the response of Atlantic sea surface temperatures to the
North Atlantic Oscillation*, *Scientific Reports*.

## What CDA computes

Let `X` be an `N1 x K` matrix and `Y` an `N2 x K` matrix. The two datasets have
the same `K` variables but may have different numbers of time steps. CDA solves
the generalized eigenvalue problem

```text
Cov(X) q = lambda Cov(Y) q.
```

The projection vectors are normalized so that
`t(q) %*% Cov(Y) %*% q = I`. Consequently, each eigenvalue `lambda` is the
sample variance ratio

```text
var(X %*% q) / var(Y %*% q).
```

The ratios are returned in descending order. The first mode maximizes the
variance ratio of dataset 1 to dataset 2. The last mode has the smallest ratio,
so its reciprocal maximizes the variance ratio of dataset 2 to dataset 1.

The sign of every CDA projection vector, loading pattern, and variate time
series is arbitrary; reversing all three signs for a mode does not change the
result.

## Repository contents

```text
R/cda.R                    Main CDA function
R/gev.R                    Generalized eigenvalue solver
examples/CallCDACode.R     Worked MCOM/SOM analysis and figures
tests/test_synthetic.R     Package-free numerical checks
data/README.md             Input-data description
docs/PUBLISHING.md         GitHub and Zenodo instructions
```

## Requirements

- R
- `ncdf4`, `fields`, and `maps` for the NetCDF worked example
- No contributed packages for `cda()` itself or the synthetic test

Install the example dependencies once with:

```r
install.packages(c("ncdf4", "fields", "maps"))
```

## Quick start with two arbitrary datasets

From the repository's top-level directory:

```r
source(file.path("R", "gev.R"))
source(file.path("R", "cda.R"))

# ts1 and ts2 may have different row counts, but must have the same K columns.
# eof must have K columns. Use diag(K) when no spatial EOF reconstruction is
# needed and the original variables themselves should define the loadings.
K <- ncol(ts1)
fit <- cda(
  xdata = ts1,
  ydata = ts2,
  eof = diag(K),
  num.eof = K
)

fit$discr.ratio  # K variance ratios
fit$rx           # N1 x K variates for dataset 1
fit$ry           # N2 x K variates for dataset 2
fit$pmat         # K x K loading patterns when eof = diag(K)
fit$q            # K x K projection vectors
```

If `eof` is a `SPACE x K` matrix of EOF patterns, then `fit$pmat` is a
`SPACE x K` matrix of loading patterns. If `num.eof` is smaller than `K`, the
returned number of CDA modes equals `num.eof`.

### Automatic truncation selection

Set `num.eof = NA` (the default) to use the minimum-information criterion (MIC)
implemented in `cda.R`:

```r
fit <- cda(ts1, ts2, eof, num.eof = NA)
fit$nmin      # MIC-selected truncation
fit$mic       # MIC as a function of truncation
fit$neof.pic  # truncation actually used
```

The covariance matrix for dataset 2 must be positive definite for the Cholesky
factorization in `gev()`; in practice, the selected truncation must be smaller
than the effective sample size and rank of both datasets. The MIC correction
also requires each sample size to exceed the candidate truncation by at least
two.

## Reproduce the MCOM/SOM calculation

1. Put `EOF_STmonNS_NAtl_MCOM_SOM_truncated.nc` in `data/`.
2. Open R in the repository's top-level directory.
3. Run:

```r
source("examples/CallCDACode.R")
```

By default, the script retains 30 EOFs, treats time steps 1--5400 as MCOM and
the remainder as SOM, plots modes 1 and 30, and writes PDF figures plus
`cda_results.rds` to `output/`. The settings are collected at the beginning of
the script so they can be changed in one place.

## Example output

The worked example produces the following figures:

- [CDA loading pattern and variate time series](examples/figures/CDA.NAtl_MCOM_SOM.space.time.30.pdf)
- [CDA discriminant ratios](examples/figures/CDA.NAtl_MCOM_SOM.ratios.pdf)

## Validate the numerical calculation

Run the synthetic checks from the repository root:

```sh
Rscript tests/test_synthetic.R
```

The test confirms the output dimensions, descending eigenvalue order,
variance-ratio identity, and generalized-eigenvector normalization.

## Function output

`cda()` returns a list with these elements:

| Element | Dimensions | Description |
| --- | --- | --- |
| `mic` | up to `K` | MIC versus EOF/PC truncation |
| `nmin` | scalar | Truncation at the minimum MIC |
| `neof.pic` | scalar | Truncation used in the CDA solution |
| `discr.ratio` | `neof.pic` | Variance ratios, dataset 1 / dataset 2 |
| `rx` | `N1 x neof.pic` | Dataset 1 CDA variates |
| `ry` | `N2 x neof.pic` | Dataset 2 CDA variates |
| `pmat` | `SPACE x neof.pic` | CDA loading patterns |
| `q` | `neof.pic x neof.pic` | Projection vectors in retained-PC space |

## References

- DelSole, T., and M. K. Tippett (2022): *Statistical Methods for Climate
  Scientists*. Cambridge University Press. Chapter 16. DOI:
  [10.1017/9781108659055](https://doi.org/10.1017/9781108659055).
- Buckley, M. W., T. DelSole, Y.-O. Kwon, S. Larson, S.-I. Shin, and K.
  McMonigal (2026): “Ocean dynamics mediates the response of Atlantic sea
  surface temperatures to the North Atlantic Oscillation.” *Scientific
  Reports*.

## Citation and license

Please cite the archived software release using the citation displayed by
GitHub or Zenodo, as well as the relevant scientific reference above. Before
the first public release, update `CITATION.cff` with the GitHub URL and, after
archiving, the Zenodo DOI.

The repository currently proposes the MIT License; see `LICENSE`. Confirm that
this is the desired license, and separately confirm that the input data may be
redistributed under an appropriate data license, before making the repository
public.
