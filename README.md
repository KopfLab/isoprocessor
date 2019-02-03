
<!-- README.md is generated from README.Rmd. Please edit that file -->

# isoprocessor <a href='http://isoprocessor.isoverse.org'><img src='man/figures/isoprocessor_logo_thumb.png' align="right" height="138.5"/></a>

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/isoprocessor)](https://cran.r-project.org/package=isoprocessor)
[![Git\_Hub\_Version](https://img.shields.io/badge/GitHub-0.3.0-orange.svg?style=flat-square)](/commits)
[![Documentation](https://img.shields.io/badge/docs-online-green.svg)](http://isoprocessor.isoverse.org/)
[![Build
Status](https://travis-ci.org/isoverse/isoprocessor.svg?branch=master)](https://travis-ci.org/isoverse/isoprocessor)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/isoverse/isoprocessor?branch=master&svg=true)](https://ci.appveyor.com/project/isoverse/isoprocessor)
[![Binder](https://img.shields.io/badge/launch-RStudio-blue.svg)](https://mybinder.org/v2/gh/isoverse/isoprocessor/binder?urlpath=rstudio)
[![Binder](https://img.shields.io/badge/launch-Jupyter-orange.svg)](https://mybinder.org/v2/gh/isoverse/isoprocessor/binder?urlpath=lab)

## About

This package provides broad functionality for IRMS data processing and
reduction pipelines.

Existing functionality includes signal conversion (voltage to current
and back), time scaling (continuous flow chromatograms), isotope ratio
calculations, delta value calculations, as well as easy-to-use highly
flexible data calibration and visualization pipelines for continuous
flow data. Additional tools on O17 corrections, H3 factor calculation,
peak detection, baseline correction, etc are in the works. All
implemented functions are well documented and ready for use. However,
since this package is still in active development some syntax and
function names may still change.

## Installation

You can install the dependency
[isoreader](http://isoreader.isoverse.org/) and
[isoprocessor](http://isoprocessor.isoverse.org/) itself both from
GitHub using the `devtools` package. Note that while
[isoprocessor](http://isoprocessor.isoverse.org/) uses some functions
from [isoreader](http://isoreader.isoverse.org/), it does NOT require
IRMS data to be read with [isoreader](http://isoreader.isoverse.org/),
it can be used standalone with raw data obtained differently.

``` r
install.packages("devtools") # only if you don't have this installed yet
devtools::install_github("isoverse/isoreader")
devtools::install_github("isoverse/isoprocessor")
```

## Functionality

  - for a full reference of all available functions, see the **[Function
    Reference](http://isoprocessor.isoverse.org/reference/)**
  - for an example of how to work with continuos flow data, see the
    vignette on **[Continuous
    Flow](http://isoprocessor.isoverse.org/articles/continuous_flow.html)**
  - for an example of how to work with dual inlet data, see the vignette
    on **[Dual
    Inlet](http://isoprocessor.isoverse.org/articles/dual_inlet.html)**
  - additional vignettes on data reduction and calibration are in the
    works

## Open Source

[isoprocessor](http://isoprocessor.isoverse.org/) is and will always be
fully open-source (i.e. free as in ‘freedom’ and free as in ‘free beer’)
and is provided as is. The source code is released under
GPL-2.

## isoverse <a href='http://www.isoverse.org'><img src='man/figures/isoverse_logo_thumb.png' align="right" height="138.5"/></a>

This package is part of the isoverse suite of data tools for stable
isotopes.
