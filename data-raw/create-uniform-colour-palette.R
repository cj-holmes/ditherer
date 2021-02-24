library(tidyverse)

s <- 51

c216 <-
  crossing(r = seq(0, 255, by=s),
           g = seq(0, 255, by=s),
           b = seq(0, 255, by=s)) %>%
  mutate(col = pmap_chr(list(r, g, b), ~rgb(..1, ..2, ..3, maxColorValue = 255))) %>%
  arrange(r, g, b) %>%
  pull(col)

tibble(c = c216) %>%
  ggplot(aes("", fill = c))+
  geom_bar()+
  scale_fill_identity()+
  coord_flip()+
  theme_void()



s <- 85

c64 <-
  crossing(r = seq(0, 255, by=s),
         g = seq(0, 255, by=s),
         b = seq(0, 255, by=s)) %>%
  mutate(col = pmap_chr(list(r, g, b), ~rgb(..1, ..2, ..3, maxColorValue = 255))) %>%
  arrange(r, g, b) %>%
  pull(col)

tibble(c = c64) %>%
  ggplot(aes("", fill = c))+
  geom_bar()+
  scale_fill_identity()+
  coord_flip()+
  theme_void()

usethis::use_data(c216, c64, overwrite = TRUE)
