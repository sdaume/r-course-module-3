# data is based on Scopus searches for publications with SRC affiliations
#
# this script prepares an cleaned and annotated dataset for an STM topic
# modellign exercise

###############################################################################################
# LOAD THE DOCUMENTS
###############################################################################################

src_pubs_1 <- readr::read_csv("./topicmodels/data-raw/scopus-src-2022-2023.csv",
                              name_repair = "universal",
                              col_types = "c")

src_pubs_2 <- readr::read_csv("./topicmodels/data-raw/scopus-src-2004-2021.csv",
                              name_repair = "universal",
                              col_types = "c")


# combines the two files, filters publications with missing abstracts,
# renames variable names for consistency, assigns a document ID and creates
# additional variables that can be used as covariates in an STM topic model
# (specifically whether the paper is open access or not, whether the first
# author has SRC has the main affiliation, in which phase of SRC's history
# the publication was published, and the number of authors)

src_pubs <- rbind(src_pubs_1, src_pubs_2) %>%
  select(Author.s..ID, Affiliations, Title, Abstract, Year, Open.Access) %>%
  rename_all(tolower) %>%
  filter(!stringr::str_detect(abstract, pattern = "No abstract available")) %>%
  #mutate(pub_date = lubridate::ymd(year, truncated = 4L)) %>%
  mutate(open_access = case_when(is.na(open.access) ~ "non-open access",
                                 TRUE ~ "open access")) %>%
  #mutate(open_access = ifelse(is.na(open.access), 0, 1)) %>%
  mutate(n_authors = stringr::str_count(author.s..id, ";")) %>%
  mutate(first_author_src = stringr::str_detect(affiliations,
                                                pattern = stringr::regex(pattern = "^Stockholm Resilience Cent",
                                                                         ignore_case = TRUE))) %>%
  mutate(src_author_role = case_when(first_author_src ~ "SRC lead",
                                     TRUE ~ "SRC collaborator(s)")) %>%
  mutate(organisation_phase = case_when(year <= 2010 ~ "1",
                                        year > 2010 & year <= 2014 ~ "2",
                                        year > 2014 & year <= 2018 ~ "3",
                                        year > 2018 ~ "4",
                                        TRUE ~ "NA")) %>%
  mutate(organisation_phase = as.numeric(organisation_phase)) %>%
  mutate(organisation_phase_label = case_when(year <= 2010 ~ "foundation",
                                        year > 2010 & year <= 2014 ~ "growth",
                                        year > 2014 & year <= 2018 ~ "establishment",
                                        year > 2018 ~ "consolidation",
                                        TRUE ~ "NA")) %>%
  select(-author.s..id, -open.access, -affiliations) %>%
  mutate(doc_id = row.names(.)) %>%
  select(doc_id, year, title, abstract, n_authors, src_author_role, open_access, organisation_phase, organisation_phase_label)


readr::write_csv(src_pubs, "src_pubs_annotated.csv")
