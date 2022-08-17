library(tidyverse)

t1 = read_tsv("coral-microbiome-labels.tsv")
glimpse(t1)

t2 = read_tsv("coral-microbiome-relationship.tsv")
glimpse(t2)

t3 = t1 %>% anti_join(t2) %>% select (node) %>% arrange(node)
glimpse(t3)

write_tsv(t3, "coral-microbiome-not-related.tsv")

t3 = t1 %>% left_join(t2)
glimpse(t3)

t4 = t3 %>% mutate (label = ifelse(is.na(relationship), "", label))
glimpse(t4)

t5 = t4 %>% select (-relationship)
glimpse(t5)

write_tsv(t5, "coral-microbiome-labels-selected.tsv")
