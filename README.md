
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ditherer

This is a very early work in progress. EXPERIMENTAL\!

Now using `magick` as the main engine

## Installation

``` r
remotes::install_github('cj-holmes/ditherer)
```

``` r
library(ditherer)
```

Test image

``` r
img <- 'data-raw/lenna.png'
```

Default settings are to extract a 16 colour palette from the original
(resized image)

## Ordered dithering (default)

``` r
dither(img, original = TRUE)
dither(img, dither = "ordered")
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="50%" /><img src="man/figures/README-unnamed-chunk-5-2.png" width="50%" />

## Error diffusion dithering

``` r
dither(img, original = TRUE)
dither(img, dither = "diffusion")
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="50%" /><img src="man/figures/README-unnamed-chunk-6-2.png" width="50%" />

## No dithering

``` r
dither(img, original = TRUE)
dither(img, dither = "none")
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="50%" /><img src="man/figures/README-unnamed-chunk-7-2.png" width="50%" />
