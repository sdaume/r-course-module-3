library(quanteda)
library(quanteda.textstats)
library(stm)
library(dplyr)


###############################################################################################
# LOAD THE DOCUMENTS
###############################################################################################

src_pubs <- readr::read_csv("./topicmodels/data/src_pubs_annotated.csv",
                            col_types = "c")



###############################################################################################
# PREPROCESS THE DOCUMENT SET
###############################################################################################

# create a document corpus
pubs_corpus <- src_pubs %>%
  quanteda::corpus(docid_field = "doc_id", text_field = "abstract")

# tokenize the document corpus (here we use words as tokens)
# AND filter/transform certain tokens
pubs_tokens <- pubs_corpus %>%
  quanteda::tokens(what = "word",
                   remove_punct = TRUE,
                   remove_symbols = TRUE,
                   remove_numbers = TRUE,
                   remove_url = TRUE,
                   remove_separators = TRUE,
                   split_hyphens = TRUE)

# create a document feature matrix and filter the
# features (here by removing common English stopwords)
pubs_dfm <- pubs_tokens %>%
  quanteda::dfm(tolower = TRUE) %>%
  quanteda::dfm_remove(pattern = quanteda::stopwords("english")) %>%
  quanteda::dfm_wordstem()

#dfm_stats <- textstat_frequency(pubs_dfm)


# we can apply additional filtering based to the document feature matrix
# based on feature and document properties, for example by removing rare terms,
# short terms or short documents
pubs_dfm <- pubs_dfm %>%
  quanteda::dfm_remove(min_nchar = 2) %>% # remove terms that are single characters
  quanteda::dfm_trim(min_docfreq = 2, docfreq_type = "count") %>% # remove terms that not appear in at least two documents
  quanteda::dfm_subset(quanteda::ntoken(.) > 2) # remove documents that consist only of two or less tokens

# take a look at the frequency of terms
dfm_stats <- textstat_frequency(pubs_dfm)

#save(pubs_dfm, file = "pubs_dfm.Rdata")



###############################################################################################
# FIT THE TOPIC MODEL
###############################################################################################

# for consistency we use the native STM format; the stm() function actually calls
# quanteda::convert() internally when a DFM is passed, but in order to ensure
# that misalignments of docs and metadata are avoided when reproducing any parts
# of the analysis we explicitly work with the native format
stm_docs <- quanteda::convert(pubs_dfm, to = "stm")

#save(stm_docs, file = "stm_docs.Rdata")

src_topics <- stm(documents = stm_docs$documents,
                  vocab = stm_docs$vocab,
                  data = stm_docs$meta,
                  prevalence = ~ organisation_phase * src_author_role,
                  K = 20,
                  #emtol = 0.000001,
                  #max.em.its = 1000,
                  #control = list("allow.neg.change" = FALSE),
                  #seed = seed_stm,
                  verbose = TRUE)


#save(src_topics, file = "src_topics.Rdata")




###############################################################################################
# INSPECT THE TOPIC MODEL
###############################################################################################

# list most probable words (different groups of words are available)
summary(src_topics)

# plot the topic shares/probabilities using plot.STM
plot(src_topics, n = 5)





###############################################################################################
# ESTIMATE COVARIATE EFFECT
###############################################################################################

# we estimate the covariate effect for all topics according to the prevalence
# formula used when fitting the model
# NOTE: 'uncertainty = "None"' is faster but should not be the default choice
src_topic_effect <- estimateEffect(1:20 ~ organisation_phase * src_author_role,
                                   stmobj = src_topics,
                                   metadata = stm_docs$meta, uncertainty = "None")

#save(src_topic_effect, file = "src_topic_effect.Rdata")

# this summarises the regression stats for the estimated covriate effects
summary(src_topic_effect)




###############################################################################################
# INSPECT THE COVARIATE EFFECT FOR SPECIFIC TOPICS
###############################################################################################


#==============================================================================================
# Example 1: change of topical prevalence during SRC's organisational history
#            using Topic 3 ("sustainable development") and Topic 19 ("baltic sea")
#==============================================================================================

org_phase_values <- src_pubs %>%
  group_by(organisation_phase, organisation_phase_label) %>%
  summarise(n_pubs = n()) %>%
  ungroup()

plot(src_topic_effect,
     covariate = "organisation_phase",
     method = "continuous",
     model = src_topics,
     #printlegend = FALSE,
     ylim = c(0, 0.18),
     topics = c(3, 19),
     xaxt = "n",
     main = 'Effect of organisational phases on prevalence of Topic 3 ("sustainable development") and Topic 19 ("baltic sea") ',
     #labeltype = "prob",
     xlab = "Organisation phase")
axis(1, at = org_phase_values$organisation_phase,
     labels = org_phase_values$organisation_phase_label)



#==============================================================================================
# Example 2: impact of SRC lead authorship on relative topical prevalence
#            using Topic 7 ("social-ecological systems"), Topic 2 ("global governance"),
#            Topic 16 ("planetary boundaries"), Topic 19 ("baltic sea") and
#            Topic 14 ("computational models")
#==============================================================================================

plot(src_topic_effect, covariate = "src_author_role",
     topics = c(7, 2, 16, 19, 14),
     model = src_topics, method = "difference",
     cov.value1 = "SRC lead", cov.value2 = "SRC collaborator(s)",
     xlab = "SRC collaborator(s) ... SRC lead",
     xlim = c(-0.06, 0.06),
     main = "Effect of SRC lead authorship",
     labeltype = "prob")

# plots this for all topics
#plot(src_topic_effect, covariate = "src_author_role",
#     topics = seq.int(1, 20, 1),
#     model = src_topics, method = "difference",
#     cov.value1 = "SRC lead", cov.value2 = "SRC collaborator(s)",
#     xlab = "SRC collaborator(s) ... SRC lead",
#     main = "Effect of SRC lead authorship")


#==============================================================================================
# Example 3: impact of SRC lead authorship on absolute topical prevalence
#            using Topic 14 ("computational models")
#==============================================================================================

plot(src_topic_effect, covariate = "src_author_role",
     topics = c(14),
     model = src_topics, method = "pointestimate",
     cov.value1 = "SRC lead", cov.value2 = "SRC collaborator(s)",
     xlab = "SRC collaborator(s) ... SRC lead",
     main = "Effect of SRC lead authorship",
     #xlim = c(0, 0.08),
     labeltype = "prob")




#==============================================================================================
# Example 4: combined effect of SRC lead authorship and organisational phase on
#            topical prevalence Topic 16 ("planetary boundaries")
#==============================================================================================


# test for example
# 1 fisheries
# 16 pb
# 19 baltic sea
# 4 cities
# 17 food
plot(src_topic_effect,
     topics = c(16),
     covariate = "organisation_phase",
     model = src_topics,
     ci.level = 0.95,
     method = "continuous",
     moderator = "src_author_role",
     moderator.value = "SRC lead",
     linecol = "#eb7125", lwd = 4,
     xlab = "Organisational phase",
     ylim = c(0, .12),
     main = 'Effect of SRC lead authorship on Topic 16 ("planetary boundaries")',
     xaxt = "n",
     printlegend = F)
plot(src_topic_effect,
     topics = c(16),
     covariate = "organisation_phase",
     model = src_topics,
     method = "continuous",
     moderator = "src_author_role",
     moderator.value = "SRC collaborator(s)",
     linecol = "#363636", lwd = 2,
     add = T,
     printlegend = F)
legend(2, .12, c("SRC lead", "SRC collaborator(s)"), lwd = 2, col = c("#eb7125", "#363636"))
axis(1, at = org_phase_values$organisation_phase,
     labels = org_phase_values$organisation_phase_label)



