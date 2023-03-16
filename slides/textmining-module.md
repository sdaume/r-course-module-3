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

1.  get documents to analyse
2.  preprocess
3.  create a corpus
4.  tokenize
5.  create document-term matrix
6.  *(evaluate alternative topic numbers)*
7.  decide on K, the number of topics, and fit a topic model
8.  *(validate semantic integrity of the topic model)*

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
-   How prominent are they?
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

``` r
plot(src_topics, n = 5)
```

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
#> (Intercept)                                 0.045173   0.009762   4.627
#> organisation_phase                         -0.003745   0.003057  -1.225
#> src_author_roleSRC lead                    -0.014333   0.020423  -0.702
#> organisation_phase:src_author_roleSRC lead  0.014620   0.006364   2.297
#>                                            Pr(>|t|)    
#> (Intercept)                                3.95e-06 ***
#> organisation_phase                           0.2207    
#> src_author_roleSRC lead                      0.4829    
#> organisation_phase:src_author_roleSRC lead   0.0217 *  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 2:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.057584   0.009369   6.146
#> organisation_phase                         -0.003726   0.002989  -1.246
#> src_author_roleSRC lead                     0.043138   0.019877   2.170
#> organisation_phase:src_author_roleSRC lead -0.003605   0.006272  -0.575
#>                                            Pr(>|t|)    
#> (Intercept)                                9.63e-10 ***
#> organisation_phase                           0.2128    
#> src_author_roleSRC lead                      0.0301 *  
#> organisation_phase:src_author_roleSRC lead   0.5655    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 3:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                -0.015549   0.010757  -1.445
#> organisation_phase                          0.024472   0.003339   7.330
#> src_author_roleSRC lead                    -0.026256   0.022125  -1.187
#> organisation_phase:src_author_roleSRC lead  0.004872   0.006921   0.704
#>                                            Pr(>|t|)    
#> (Intercept)                                   0.149    
#> organisation_phase                         3.39e-13 ***
#> src_author_roleSRC lead                       0.235    
#> organisation_phase:src_author_roleSRC lead    0.482    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 4:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.001813   0.010452   0.173
#> organisation_phase                          0.013620   0.003292   4.138
#> src_author_roleSRC lead                     0.036296   0.022896   1.585
#> organisation_phase:src_author_roleSRC lead -0.015291   0.007231  -2.115
#>                                            Pr(>|t|)    
#> (Intercept)                                  0.8623    
#> organisation_phase                         3.66e-05 ***
#> src_author_roleSRC lead                      0.1131    
#> organisation_phase:src_author_roleSRC lead   0.0346 *  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 5:
#> 
#> Coefficients:
#>                                              Estimate Std. Error t value
#> (Intercept)                                 0.0572582  0.0089854   6.372
#> organisation_phase                         -0.0005766  0.0027989  -0.206
#> src_author_roleSRC lead                    -0.0310447  0.0182317  -1.703
#> organisation_phase:src_author_roleSRC lead  0.0044656  0.0056692   0.788
#>                                            Pr(>|t|)    
#> (Intercept)                                2.33e-10 ***
#> organisation_phase                           0.8368    
#> src_author_roleSRC lead                      0.0888 .  
#> organisation_phase:src_author_roleSRC lead   0.4310    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 6:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.026148   0.012292   2.127
#> organisation_phase                          0.017092   0.003825   4.468
#> src_author_roleSRC lead                    -0.006070   0.025316  -0.240
#> organisation_phase:src_author_roleSRC lead  0.006300   0.007868   0.801
#>                                            Pr(>|t|)    
#> (Intercept)                                  0.0335 *  
#> organisation_phase                         8.35e-06 ***
#> src_author_roleSRC lead                      0.8105    
#> organisation_phase:src_author_roleSRC lead   0.4233    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 7:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.082466   0.009998   8.249
#> organisation_phase                         -0.003802   0.003133  -1.214
#> src_author_roleSRC lead                     0.059801   0.021739   2.751
#> organisation_phase:src_author_roleSRC lead -0.008953   0.006743  -1.328
#>                                            Pr(>|t|)    
#> (Intercept)                                2.96e-16 ***
#> organisation_phase                            0.225    
#> src_author_roleSRC lead                       0.006 ** 
#> organisation_phase:src_author_roleSRC lead    0.184    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 8:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.068949   0.009686   7.118
#> organisation_phase                         -0.007089   0.003094  -2.291
#> src_author_roleSRC lead                     0.032197   0.022266   1.446
#> organisation_phase:src_author_roleSRC lead -0.008028   0.006984  -1.150
#>                                            Pr(>|t|)    
#> (Intercept)                                1.54e-12 ***
#> organisation_phase                           0.0221 *  
#> src_author_roleSRC lead                      0.1483    
#> organisation_phase:src_author_roleSRC lead   0.2505    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 9:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.068440   0.010957   6.246
#> organisation_phase                         -0.008988   0.003383  -2.657
#> src_author_roleSRC lead                    -0.036222   0.023750  -1.525
#> organisation_phase:src_author_roleSRC lead  0.004615   0.007519   0.614
#>                                            Pr(>|t|)    
#> (Intercept)                                5.18e-10 ***
#> organisation_phase                          0.00796 ** 
#> src_author_roleSRC lead                     0.12739    
#> organisation_phase:src_author_roleSRC lead  0.53943    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 10:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.010424   0.008640   1.206
#> organisation_phase                          0.010634   0.002742   3.878
#> src_author_roleSRC lead                     0.032328   0.017472   1.850
#> organisation_phase:src_author_roleSRC lead -0.013329   0.005431  -2.454
#>                                            Pr(>|t|)    
#> (Intercept)                                0.227781    
#> organisation_phase                         0.000109 ***
#> src_author_roleSRC lead                    0.064430 .  
#> organisation_phase:src_author_roleSRC lead 0.014215 *  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 11:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.076483   0.011950   6.400
#> organisation_phase                         -0.007330   0.003725  -1.968
#> src_author_roleSRC lead                    -0.002936   0.023805  -0.123
#> organisation_phase:src_author_roleSRC lead  0.008431   0.007406   1.138
#>                                            Pr(>|t|)    
#> (Intercept)                                1.95e-10 ***
#> organisation_phase                           0.0493 *  
#> src_author_roleSRC lead                      0.9018    
#> organisation_phase:src_author_roleSRC lead   0.2551    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 12:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                -0.011416   0.009633  -1.185
#> organisation_phase                          0.015426   0.002987   5.165
#> src_author_roleSRC lead                     0.022061   0.020411   1.081
#> organisation_phase:src_author_roleSRC lead -0.002909   0.006365  -0.457
#>                                            Pr(>|t|)    
#> (Intercept)                                   0.236    
#> organisation_phase                         2.65e-07 ***
#> src_author_roleSRC lead                       0.280    
#> organisation_phase:src_author_roleSRC lead    0.648    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 13:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.022323   0.010284   2.171
#> organisation_phase                          0.003984   0.003237   1.231
#> src_author_roleSRC lead                     0.010588   0.021313   0.497
#> organisation_phase:src_author_roleSRC lead -0.004279   0.006567  -0.652
#>                                            Pr(>|t|)  
#> (Intercept)                                  0.0301 *
#> organisation_phase                           0.2186  
#> src_author_roleSRC lead                      0.6194  
#> organisation_phase:src_author_roleSRC lead   0.5148  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 14:
#> 
#> Coefficients:
#>                                              Estimate Std. Error t value
#> (Intercept)                                 0.0601895  0.0124326   4.841
#> organisation_phase                          0.0009999  0.0038164   0.262
#> src_author_roleSRC lead                    -0.0291618  0.0258192  -1.129
#> organisation_phase:src_author_roleSRC lead -0.0017506  0.0077741  -0.225
#>                                            Pr(>|t|)    
#> (Intercept)                                1.39e-06 ***
#> organisation_phase                            0.793    
#> src_author_roleSRC lead                       0.259    
#> organisation_phase:src_author_roleSRC lead    0.822    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 15:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.081220   0.012375   6.563
#> organisation_phase                         -0.010475   0.003866  -2.709
#> src_author_roleSRC lead                    -0.034310   0.025859  -1.327
#> organisation_phase:src_author_roleSRC lead  0.008783   0.007871   1.116
#>                                            Pr(>|t|)    
#> (Intercept)                                6.77e-11 ***
#> organisation_phase                           0.0068 ** 
#> src_author_roleSRC lead                      0.1847    
#> organisation_phase:src_author_roleSRC lead   0.2646    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 16:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.030399   0.010619   2.863
#> organisation_phase                          0.007216   0.003379   2.136
#> src_author_roleSRC lead                     0.054575   0.023615   2.311
#> organisation_phase:src_author_roleSRC lead -0.015141   0.007269  -2.083
#>                                            Pr(>|t|)   
#> (Intercept)                                 0.00425 **
#> organisation_phase                          0.03282 * 
#> src_author_roleSRC lead                     0.02094 * 
#> organisation_phase:src_author_roleSRC lead  0.03739 * 
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 17:
#> 
#> Coefficients:
#>                                              Estimate Std. Error t value
#> (Intercept)                                 2.719e-02  1.267e-02   2.147
#> organisation_phase                          9.391e-03  3.937e-03   2.386
#> src_author_roleSRC lead                    -1.335e-02  2.681e-02  -0.498
#> organisation_phase:src_author_roleSRC lead -6.224e-05  8.132e-03  -0.008
#>                                            Pr(>|t|)  
#> (Intercept)                                  0.0319 *
#> organisation_phase                           0.0171 *
#> src_author_roleSRC lead                      0.6185  
#> organisation_phase:src_author_roleSRC lead   0.9939  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 18:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.103353   0.011429   9.043
#> organisation_phase                         -0.019816   0.003584  -5.529
#> src_author_roleSRC lead                    -0.026425   0.023409  -1.129
#> organisation_phase:src_author_roleSRC lead  0.003553   0.007388   0.481
#>                                            Pr(>|t|)    
#> (Intercept)                                 < 2e-16 ***
#> organisation_phase                         3.66e-08 ***
#> src_author_roleSRC lead                       0.259    
#> organisation_phase:src_author_roleSRC lead    0.631    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 19:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.133038   0.013725   9.693
#> organisation_phase                         -0.027047   0.004362  -6.201
#> src_author_roleSRC lead                    -0.092602   0.027000  -3.430
#> organisation_phase:src_author_roleSRC lead  0.021972   0.008290   2.650
#>                                            Pr(>|t|)    
#> (Intercept)                                 < 2e-16 ***
#> organisation_phase                         6.85e-10 ***
#> src_author_roleSRC lead                    0.000617 ***
#> organisation_phase:src_author_roleSRC lead 0.008108 ** 
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 20:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.074748   0.007596   9.840
#> organisation_phase                         -0.010340   0.002313  -4.470
#> src_author_roleSRC lead                     0.022650   0.015606   1.451
#> organisation_phase:src_author_roleSRC lead -0.004707   0.004766  -0.988
#>                                            Pr(>|t|)    
#> (Intercept)                                 < 2e-16 ***
#> organisation_phase                         8.28e-06 ***
#> src_author_roleSRC lead                       0.147    
#> organisation_phase:src_author_roleSRC lead    0.324    
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
code](https://github.com/sdaume/r-course-module-3/blob/main/topicmodels/topicmodel.R)**

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
