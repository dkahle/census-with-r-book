library(tidycensus)
library(tidyverse)
library(tigris)
library(sf)
library(ggbeeswarm)
library(viridis)
library(extrafont)
options(tigris_use_cache = TRUE)

df <- get_acs(geography = "tract", state = c("IL", "IN", "WI"),   
              variables = c("B03002_012", "B03002_003", "B03002_004", "B03002_005", 
                            "B03002_006"), 
              summary_var = "B19013_001", geometry = TRUE) %>%
  mutate(variable = recode(variable, B03002_003 = "White", 
                           B03002_004 = "Black", 
                           B03002_005 = "Native American", 
                           B03002_006 = "Asian", 
                           B03002_012 = "Hispanic")) %>%
  group_by(GEOID) %>%
  filter(estimate == max(estimate, na.rm = TRUE)) %>%
  ungroup() %>%
  filter(estimate != 0)

metro <- core_based_statistical_areas(cb = TRUE, class = "sf") %>%
  filter(str_detect(NAME, "Chicago"))

chi <- df[metro, op = st_within]

ggplot(chi, aes(x = variable, y = summary_est, color = summary_est)) +
  geom_quasirandom(alpha = 0.9) + 
  coord_flip() + 
  theme_minimal(base_family = "Tahoma") + 
  scale_color_viridis(guide = FALSE) + 
  scale_y_continuous(labels = scales::dollar) + 
  labs(x = "Largest group in Census tract", 
       y = "Median household income", 
       title = "Household income distribution by largest racial/ethnic group", 
       subtitle = "Census tracts, Chicago metropolitan area", 
       caption = "Data source: 2011-2015 ACS")

ggsave("plots/beeswarm_tulsa.png")