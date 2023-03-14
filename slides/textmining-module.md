##   {#section .hideslideheader data-background="#061C30"}

::: {style="display:table;width:100%;table-layout: fixed;"}
::: {.title-without-logo style="display:table-cell;width:100%;padding-right:3%;padding-left:3%;vertical-align:middle;"}
SRC PhD R course Module 9

Structural Topic Modeling

 

 

 

 
:::
:::

::: {style="display:table;width:100%;table-layout: fixed;"}
::: {.mytitlepage .linksection style="display:table-cell;width:30%;padding-left:3%;vertical-align:bottom;"}
*[\@stefandaume](https://twitter.com/stefandaume)*

*<https://scitingly.net/>*

*<stefan.daume@su.se>*
:::

::: {.mytitlepage .authorsection style="display:table-cell;width:70%;padding-right:3%;"}
  **Stefan Daume**

*[Stockholm Resilience Centre, Stockholm
University](https://www.stockholmresilience.org/meet-our-team/staff/2021-01-27-daume.html)*

& *[Beijer Institute of Ecological
Economics](https://beijer.kva.se/programmes/complexity/)*

 

*16. March 2023*
:::
:::

## Why topic modelling?

-   summarize large text collections
-   discover "latent" topics
-   text-based causal inferences and testing social science theories

## The notion of "latent topics"

## How does it work?

-   unsupervised, probabilistic classification
-   generative model (reverses the document generation process)

## Topic modelling algorithms

-   LSA - [Latent semantic
    analysis](https://asistdl.onlinelibrary.wiley.com/doi/10.1002/(SICI)1097-4571(199009)41:6%3C391::AID-ASI1%3E3.0.CO;2-9)
-   LDA - Latent dirichlet allocation [@BleiNgEt2003_JMLR_3]
-   CTM - Correlated topic model [@BleiLafferty2007_AAS_1]
-   STM - Structural topic model [@RobertsStewart_et_2019_JSTATS_91]

## STM vs "vanilla LDA"

-   STM extends CTM (i.e. assumes that topics are correlated)
-   STM can incorporate arbitrary document meta-data into the topic
    model

## Basic text mining concepts

-   documents
-   corpus
-   tokens
-   terms

## Basic steps

-   get documents to analyse
-   preprocess
-   create a corpus
-   tokenize
-   create document-term matrix
-   *(evaluate alternative topic numbers)*
-   decide on K, the number of topics, and fit a topic model
-   *(validate semantic integrity of the topic model)*

## R packages to use

-   quanteda
-   tidytext
-   (snowballc)
-   (spacyr)
-   stringr
-   stm

## An example: SRC publications

![](textmining-module_files/figure-markdown/unnamed-chunk-1-1.png)

## A simplistic approach {#a-simplistic-approach .xs-small-pg-text}

  Term            N
  ----------- -----
  social        265
  system        256
  ecolog        248
  ecosystem     243
  sustain       216
  global        175
  chang         171
  manag         168
  resili        167

## ngrams: closer to "topics"

  Term                     N
  -------------------- -----
  social ecolog          165
  ecosystem servic       146
  ecolog system           81
  climat chang            80
  baltic sea              41
  food system             36
  planetari boundari      36
  earth system            34
  regim shift             32

## What about temporal trends?

`<img src="textmining-module_files/figure-markdown/unnamed-chunk-4-1.png" width="50%" />`{=html}

## Topic modelling with STM

Questions:

-   Which latent topics exists?
-   How promiment are they?
-   Is the topic prevalence influenced by document variables?
-   How are topics related?

## Create a document corpus

-   Decide what constitutes a **document**.
-   Create a structured representation of documents with unique document
    identifiers.

## Document corpus with `quanteda`

``` r
# read the source documents
src_pubs <- readr::read_csv("./topicmodels/data/src_pubs_annotated.csv",
                            col_types = "c")

# create a document corpus using quanteda
pubs_corpus <- src_pubs %>%
  quanteda::corpus(docid_field = "doc_id", text_field = "abstract")
```

## Tokenize with `quanteda`

``` r
# tokenize the document corpus (here we use words as tokens)
pubs_tokens <- pubs_corpus %>%
  quanteda::tokens(what = "word",
                   remove_punct = TRUE,
                   remove_symbols = TRUE,
                   remove_numbers = TRUE,
                   remove_url = TRUE,
                   remove_separators = TRUE,
                   split_hyphens = TRUE)
```

## Create a 'document-feature matrix' with `quanteda`

``` r
# create a document feature matrix and filter the
# features (here by removing common English stopwords)
pubs_dfm <- pubs_tokens %>%
  quanteda::dfm(tolower = TRUE) %>%
  quanteda::dfm_remove(pattern = quanteda::stopwords("english")) %>%
  quanteda::dfm_wordstem()
```

## Filter documents and/or terms

``` r
# we can apply additional filtering to the document feature matrix
pubs_dfm <- pubs_dfm %>%
  quanteda::dfm_remove(min_nchar = 2) %>% 
  quanteda::dfm_trim(min_docfreq = 2, docfreq_type = "count") %>%  
  quanteda::dfm_subset(quanteda::ntoken(.) > 2)
```

## Fit the STM topic model

``` r
# create a native STM representation of the DFM
stm_docs <- quanteda::convert(pubs_dfm, to = "stm")

# we use 20 topics and consider two covariates
src_topics <- stm(documents = stm_docs$documents,
                  vocab = stm_docs$vocab,
                  data = stm_docs$meta,
                  prevalence = ~ organisation_phase * src_author_role,
                  K = 20,
                  verbose = TRUE)
```

## Inspect the topic model

``` r
# list most probable words (different groups of words are available)
summary(src_topics)

# plot the topic shares/probabilities using plot.STM
plot(src_topics, n = 5)
```

## Topics - Terms

``` r
summary(src_topics)
#> A topic model with 20 topics, 1906 documents and a 5104 word dictionary.
#> Topic 1 Top Words:
#>       Highest Prob: fisheri, fish, fisher, poverti, livelihood, scale, market 
#>       FREX: poverti, fisheri, fisher, livelihood, trap, women, price 
#>       Lift: ssf, amend, bigger, bought, buy, daw, homarus 
#>       Score: fisheri, fisher, fish, poverti, market, trap, livelihood 
#> Topic 2 Top Words:
#>       Highest Prob: govern, institut, global, chang, polici, ocean, sustain 
#>       FREX: corpor, institut, govern, innov, ocean, crise, compani 
#>       Lift: gradualist, multin, philanthropi, preexist, anticipatori, cdm, fip 
#>       Score: govern, ocean, corpor, institut, actor, coevolv, crise 
#> Topic 3 Top Words:
#>       Highest Prob: develop, sustain, scenario, goal, use, polici, assess 
#>       FREX: amr, sdgs, goal, scenario, target, achiev, sdg 
#>       Lift: bsms, carson, cbd, cousin, emptiv, fell, galvan 
#>       Score: amr, sdgs, scenario, sdg, cbd, goal, ipb 
#> Topic 4 Top Words:
#>       Highest Prob: urban, citi, green, area, plan, infrastructur, use 
#>       FREX: urban, citi, garden, gi, green, ug, infrastructur 
#>       Lift: peri, antithesi, architect, barcelona, cemeteri, cogitatio, colour 
#>       Score: urban, citi, green, garden, gi, ug, infrastructur 
#> Topic 5 Top Words:
#>       Highest Prob: climat, chang, risk, impact, carbon, global, adapt 
#>       FREX: climat, risk, carbon, hazard, mitig, emiss, vulner 
#>       Lift: grape, gtc, ipcc, wine, cdr, elsler, nc 
#>       Score: climat, carbon, emiss, risk, hazard, adapt, chang 
#> Topic 6 Top Words:
#>       Highest Prob: research, sustain, knowledg, transform, scienc, approach, practic 
#>       FREX: research, transdisciplinari, think, knowledg, disciplin, transform, interdisciplinari 
#>       Lift: comment, doctor, espa, interdisciplinar, interrog, intract, journalist 
#>       Score: transdisciplinari, transform, think, research, disciplin, career, engag 
#> Topic 7 Top Words:
#>       Highest Prob: social, ecolog, system, resili, complex, dynam, adapt 
#>       FREX: resili, ecolog, social, ses, system, al, deal 
#>       Lift: armitag, borrini, chapin, malin, unanticip, ostrom, berk 
#>       Score: resili, social, ses, ecolog, system, adapt, theori 
#> Topic 8 Top Words:
#>       Highest Prob: ecosystem, servic, es, valu, well, scale, landscap 
#>       FREX: es, servic, ecosystem, provis, bundl, off, landscap 
#>       Lift: cum, ditch, fiber, firewood, photograph, québec, tell 
#>       Score: servic, es, ecosystem, bundl, ebm, landscap, provis 
#> Topic 9 Top Words:
#>       Highest Prob: shift, fish, regim, reef, coral, sea, chang 
#>       FREX: reef, coral, cucumb, iuu, vessel, regim, shift 
#>       Lift: brew, breweri, fiji, iuu, mayott, ppcps, scuba 
#>       Score: reef, coral, fish, iuu, cucumb, herbivor, vessel 
#> Topic 10 Top Words:
#>       Highest Prob: natur, human, scienc, data, springer, peopl, decis 
#>       FREX: media, natur, mental, springer, behavior, children, switzerland 
#>       Lift: duinen, hollands, ladder, nationa, nff, uenc, enjoy 
#>       Score: natur, hnc, children, behavior, supplementari, abm, media 
#> Topic 11 Top Words:
#>       Highest Prob: govern, adapt, learn, actor, network, collabor, stakehold 
#>       FREX: learn, collabor, student, actor, stakehold, particip, adapt 
#>       Lift: acf, brunswick, classroom, igitur, man, misalign, multiactor 
#>       Score: learn, actor, network, collabor, govern, adapt, student 
#> Topic 12 Top Words:
#>       Highest Prob: communiti, sustain, local, practic, peopl, cultur, divers 
#>       FREX: biocultur, indigen, discours, redd, justic, sf, power 
#>       Lift: artifact, biocultur, centralis, cocreat, dune, historic, linguist 
#>       Score: indigen, redd, biocultur, sf, justic, forest, discours 
#> Topic 13 Top Words:
#>       Highest Prob: resourc, behaviour, communiti, cooper, user, individu, group 
#>       FREX: behaviour, cooper, pool, user, attitud, game, harvest 
#>       Lift: aggress, balines, everyon, hydrocarbon, megapitaria, methanogen, microorgan 
#>       Score: cooper, behaviour, harvest, templ, attitud, cell, microbi 
#> Topic 14 Top Words:
#>       Highest Prob: model, network, data, dynam, analysi, approach, use 
#>       FREX: node, model, statist, network, graph, simul, nonlinear 
#>       Lift: barabási, brain, chaotic, crossov, eigenanalysi, ep, epla 
#>       Score: network, model, node, simul, graph, brokerag, statist 
#> Topic 15 Top Words:
#>       Highest Prob: water, land, use, forest, region, basin, moistur 
#>       FREX: moistur, water, evapor, watersh, rainfal, soil, precipit 
#>       Lift: 2layer, arcswat, companion, envelop, eulerian, hydrochem, inund 
#>       Score: water, moistur, evapor, precipit, rainfal, basin, hydrolog 
#> Topic 16 Top Words:
#>       Highest Prob: system, human, earth, boundari, global, planetari, tip 
#>       FREX: planetari, earth, tip, boundari, safe, element, biospher 
#>       Lift: chemist, destabilis, interglaci, biocid, biogeophys, domino, johan 
#>       Score: earth, planetari, tip, anthropocen, boundari, safe, human 
#> Topic 17 Top Words:
#>       Highest Prob: food, product, system, agricultur, aquacultur, farm, environment 
#>       FREX: farm, aquacultur, food, nutrit, certif, consumpt, product 
#>       Lift: acid, affluent, agroecolog, aquafe, buck, cargil, carp 
#>       Score: aquacultur, food, farm, seafood, nutrit, agricultur, farmer 
#> Topic 18 Top Words:
#>       Highest Prob: speci, habitat, biodivers, landscap, forest, divers, function 
#>       FREX: patch, habitat, trait, speci, dispers, invas, plant 
#>       Lift: acacia, amphibian, apart, macroinvertebr, plcas, allometr, arabl 
#>       Score: speci, habitat, patch, trait, bird, forest, golf 
#> Topic 19 Top Words:
#>       Highest Prob: sea, baltic, ice, nutrient, indic, ecosystem, increas 
#>       FREX: baltic, prey, seabird, oxygen, cod, ice, salin 
#>       Lift: argentatus, auk, biotop, clupea, copepod, deglaci, dissolut 
#>       Score: baltic, prey, ice, sea, sheet, predat, nutrient 
#> Topic 20 Top Words:
#>       Highest Prob: manag, conserv, implement, marin, approach, develop, success 
#>       FREX: manag, conserv, implement, success, restor, protect, european 
#>       Lift: bureaucraci, iea, virtu, appeal, ec, forsak, voluntarili 
#>       Score: conserv, manag, marin, implement, protect, lake, plan
```

## Topic shares

`<img src="textmining-module_files/figure-markdown/unnamed-chunk-6-1.png" width="70%" />`{=html}

## Estimate covariate effects

``` r
# this can be estimated for selected topics (here we evaluate all topics)
src_topic_effect <- estimateEffect(1:20 ~ organisation_phase * src_author_role,
                                   stmobj = src_topics,
                                   metadata = stm_docs$meta, uncertainty = "None")

# this summarises the regression stats for the estimated covriate effects
summary(src_topic_effect)
```

## Covariate effects summary {#covariate-effects-summary .xs-small-pg-text}

``` r
summary(src_topic_effect)
#> 
#> Call:
#> estimateEffect(formula = 1:20 ~ organisation_phase * src_author_role, 
#>     stmobj = src_topics, metadata = stm_docs$meta, uncertainty = "None")
#> 
#> 
#> Topic 1:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.045324   0.009596   4.723
#> organisation_phase                         -0.003682   0.003041  -1.211
#> src_author_roleSRC lead                    -0.014385   0.021840  -0.659
#> organisation_phase:src_author_roleSRC lead  0.014653   0.006775   2.163
#>                                            Pr(>|t|)    
#> (Intercept)                                2.49e-06 ***
#> organisation_phase                           0.2261    
#> src_author_roleSRC lead                      0.5102    
#> organisation_phase:src_author_roleSRC lead   0.0307 *  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 2:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.057513   0.009612   5.984
#> organisation_phase                         -0.003671   0.003056  -1.201
#> src_author_roleSRC lead                     0.042315   0.019474   2.173
#> organisation_phase:src_author_roleSRC lead -0.003440   0.006080  -0.566
#>                                            Pr(>|t|)    
#> (Intercept)                                 2.6e-09 ***
#> organisation_phase                           0.2298    
#> src_author_roleSRC lead                      0.0299 *  
#> organisation_phase:src_author_roleSRC lead   0.5716    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 3:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                -0.015880   0.011055  -1.436
#> organisation_phase                          0.024623   0.003442   7.154
#> src_author_roleSRC lead                    -0.026937   0.022539  -1.195
#> organisation_phase:src_author_roleSRC lead  0.005000   0.007097   0.705
#>                                            Pr(>|t|)    
#> (Intercept)                                   0.151    
#> organisation_phase                          1.2e-12 ***
#> src_author_roleSRC lead                       0.232    
#> organisation_phase:src_author_roleSRC lead    0.481    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 4:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.003175   0.010878   0.292
#> organisation_phase                          0.013116   0.003363   3.900
#> src_author_roleSRC lead                     0.037755   0.021558   1.751
#> organisation_phase:src_author_roleSRC lead -0.015788   0.006744  -2.341
#>                                            Pr(>|t|)    
#> (Intercept)                                  0.7704    
#> organisation_phase                         9.94e-05 ***
#> src_author_roleSRC lead                      0.0801 .  
#> organisation_phase:src_author_roleSRC lead   0.0193 *  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 5:
#> 
#> Coefficients:
#>                                              Estimate Std. Error t value
#> (Intercept)                                 0.0567325  0.0088904   6.381
#> organisation_phase                         -0.0004705  0.0027788  -0.169
#> src_author_roleSRC lead                    -0.0315325  0.0178430  -1.767
#> organisation_phase:src_author_roleSRC lead  0.0046685  0.0055989   0.834
#>                                            Pr(>|t|)    
#> (Intercept)                                 2.2e-10 ***
#> organisation_phase                           0.8656    
#> src_author_roleSRC lead                      0.0774 .  
#> organisation_phase:src_author_roleSRC lead   0.4045    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 6:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.026958   0.011986   2.249
#> organisation_phase                          0.016915   0.003802   4.449
#> src_author_roleSRC lead                    -0.006071   0.027106  -0.224
#> organisation_phase:src_author_roleSRC lead  0.006310   0.008456   0.746
#>                                            Pr(>|t|)    
#> (Intercept)                                  0.0246 *  
#> organisation_phase                         9.13e-06 ***
#> src_author_roleSRC lead                      0.8228    
#> organisation_phase:src_author_roleSRC lead   0.4556    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 7:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.082062   0.010530   7.793
#> organisation_phase                         -0.003702   0.003199  -1.157
#> src_author_roleSRC lead                     0.060520   0.020999   2.882
#> organisation_phase:src_author_roleSRC lead -0.009238   0.006536  -1.413
#>                                            Pr(>|t|)    
#> (Intercept)                                1.07e-14 ***
#> organisation_phase                            0.247    
#> src_author_roleSRC lead                       0.004 ** 
#> organisation_phase:src_author_roleSRC lead    0.158    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 8:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.069651   0.010323   6.747
#> organisation_phase                         -0.007289   0.003135  -2.325
#> src_author_roleSRC lead                     0.032162   0.022434   1.434
#> organisation_phase:src_author_roleSRC lead -0.008137   0.006939  -1.173
#>                                            Pr(>|t|)    
#> (Intercept)                                1.99e-11 ***
#> organisation_phase                           0.0202 *  
#> src_author_roleSRC lead                      0.1518    
#> organisation_phase:src_author_roleSRC lead   0.2411    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 9:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.069354   0.011134   6.229
#> organisation_phase                         -0.009190   0.003446  -2.667
#> src_author_roleSRC lead                    -0.036831   0.023753  -1.551
#> organisation_phase:src_author_roleSRC lead  0.004821   0.007433   0.649
#>                                            Pr(>|t|)    
#> (Intercept)                                5.77e-10 ***
#> organisation_phase                          0.00772 ** 
#> src_author_roleSRC lead                     0.12117    
#> organisation_phase:src_author_roleSRC lead  0.51669    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 10:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.010874   0.008240   1.320
#> organisation_phase                          0.010457   0.002563   4.081
#> src_author_roleSRC lead                     0.031421   0.017911   1.754
#> organisation_phase:src_author_roleSRC lead -0.013007   0.005656  -2.300
#>                                            Pr(>|t|)    
#> (Intercept)                                  0.1871    
#> organisation_phase                         4.68e-05 ***
#> src_author_roleSRC lead                      0.0796 .  
#> organisation_phase:src_author_roleSRC lead   0.0216 *  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 11:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.075546   0.011973   6.309
#> organisation_phase                         -0.006989   0.003790  -1.844
#> src_author_roleSRC lead                    -0.002697   0.026735  -0.101
#> organisation_phase:src_author_roleSRC lead  0.008284   0.008236   1.006
#>                                            Pr(>|t|)    
#> (Intercept)                                3.48e-10 ***
#> organisation_phase                           0.0653 .  
#> src_author_roleSRC lead                      0.9197    
#> organisation_phase:src_author_roleSRC lead   0.3146    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 12:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                -0.012093   0.008972  -1.348
#> organisation_phase                          0.015666   0.002849   5.500
#> src_author_roleSRC lead                     0.023387   0.020209   1.157
#> organisation_phase:src_author_roleSRC lead -0.003201   0.006332  -0.506
#>                                            Pr(>|t|)    
#> (Intercept)                                   0.178    
#> organisation_phase                         4.32e-08 ***
#> src_author_roleSRC lead                       0.247    
#> organisation_phase:src_author_roleSRC lead    0.613    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 13:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.022268   0.009767   2.280
#> organisation_phase                          0.004140   0.003037   1.363
#> src_author_roleSRC lead                     0.008876   0.019749   0.449
#> organisation_phase:src_author_roleSRC lead -0.003988   0.006077  -0.656
#>                                            Pr(>|t|)  
#> (Intercept)                                  0.0227 *
#> organisation_phase                           0.1730  
#> src_author_roleSRC lead                      0.6532  
#> organisation_phase:src_author_roleSRC lead   0.5117  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 14:
#> 
#> Coefficients:
#>                                              Estimate Std. Error t value
#> (Intercept)                                 0.0605840  0.0118124   5.129
#> organisation_phase                          0.0008032  0.0037433   0.215
#> src_author_roleSRC lead                    -0.0297799  0.0246842  -1.206
#> organisation_phase:src_author_roleSRC lead -0.0016320  0.0076814  -0.212
#>                                            Pr(>|t|)    
#> (Intercept)                                3.21e-07 ***
#> organisation_phase                            0.830    
#> src_author_roleSRC lead                       0.228    
#> organisation_phase:src_author_roleSRC lead    0.832    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 15:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.081345   0.011605   7.009
#> organisation_phase                         -0.010522   0.003679  -2.860
#> src_author_roleSRC lead                    -0.032706   0.024016  -1.362
#> organisation_phase:src_author_roleSRC lead  0.008302   0.007447   1.115
#>                                            Pr(>|t|)    
#> (Intercept)                                3.32e-12 ***
#> organisation_phase                          0.00428 ** 
#> src_author_roleSRC lead                     0.17340    
#> organisation_phase:src_author_roleSRC lead  0.26505    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 16:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.029942   0.010524   2.845
#> organisation_phase                          0.007303   0.003250   2.247
#> src_author_roleSRC lead                     0.055802   0.022512   2.479
#> organisation_phase:src_author_roleSRC lead -0.015447   0.007074  -2.184
#>                                            Pr(>|t|)   
#> (Intercept)                                 0.00449 **
#> organisation_phase                          0.02474 * 
#> src_author_roleSRC lead                     0.01327 * 
#> organisation_phase:src_author_roleSRC lead  0.02911 * 
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 17:
#> 
#> Coefficients:
#>                                              Estimate Std. Error t value
#> (Intercept)                                 0.0266516  0.0126134   2.113
#> organisation_phase                          0.0095863  0.0038842   2.468
#> src_author_roleSRC lead                    -0.0123350  0.0263262  -0.469
#> organisation_phase:src_author_roleSRC lead -0.0003028  0.0081606  -0.037
#>                                            Pr(>|t|)  
#> (Intercept)                                  0.0347 *
#> organisation_phase                           0.0137 *
#> src_author_roleSRC lead                      0.6394  
#> organisation_phase:src_author_roleSRC lead   0.9704  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 18:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.103778   0.011502   9.023
#> organisation_phase                         -0.019904   0.003614  -5.507
#> src_author_roleSRC lead                    -0.024972   0.022688  -1.101
#> organisation_phase:src_author_roleSRC lead  0.002927   0.007069   0.414
#>                                            Pr(>|t|)    
#> (Intercept)                                 < 2e-16 ***
#> organisation_phase                         4.15e-08 ***
#> src_author_roleSRC lead                       0.271    
#> organisation_phase:src_author_roleSRC lead    0.679    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 19:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.133222   0.013488   9.877
#> organisation_phase                         -0.027272   0.004214  -6.472
#> src_author_roleSRC lead                    -0.093331   0.028418  -3.284
#> organisation_phase:src_author_roleSRC lead  0.022324   0.008880   2.514
#>                                            Pr(>|t|)    
#> (Intercept)                                 < 2e-16 ***
#> organisation_phase                         1.22e-10 ***
#> src_author_roleSRC lead                     0.00104 ** 
#> organisation_phase:src_author_roleSRC lead  0.01202 *  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 20:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.075540   0.007150  10.564
#> organisation_phase                         -0.010602   0.002239  -4.735
#> src_author_roleSRC lead                     0.020996   0.015314   1.371
#> organisation_phase:src_author_roleSRC lead -0.004167   0.004762  -0.875
#>                                            Pr(>|t|)    
#> (Intercept)                                 < 2e-16 ***
#> organisation_phase                         2.35e-06 ***
#> src_author_roleSRC lead                       0.171    
#> organisation_phase:src_author_roleSRC lead    0.382    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

## Example 1: Topics over time

`<img src="textmining-module_files/figure-markdown/unnamed-chunk-8-1.png" width="70%" />`{=html}

## Example 2: SRC lead authorship

`<img src="textmining-module_files/figure-markdown/unnamed-chunk-9-1.png" width="70%" />`{=html}

## Example 3: SRC lead authorship

`<img src="textmining-module_files/figure-markdown/unnamed-chunk-10-1.png" width="70%" />`{=html}

## Example 4: Combined effects

`<img src="textmining-module_files/figure-markdown/unnamed-chunk-11-1.png" width="70%" />`{=html}

## Exercise

1.  fit the model with a different K
2.  test a different prevalence formula (for example `n_authors` or
    `open_access`)
3.  estimate the covariate effect for this model
4.  adapt the examples in the script for other topics and covariates

**[Sample
code](https://github.com/sdaume/r-course-module-3/topicmodels/topicmodel.R)**

# Thank You!

## Key Resources

-   [quanteda R package](http://quanteda.io/)
-   [stm: An R Package for Structural Topic
    Models](https://www.jstatsoft.org/article/view/v091i02)
    [@XieAllaire_et_2022]
-   [oolong R package](https://github.com/chainsawriot/oolong)

## References

::: {#refs}
:::

## Colophon {#colophon .colophon}

**SRC PhD R course Module 9 --- Structural Topic Modeling"** by *Stefan
Daume*

 

Presented on 16. March 2023.

 

This presentation can be cited using: *doi:...*

 

**PRESENTATION DETAILS**

**Author/Affiliation:** Stefan Daume, Stockholm Resilience Centre,
Stockholm University

**Presentation URL:**
<https://sdaume.github.io/r-course-module-3/slides/textmining-module.html>

**Presentation Source:** \[TBD\]

**Presentation PDF:** \[TBD\]

 

**CREDITS & LICENSES**

This presentation is delivered with the help of several free and open
source tools and libraries. It utilises the
[reveal.js](https://revealjs.com/) presentation framework and has been
created using [RMarkdown](https://rmarkdown.rstudio.com),
[knitr](https://yihui.name/knitr/), [RStudio](https://www.rstudio.com)
and [Pandoc](https://pandoc.org/).
[highlight.js](https://highlightjs.org) provides syntax highlighting for
code sections. [MathJax](https://www.mathjax.org) supports the rendering
of mathematical notations. PDF and JPG copies of this presentation were
generated with [DeckTape](https://github.com/astefanutti/decktape).
Please note the respective licenses of these tools and libraries.

 

If not noted and attributed otherwise, the contents (text, charts,
images) of this presentation are **Copyright © 2023 of the Author** and
provided under a *CC BY 4.0* public domain license.
