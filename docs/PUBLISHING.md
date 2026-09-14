# Publishing the CDA repository on GitHub and Zenodo

This checklist takes the prepared repository from your computer to a public,
versioned, DOI-assigned software record. Complete the authorship, licensing,
and data-provenance checks before the first public release.

## 1. Final checks before uploading

1. Put `EOF_STmonNS_NAtl_MCOM_SOM_truncated.nc` in `data/`.
2. Confirm that the NetCDF file may be redistributed and state its license and
   provenance in `data/README.md`.
3. Confirm that MIT is the desired software license. If it is not, replace
   `LICENSE` and update the `license` field in `CITATION.cff`.
4. Confirm the software authors listed in `CITATION.cff`. Add Michael Tippett or
   other contributors if their software contributions warrant authorship.
5. Add the final citation and DOI for the Buckley et al. paper to `README.md`
   when available.
6. Run `Rscript tests/test_synthetic.R`.
7. Run `source("examples/CallCDACode.R")` from the repository root and inspect
   the resulting figures.

## 2. Create the GitHub repository

The most reliable method is to push this prepared folder with Git. It preserves
the directory structure and gives you a complete local history.

1. Sign in to GitHub.
2. Select **New repository**.
3. Suggested repository name: `covariance-discriminant-analysis`.
4. Suggested description: `R code and a reproducible example for Covariance
   Discriminant Analysis (CDA).`
5. Choose **Public** when the files are ready for release.
6. Do **not** initialize the new repository with a README, `.gitignore`, or
   license, because this prepared folder already contains them.
7. Select **Create repository** and copy the HTTPS repository URL.

In Terminal, change into the unzipped repository directory and run:

```sh
git init
git add .
git commit -m "Initial public release of CDA code"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/covariance-discriminant-analysis.git
git push -u origin main
```

Replace `YOUR-USERNAME` with the GitHub owner. GitHub will prompt you to
authenticate if needed.

After pushing, edit `CITATION.cff` and add:

```yaml
repository-code: "https://github.com/YOUR-USERNAME/covariance-discriminant-analysis"
```

Commit and push that change:

```sh
git add CITATION.cff
git commit -m "Add repository URL to citation metadata"
git push
```

### Browser-only alternative

You can instead create the empty repository, select **Add file > Upload files**,
and drag the contents of the unzipped folder into GitHub. Check carefully that
the `R`, `examples`, `tests`, `data`, `docs`, and `output` directories retain
their structure. The command-line method is preferable for an archival code
repository.

## 3. Connect the repository to Zenodo

1. Sign in to Zenodo using your GitHub account.
2. Open your Zenodo profile menu and select **GitHub**.
3. Find `covariance-discriminant-analysis` and enable it.
4. Confirm that Zenodo recognizes the repository before creating the GitHub
   release.

This repository uses `CITATION.cff` for both GitHub's citation display and the
software metadata consumed by Zenodo. Do not add `.zenodo.json` unless you need
Zenodo-specific metadata such as grants or communities; if both files are
present, Zenodo ignores `CITATION.cff` during GitHub release archiving.

## 4. Create release 1.0.0

On the GitHub repository page:

1. Select **Releases**, then **Draft a new release**.
2. Choose **Create new tag** and enter `v1.0.0`.
3. Set the release title to `CDA for R v1.0.0`.
4. Briefly describe the included functions, worked example, input dataset, and
   validation test.
5. Select **Publish release**.

Zenodo should detect and process the release. In Zenodo, open the repository
from the GitHub integration page, wait for processing to finish, and select the
record DOI.

## 5. Add the DOI to GitHub

The Zenodo record supplies a version-specific DOI. Add it to `CITATION.cff`:

```yaml
doi: "10.5281/zenodo.REPLACE_WITH_RECORD_NUMBER"
```

Add the badge supplied on the Zenodo record near the top of `README.md`:

```markdown
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.RECORD.svg)](https://doi.org/10.5281/zenodo.RECORD)
```

Then commit and push:

```sh
git add README.md CITATION.cff
git commit -m "Add Zenodo DOI"
git push
```

This post-release commit is normal. The archived `v1.0.0` files remain fixed;
future code changes should be released under a new version such as `v1.0.1` or
`v1.1.0`.

## 6. Cite the software in the paper

Use the exact software citation shown on the Zenodo record, including the
version-specific DOI. A Code Availability statement can say:

> The R code used to perform Covariance Discriminant Analysis, together with a
> worked example and the truncated input dataset, is archived on Zenodo at
> https://doi.org/10.5281/zenodo.RECORD and developed at the corresponding
> GitHub repository.

Replace the placeholder with the actual DOI and add the GitHub URL. If the
dataset receives a separate Zenodo record, cite both the software record and
the dataset record explicitly.
