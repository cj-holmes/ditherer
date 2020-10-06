#' Produce an image with ordered dithering
#'
#' An implementation of ordered image dithering using the bayer matrix
#'
#' @param img path or URL to image
#' @param res Horixontal resolution of output image in pixels (default = 220)
#'   This is only used if scale = NULL (which is the default behaviour). The reason for this is to try and
#'   prevent very large images being processed by accident (large images will be slow to dither)
#' @param target_palette A target palette of colours for the output image. One of
#' \itemize{
#'   \item 'extract' (default) = A colour palette of length n is extracted from the image
#'   \item 'greyscale' = A greyscale palette of length n is used
#'   \item A character vector of colours = The vector of colours is used as is
#'   }
#' @param scale Scaling percentage (default = NULL).
#'   If scale is not NULL, it overides the value of res. Full size = 100, half size = 50 etc.
#' @param bayer_size bayer matrix size (square matrix of side length 2^bayer_size)
#' @param n Number of oclours to be used (default = 6) if target palette is set to 'extract' or 'greyscale'
#' @param seed A seed for reproducability if target_palette is set to 'extract' (default = NULL)
#' @param dither Should dithering be applied, logical (default = TRUE)
#' @param original Print original (resized) picture colours (defaul = FALSE)
#'
#' @export
dither <- function(img,
                   res = 220,
                   scale = NULL,
                   target_palette = "extract",
                   n = 6,
                   bayer_size = 3,
                   seed = NULL,
                   dither = TRUE,
                   original = FALSE){

  # Save raw image
  i <- imager::load.image(img)

  # Extract aspect ratio of raw image
  asp <- imager::height(i)/imager::width(i)

  # Resize, convert to dataframe and spread to wide format R,G,B columns
  i <-
    i %>%
    imager::resize(size_y = ifelse(is.null(scale), res*asp, -scale),
                   size_x = ifelse(is.null(scale), res, -scale)) %>%
    as.data.frame() %>%
    tidyr::spread(k=cc, v=value) %>%
    dplyr::rename(r = `1`, g = `2`, b = `3`)

  if(original){
    return(
      i %>%
        dplyr::mutate(original = purrr::pmap_chr(list(r,g,b), rgb)) %>%
        ggplot2::ggplot()+
        ggplot2::geom_raster(ggplot2::aes(x, y, fill=original))+
        ggplot2::coord_fixed()+
        ggplot2::scale_y_reverse()+
        ggplot2::scale_fill_identity()+
        ggplot2::theme_void()
    )
  }


  # Get target palette
  if(length(target_palette) == 1 && target_palette == "extract"){

    if(!is.null(seed)){set.seed(seed)}
    km <- i %>% dplyr::select(r, g, b) %>% kmeans(n)
    target_palette <- apply(km$centers, MARGIN = 1, FUN = function(x) rgb(x[1], x[2], x[3]))

    }else if(length(target_palette) == 1 && target_palette == "greyscale"){

      target_palette <- scales::grey_pal(start=0.2, end=0.8)(n)

      }else{

        target_palette <- target_palette

        }

  # Process target palette
  tp <- lapply(target_palette, function(x) col2rgb(x)/255 %>% as.vector())

  # Create vectors of the indivdual R, G and B values for use later
  tp_r <- sapply(tp, function(x) x[1])
  tp_g <- sapply(tp, function(x) x[2])
  tp_b <- sapply(tp, function(x) x[3])

  # Create dithe rmatrix
  dm <-
    bayer(bayer_size) %>%
    norm_bayer() %>%
    rep_mat(nrow_out = max(i$x),
            ncol_out = max(i$y))

  # Compute factor (set to 0 for no dithering)
  if(dither){f <- 1/length(target_palette)} else {f <- 0}

  # Apply ditherin matrix to each channel (RGB) and then compute nearest colour for each pixel
  # and plot!
  i %>%
    dplyr::arrange(y) %>%
    dplyr::mutate(dm = as.vector(dm) - 0.5) %>%
    dplyr::mutate(r = r + (f * dm),
                  g = g + (f * dm),
                  b = b + (f * dm)) %>%
    dplyr::mutate(dithered = purrr::pmap_chr(list(r, g, b),
                                             ~closest_colour(r=..1, g=..2, b=..3,
                                                             tp_r=tp_r, tp_g=tp_g, tp_b=tp_b,
                                                             target_palette = target_palette))) %>%
    ggplot2::ggplot()+
    ggplot2::geom_raster(ggplot2::aes(x, y, fill=dithered))+
    ggplot2::coord_fixed()+
    ggplot2::scale_y_reverse()+
    ggplot2::scale_fill_identity()+
    ggplot2::theme_void()
  }
