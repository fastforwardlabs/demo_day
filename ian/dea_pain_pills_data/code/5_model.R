# R script to investigate patterns between the
# average per-capita pills per year by county and
# other county-level variables from US Census data

# Ian Cook
# 2019-07-25

library(dplyr)
library(readr)
library(purrr)
library(broom)

# load county-level pain pills data
arcos_by_county <- read_csv(
  file = "data/arcos_by_county_sorted.csv",
  col_types = "ccciiii"
) %>%
select(-population)

# load and clean up county-level Census data
census <- 
  readRDS("data/census.rds") %>%
  select(
    STCOU,      # FIPS 
    AGE010210D, # Resident population (April 1 - complete count) 2010
    INC110209D, # Median household income in the past 12 months (in 2009 inflation-adjusted dollars) in 2005-2009
    IPE110209D, # People of all ages in poverty - number 2009
    POP150210D, # Male population 2010 (complete count)
    POP110200D, # Urban population 2000 (sample)
    EDU630200D, # Educational attainment - persons 25 years and over completing 12 years or more of school 2000
    CRM110208D, # Number of violent crimes known to police 2008
    ELE035208D, # Votes cast for Republicans 
    POP220210D, # Population of one race - White alone 2010 (complete count)
    CLF040210D, # Civilian labor force unemployment rate 2010
    POP645209D, # Place of birth, foreign-born, percent,  2005-2009
    POP060210D, # Population per square mile 2010
    HEA720207D, # All persons 18 to 64 years with health insurance 2007
    VET605209D # Veterans - total 2005-2009
  ) %>% transmute(
    fips = STCOU,
    population = AGE010210D,
    income = INC110209D,
    poverty = IPE110209D / population,
    male = POP150210D / population,
    urban = POP110200D / population,
    education = EDU630200D / population,
    crime = CRM110208D / population,
    republican_vote = ELE035208D,
    white = POP220210D / population,
    unemployment = CLF040210D / 100,
    foreign = POP645209D / 100,
    density = POP060210D,
    insurance = HEA720207D / population,
    veterans = VET605209D / population
  )

# note: Puerto Rico is not present in the Census data

# join the pain pills data with the Census data
formodels <- arcos_by_county %>% 
  inner_join(census, by = "fips")

# compute Spearman's rank correlation coefficient
# pairwise for each indepdent variable versus the dependent variable
map_dfr(c("income","poverty","male","urban","education",
          "crime","republican_vote","white","unemployment",
          "foreign","density","insurance","veterans"),
  function(xvar) {
    suppressWarnings(
      res <- tidy(cor.test(
        x = formodels[,xvar,drop = TRUE],
        y = formodels$pills_per_person_per_year,
        method = "spearman"
      )
    ))
    res %>%
      select(estimate, p.value) %>%
        mutate(
          x = xvar,
          y = "pills_per_person_per_year",
        ) %>%
        select(y, x, everything())
  }) %>%
  arrange(estimate)

# fit a linear regression model,
# (excluding a few of the independent variables)
model <- lm(
  pills_per_person_per_year ~ 
    income + 
    #poverty +
    male + 
    #urban + 
    education + 
    crime + 
    republican_vote + 
    white + 
    unemployment + 
    # foreign + 
    density + 
    insurance +
    veterans,
  data = formodels
)

summary(model)

# create a scatter plot matrix
# which is a matrix of plots like
# `plot(x = scatter$pills, y = scatter$income)`
# for every pair of variables
scatter <- formodels %>%
  select(
    pills = pills_per_person_per_year,
    income, male, education, crime,
    republican = republican_vote,
    white, unemployment, density, insurance, veterans
  )
pairs(
  scatter,
  pch = 1,
  cex = 0.2,
  col = rgb(r = 0, g = 0, b = 0, a = 0.05)
)
