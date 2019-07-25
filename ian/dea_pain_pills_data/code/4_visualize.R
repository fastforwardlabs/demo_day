# R script to visualize the ARCOS data by county

# Ian Cook
# 2019-07-25

library(readr)
library(dplyr)
library(ggplot2)
library(sf)
library(urbnmapr)
library(urbnthemes)


# load county-level pain pills data
arcos_by_county <- read_csv(
  file = "data/arcos_by_county_sorted.csv",
  col_types = "ccciiii"
)

# load county map and join with pain pills data
formaps <- 
  get_urbn_map(map = "counties", sf = TRUE) %>% 
  right_join(
    arcos_by_county,
    by = c("county_fips" = "fips")
  )

# set map theme
suppressWarnings(set_urbn_defaults(style = "map"))

# create the map
ggplot(formaps) +
  geom_sf(
    aes(fill = pills_per_person_per_year),
    color = "#FFFFFF",
    size = 0.02
  ) +
 scale_fill_gradient2(
   low = "#FFFFFF",
   mid = "#FFEEFF",
   high = "#B6009E",
   na.value = "#FFFFFF"
 ) +
 geom_sf(
   get_urbn_map("states", sf = TRUE),
   mapping = aes(),
   fill = NA,
   color = "#000000",
   size = 0.05
 ) +
 labs(fill = "pills/person/year")
