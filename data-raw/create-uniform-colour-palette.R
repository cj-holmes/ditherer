library(tidyverse)

# s <- 51
s <- 85

uniform_cols <-
  crossing(r = seq(0, 255, by=s),
         g = seq(0, 255, by=s),
         b = seq(0, 255, by=s)) %>%
  mutate(col = pmap_chr(list(r, g, b), ~rgb(..1, ..2, ..3, maxColorValue = 255))) %>%
  arrange(r, g, b) %>%
  pull(col)

tibble(c = uniform_cols) %>%
  ggplot(aes("", fill = c))+
  geom_bar()+
  scale_fill_identity()+
  coord_flip()+
  theme_void()

usethis::use_data(uniform_cols, overwrite = TRUE)
