# Copyright 2018 Province of British Columbia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

#' Make a regular square grid of tiles based on a bounding box
#'
#' @param bbox a bounding box (from `sf::st_bbox` or a named list with elements `xmin`, `xmax`, `ymin`, `ymax`)
#' @param n_rows number of rows (and columns)
#'
#' @return an sf object of tiles
make_tiles <- function(bbox, n_rows) {
  
  # Tile borders by making a sequence from bbox
  x_borders <- seq(bbox$xmin, bbox$xmax, length.out = n_rows + 1)
  y_borders <- seq(bbox$ymin, bbox$ymax, length.out = n_rows + 1)
  
  # Use x and y borders to create a data.frame of xmin, xmax, ymin, ymax.
  tile_dim_df <- cbind(
    expand.grid(xmin = x_borders[1:n_rows],
                ymin = y_borders[1:n_rows]), 
    expand.grid(xmax = x_borders[2:(n_rows + 1)], 
                ymax = y_borders[2:(n_rows + 1)])
  )
  
  # Create a polygon grid of size nTileRows * nTileRows
  # by creating a polygon for each xmin, xmax, ymin, ymax, 
  # convert each into an sf object, and combine: 
  # and combining them
  sf_list <- lapply(seq_len(nrow(tile_dim_df)), function(i) {
    st_sf(tile_id = i, bb_to_sfc_poly(tile_dim_df[i, ], crs = 3005), crs = 3005)
  })
  
  do.call("rbind", sf_list)
}

#' Function to convert a bounding box to a sfc polygon object
#'
#' @param bb a bounding box or list with xmin, xmax, ymin, ymax elements
#' @param crs a number with epsg code or proj4string
bb_to_sfc_poly <- function(bb, crs) {
  if (!inherits(bb, "bbox")) {
    bb <- st_bbox(c(
      xmin = bb$xmin, 
      xmax = bb$xmax,
      ymin = bb$ymin,
      ymax = bb$ymax
    ))
  }
  st_as_sfc(bb)
}
