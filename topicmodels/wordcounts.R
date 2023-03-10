library(topicsplorrr)
library(dplyr)


src_pubs <- readr::read_csv("./topicmodels/data/src_pubs_annotated.csv",
                            col_types = "c") %>%
  mutate(pub_date = lubridate::ymd(year, truncated = 4L))


pub_stats <- src_pubs %>%
  count(year, organisation_phase)


# extract unigrams
src_unigrams <- unigrams_by_date(textData = src_pubs,
                                 textColumn = "title",
                                 dateColumn = "year") %>%
  count(term) %>%
  arrange(-n)

src_bigrams <- bigrams_by_date(textData = src_pubs,
                               textColumn = "title",
                               dateColumn = "year") %>%
  count(term) %>%
  arrange(-n)


terms_by_date(textData = src_pubs,
              textColumn = "title",
              dateColumn = "pub_date",
              tokenType = "unigram") %>%
  plot_term_frequencies(timeBinUnit = "year", topN = 9, nCols = 3,
                        minTermTimeBins = 0)

terms_by_date(textData = src_pubs,
              textColumn = "title",
              dateColumn = "pub_date",
              tokenType = "bigram") %>%
  plot_term_frequencies(timeBinUnit = "year", topN = 9, nCols = 3,
                        minTermTimeBins = 0)



