# check index year proportions for target and comparator

library(dplyr)
library(ggplot2)

respath = 'E:/LegendMonotherapy_ccae/shinyData'
fname = 'covariate_balance_t3010_c3011_CCAE.rds'

# ACE: 3010
# THZ: 3011

balance = readRDS(file.path(respath, fname))

years = balance %>% 
  filter(covariate_id %% 1000 == 6, analysis_id == 1) %>% 
  group_by(covariate_id) %>% 
  summarize(target_mean_before = mean(target_mean_before), 
            comparator_mean_before = mean(comparator_mean_before)) %>% 
  ungroup() %>% 
  select(covariate_id, target_mean_before, comparator_mean_before) %>% 
  mutate(year = covariate_id %/% 1000) %>%
  arrange(year) 
years

years_long = data.frame(year = rep(years$year, 2),
                        percentage = c(years$target_mean_before, 
                                       years$comparator_mean_before),
                        drug = rep(c('ACEi','THZ')))

capt = sprintf('database: IBM_CCAE\nACEi subjects: %s\nTHZ subjects:%s',
               1229898, 968231)

ggplot(years_long, aes(x=year, y=percentage, fill=drug)) +
  geom_bar(stat = 'identity') +
  labs(fill='', caption = capt)+
  facet_grid(drug~.)+
  theme_bw(base_size = 14)
