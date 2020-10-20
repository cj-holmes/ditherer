
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ditherer

This is a very early work in progress. EXPERIMENTAL\!

Now using `magick` as the main engine

## Installation

``` r
remotes::install_github('cj-holmes/ditherer)
```

## Example

``` r
library(ditherer)
```

Test image Lenna

``` r
img <- 'data-raw/lenna.png'
dither(img, dither = "ordered")
```

![](man/figures/README-example1-1.png)<!-- -->

``` r
dither(img, dither = "diffusion")
```

![](man/figures/README-example1-2.png)<!-- -->

``` r
dither(img, dither = "none")
```

![](man/figures/README-example1-3.png)<!-- -->

``` r
dither(img, dither = "ordered", target_palette = "greyscale")
```

![](man/figures/README-example1-4.png)<!-- -->
