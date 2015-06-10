#' Cartesian coordinates with an aspect ratio approximating Mercator projection.
#'
#' The represenation of a portion of the earth, wich is approximately spherical,
#' onto a flat 2D plane requires a projection. This is what
#' \code{\link{coord_map}} does. These projections account for the fact that the
#' actual length (in km) of one degree of longitude varies between the equator
#' and the pole. Near the equator, the ratio between the lengths of one degree
#' of latitude and one degree of longitude is approximately 1. Near the pole, it
#' is tends towards infinity because the length of one degree of longitude tends
#' towards 0. For regions that span only a few degrees and are not too close to
#' the poles, setting the aspect ratio of the plot to the appropriate lat/lon
#' ratio approximates the usual mercator projection. This is what
#' \code{coord_quickmap} does. With \code{\link{coord_map}} all elements of the
#' graphic have to be projected which is not the case here. So
#' \code{\link{coord_quickmap}} has the advantage of being much faster, in
#' particular for complex plots such as those using with
#' \code{\link{geom_tile}}, at the expense of correctedness in the projection.
#'
#' @export
#' @inheritParams coord_cartesian
#' @examples
#' # ensures that the ranges of axes are equal to the specified ratio by
#' # adjusting the plot aspect ratio
#' 
#' if (require("maps")) {
#' # Create a lat-long dataframe from the maps package
#' nz <- map_data("nz")
#' # Prepare a plot of the map
#' nzmap <- ggplot(nz, aes(x = long, y = lat, group = group)) +
#'   geom_polygon(fill = "white", colour = "black")
#'
#' # Plot it in cartesian coordinates
#' nzmap
#' # With correct mercator projection
#' nzmap + coord_map()
#' # With the aspect ratio approximation
#' nzmap + coord_quickmap()
#' }
#' 
#' # Resize the plot to see that the specified aspect ratio is maintained
coord_quickmap <- function(xlim = NULL, ylim = NULL) {
  coord(limits = list(x = xlim, y = ylim),
    subclass = c("quickmap", "cartesian"))
}

#' @export
coord_aspect.quickmap <- function(coord, ranges) {
  # compute coordinates of center point of map
  x.center <- sum(ranges$x.range) / 2
  y.center <- sum(ranges$y.range) / 2

  # compute distance corresponding to 1 degree in either direction
  # from the center
  x.dist <- dist_central_angle(x.center + c(-0.5, 0.5), rep(y.center, 2))
  y.dist <- dist_central_angle(rep(x.center, 2), y.center+c(-0.5, 0.5))
  # NB: this makes the projection correct in the center of the plot and
  #     increasingly less correct towards the edges. For regions of reasonnable
  #     size, this seems to give better results than computing this ratio from
  #     the total lat and lon span.

  # scale the plot with this aspect ratio
  ratio <- y.dist / x.dist

  diff(ranges$y.range) / diff(ranges$x.range) * ratio
}