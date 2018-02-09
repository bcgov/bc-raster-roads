library(sf)
library(dplyr)
library(readr)

## Ensure you have run 01_load.R before you run this
roads_sf <- readRDS("tmp/DRA_roads_sf.rds")
road_types <- read_csv("data/TRANSPORT_LINE_TYPE_CODE.csv")

roads_sf <- 
  roads_sf %>% 
  mutate(rd_len = st_length(.))
sum(roads_sf$rd_len)

length_by_type <- roads_sf %>% 
  st_set_geometry(NULL) %>% 
  group_by(TRANSPORT_LINE_TYPE_CODE) %>% 
  summarise(total_length = as.numeric(units::set_units(sum(rd_len), km))) %>% 
  left_join(road_types, by = "TRANSPORT_LINE_TYPE_CODE") %>% 
  select(TRANSPORT_LINE_TYPE_CODE, DESCRIPTION, total_length)

write_csv(length_by_type, "out/roads_by_type_summary.csv")
