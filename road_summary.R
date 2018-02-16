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

library(sf) # spatial object
library(dplyr) # data munging
library(readr) # load data
library(ggplot2) # plotting, dev version from GitHub for geom_sf
library(forcats) # reorder factors
library(bcmaps) # bc_bound()
library(RColorBrewer) # colour palette
library(envreportutils) # theme_soe()
library(patchwork) # multiplot
library(R.utils) # capitalize

## Ensure you have run 01_load.R before you run this
## Load data files from local folders
roads_sf <- readRDS("tmp/DRA_roads_sf.rds")
road_types <- read_csv("data/TRANSPORT_LINE_TYPE_CODE.csv")
road_surfaces <- read_csv("data/TRANSPORT_LINE_SURFACE_CODE.csv")
  
## Add a new colomn with total length of each road segment
roads_sf <- 
  roads_sf %>%
  mutate(rd_len = st_length(.))

## Sum of road segment lengths
total_length_roads <- units::set_units(sum(roads_sf$rd_len), km) %>% 
  round(digits = 0) %>% 
  scales::comma()

## Sum of ALL road segment lengths by TRANSPORT_LINE_TYPE_CODE
length_by_type <- roads_sf %>%
  st_set_geometry(NULL) %>%
  group_by(TRANSPORT_LINE_TYPE_CODE) %>%
  summarise(total_length = as.numeric(units::set_units(sum(rd_len), km))) %>%
  left_join(road_types, by = "TRANSPORT_LINE_TYPE_CODE") %>%
  select(TRANSPORT_LINE_TYPE_CODE, DESCRIPTION, total_length)

## Sum of ALL road segment lengths by TRANSPORT_LINE_SURFACE_CODE
length_by_surface <- roads_sf %>%
  st_set_geometry(NULL) %>%
  group_by(TRANSPORT_LINE_SURFACE_CODE) %>%
  summarise(total_length = as.numeric(units::set_units(sum(rd_len), km))) %>%
  left_join(road_surfaces, by = "TRANSPORT_LINE_SURFACE_CODE") %>%
  select(TRANSPORT_LINE_SURFACE_CODE, DESCRIPTION, total_length)

## Write out summary CSV file
write_csv(length_by_type, "out/roads_by_type_summary.csv")
write_csv(length_by_surface, "out/roads_by_surface_summary.csv")

## Filter out some transport line types & surfaces
exclude_surface <- c("O", "B") ## overgrown &  boat, also consider decommisioned?
exclude_type <- c("T", "TD", "FR", "F", "FP") ## trail, trail demographic, ferry, ferry resource, ferry passenger, also consider TR, RP and TS?

soe_roads <- roads_sf %>% 
  filter(!TRANSPORT_LINE_TYPE_CODE %in% exclude_type) %>% 
  filter(!TRANSPORT_LINE_SURFACE_CODE %in% exclude_surface) 

soe_roads_summary <-  soe_roads %>% 
  st_set_geometry(NULL) %>%
  group_by(TRANSPORT_LINE_SURFACE_CODE) %>%
  summarise(total_length = as.numeric(units::set_units(sum(rd_len), km))) %>%
  left_join(road_surfaces, by = "TRANSPORT_LINE_SURFACE_CODE") %>%
  select(TRANSPORT_LINE_SURFACE_CODE, DESCRIPTION, total_length) %>% 
  mutate(DESCRIPTION = R.utils::capitalize(DESCRIPTION))
soe_roads_summary

## Bar chart of roads by surface type
## creating a colour brewer palette from http://colorbrewer2.org/
# colrs <- brewer.pal(6, "Paired")
colrs <- c("D" = "#e31a1c",
           "L" = "#b2df8a",
           "P" = "grey30",
           "R" = "#33a02c",
           "S" = "#fdbf6f",
           "U" = "#ffff99")

names(colrs) <- unique(soe_roads_summary$TRANSPORT_LINE_SURFACE_CODE)

soe_roads_sum_chart <- soe_roads_summary %>% 
  ggplot(aes(fct_reorder(DESCRIPTION, total_length), total_length/1000)) +
  geom_col(aes(fill = TRANSPORT_LINE_SURFACE_CODE)) +
  scale_fill_manual(values = colrs, labels = unique(soe_roads_summary$DESCRIPTION),
                    guide = FALSE) +
    theme_soe() +
    coord_flip() +
    labs(x = "", y = "Total Length (km * 1000)", title = "Total Length of Roads in B.C. by Road Surface Type",
         subtitle = paste0("B.C. has ", total_length_roads, " of roads")) +
    scale_y_continuous(expand = c(0, 0)) +
    theme(panel.grid.major.y = element_blank(),
          axis.text = element_text(size = 12),
          axis.title = element_text(size = 14),
          plot.subtitle = element_text(size = 12),
          plot.margin = unit(c(30, 5, 30, 5), "mm"))
plot(soe_roads_sum_chart)

## Plot of BC with soe_roads
# plot(st_geometry(soe_roads))
# plot(soe_roads[, "TRANSPORT_LINE_SURFACE_CODE"])

# soe_roads %>% 
#   select(TRANSPORT_LINE_SURFACE_CODE) %>% 
#   plot()
# plot(st_geometry(bc), add = TRUE)

# soe_roads_testing <- soe_roads %>% 
#   filter(TRANSPORT_LINE_SURFACE_CODE == "S")

## ggplot2 dev version
soe_roads_map <- ggplot() +
  geom_sf(data = bc_bound(), fill = NA, size = 0.2) +
    geom_sf(data = soe_roads, aes(colour = TRANSPORT_LINE_SURFACE_CODE), size = 0.1) +
  coord_sf(datum = NA) +
  scale_colour_manual(values = colrs, guide = FALSE) +
    theme_minimal()
# plot(soe_roads_map)

## data = soe_roads[1:1000,] ## using small subset for plot iteration

# X11(type = "cairo")
# plot(soe_road_map)

## Saving plots
png_retina(filename = "./out/soe_roads_by_surface.png", width = 500, height = 500, units = "px", type = "cairo-png")
plot(soe_roads_sum_chart)
dev.off()

png_retina(filename = "./out/soe_roads_map.png", width = 500, height = 500, units = "px", type = "cairo-png")
plot(soe_roads_map)
dev.off()

png_retina(filename = "./out/soe_roads_viz.png", width = 900, height = 600, units = "px", type = "cairo-png")
soe_roads_sum_chart + soe_roads_map + plot_layout(ncol = 2, widths = c(.6, 1.2))
dev.off()
