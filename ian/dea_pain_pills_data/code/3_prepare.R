# R script to prepare ARCOS data for county-level analysis

# Ian Cook
# 2019-07-25

library(implyr)
library(readr)

impala <- src_impala(odbc::odbc(), dsn = "Impala DSN")

# compute number of pills, pills per person per year,
# population, and number of pharmacies by county,
# excluding the 100 largest non-community pharmacies

arcos <- 
  tbl(impala, in_schema("arcos","arcos_clean"))
buyers_to_exclude <- 
  tbl(impala, in_schema("arcos","buyers_to_exclude"))
population_by_county <- 
  tbl(impala, in_schema("arcos","population_by_county"))

arcos_by_county_sorted <- arcos %>%
  anti_join(
    buyers_to_exclude,
    by = "buyer_dea_no"
  ) %>%
  left_join(
    population_by_county,
    by = c("buyer_state" = "state", "buyer_county" = "county")
  ) %>%
  group_by(fips) %>%
  summarise(
    buyer_state = max(buyer_state),
    buyer_county = max(buyer_county),
    num_pills = round(sum(dosage_unit)),
    pills_per_person_per_year = 
      round(sum(dosage_unit) / max(population) / 7),
    population = max(population),
    num_pharmacies = n_distinct(buyer_dea_no)
  ) %>%
  arrange(desc(pills_per_person_per_year)) %>%
  collect() %>%
  mutate(
    num_pills = as.integer(num_pills),
    pills_per_person_per_year = 
      as.integer(pills_per_person_per_year),
    num_pharmacies = as.integer(num_pharmacies)
  )

# save the result
write_csv(
  arcos_by_county_sorted,
  "data/arcos_by_county_sorted.csv"
)

dbDisconnect(impala)

# view the data
arcos_by_county_sorted %>% head(100) %>% as.data.frame()
