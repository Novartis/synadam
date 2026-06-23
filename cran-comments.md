## Submission

This is a new submission of the package `synadam` to CRAN.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release, so the expected NOTE on CRAN is:

  ```
  Maintainer: 'David Zhang <david-1.zhang@novartis.com>'
  New submission
  ```

The only NOTE observed in the local `R CMD check --as-cran` run was:

```
checking for future file timestamps ... NOTE
  unable to verify current time
```

This NOTE is an artifact of the build machine being unable to reach the
external time-verification server; it is not related to the package and does
not occur on machines with network access to the time service.

## Test environments

* Local: macOS (aarch64-apple-darwin20), R 4.5.1 — `R CMD check --as-cran`,
  0 errors | 0 warnings | 1 note (the timestamp NOTE described above).

Additional platform checks (win-builder, the macOS builder, and R-hub v2) have
not yet been run for this submission and should be completed before submitting.

## Downstream dependencies

There are currently no downstream dependencies for this package (new
submission).
