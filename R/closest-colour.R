#' Closest colour
#'
#' Not exported - not for use by the user
#'   For computing the nearest target palette colour to a given colour
#'
#' @param r actual r (length 1)
#' @param g actual g (length 1)
#' @param b actual b (length 1)
#' @param tp_r target palette reds (vector)
#' @param tp_g target palette greens (vector)
#' @param tp_b target palette blues (vector)
#' @param target_palette target palette vector of colours (string)
closest_colour <- function(r,g,b, tp_r, tp_g, tp_b, target_palette){

  t <- sqrt((r - tp_r)^2 + (g - tp_g)^2 + (b - tp_b)^2)

  target_palette[t == min(t)][1]
}
