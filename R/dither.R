#' Produce an image with ordered dithering
#'
#' An implementation of ordered image dithering using the bayer matrix
#'
#' @param img path or URL to image
#' @param res Horixontal resolution of output image in pixels (default = 200)
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
#' @param n Number of oclours to be used (default = 16) if target palette is set to 'extract' or 'greyscale'
#' @param dither One of
#' \itemize{
#'   \item "ordered" - Ordered dithering using a bayer matrix (default)
#'   \item "diffusion" - Floyd/Steinberg error diffusion dithering
#'   \item "none" - No dithering
#'   }
#'
#' @export
dither <- function(img,
                   res = 200,
                   scale = NULL,
                   target_palette = "extract",
                   n = 16,
                   bayer_size = 3,
                   seed = NULL,
                   dither = "ordered",
                   original = FALSE){

  # Resize image and save info ----------------------------------------------
  i <-
    magick::image_read(img) %>%
    magick::image_scale(geometry = ifelse(is.null(scale),
                                             magick::geometry_size_pixels(width=res),
                                             magick::geometry_size_percent(width = scale)))

  # Compute information on resized image
  info_out <- magick::image_info(i)


  # Define the target image -------------------------------------------------
  if(length(target_palette) == 1 && target_palette == "extract"){
    t <- magick::image_quantize(i, max = n, treedepth = 0)

    } else if(length(target_palette) == 1 && target_palette == "greyscale"){
      t <- matrix(grey.colors(n, 0, 1), nrow=1) %>% magick::image_read()

    }else{
      t <- matrix(target_palette, nrow=1) %>% magick::image_read()

      }

  # Create dither matrix ----------------------------------------------------
  if(dither == "ordered"){
    dm <-
      bayer(bayer_size) %>%
      norm_bayer() %>%
      rep_mat(nrow_out = info_out[["height"]],
              ncol_out = info_out[["width"]]) %>%
      as.vector() %>%
      magrittr::subtract(0.5)

    pos_dither <-
      replace(dm, sign(dm) != 1, values = 0) %>%
      magrittr::multiply_by(255/n) %>%
      rgb(., ., ., maxColorValue = 255) %>%
      matrix(nrow = info_out[["height"]],
             ncol = info_out[["width"]]) %>%
      magick::image_read()

    neg_dither <-
      replace(dm, sign(dm) != -1, values = 0) %>%
      abs() %>%
      magrittr::multiply_by(255/n) %>%
      rgb(., ., ., maxColorValue = 255) %>%
      matrix(nrow = info_out[["height"]],
             ncol = info_out[["width"]]) %>%
      magick::image_read()

    # Apply dither and generate plot
    p <-
      magick::image_composite(neg_dither,
                              magick::image_composite(i, pos_dither, operator = "Plus"),
                              operator = "Minus") %>%
      magick::image_map(t) %>%
      magick::image_raster()

  } else if(dither == "diffusion"){
    p <-
      i %>%
      magick::image_map(t, dither = TRUE) %>%
      magick::image_raster()

  } else if(dither == "none"){
    p <- i %>% magick::image_map(t, dither = FALSE) %>% magick::image_raster()

  } else {
    stop('dither options are "ordered", "diffusion" or "none"')

  }

  p %>%
    ggplot2::ggplot(ggplot2::aes(x, y, fill = col)) +
    ggplot2::geom_raster()+
    ggplot2::scale_y_reverse()+
    ggplot2::scale_fill_identity()+
    ggplot2::coord_equal()+
    ggplot2::theme_void()
  }
