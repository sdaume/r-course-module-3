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
#> (Intercept)                                 0.044363   0.009496   4.672
#> organisation_phase                         -0.003415   0.003017  -1.132
#> src_author_roleSRC lead                    -0.012757   0.020288  -0.629
#> organisation_phase:src_author_roleSRC lead  0.014155   0.006399   2.212
#>                                            Pr(>|t|)    
#> (Intercept)                                3.19e-06 ***
#> organisation_phase                           0.2578    
#> src_author_roleSRC lead                      0.5296    
#> organisation_phase:src_author_roleSRC lead   0.0271 *  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 2:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.057436   0.009564   6.005
#> organisation_phase                         -0.003711   0.003058  -1.214
#> src_author_roleSRC lead                     0.043307   0.019653   2.204
#> organisation_phase:src_author_roleSRC lead -0.003690   0.006156  -0.599
#>                                            Pr(>|t|)    
#> (Intercept)                                2.28e-09 ***
#> organisation_phase                           0.2250    
#> src_author_roleSRC lead                      0.0277 *  
#> organisation_phase:src_author_roleSRC lead   0.5490    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 3:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                -0.015386   0.010677  -1.441
#> organisation_phase                          0.024415   0.003335   7.321
#> src_author_roleSRC lead                    -0.026845   0.023037  -1.165
#> organisation_phase:src_author_roleSRC lead  0.005096   0.007083   0.719
#>                                            Pr(>|t|)    
#> (Intercept)                                   0.150    
#> organisation_phase                         3.62e-13 ***
#> src_author_roleSRC lead                       0.244    
#> organisation_phase:src_author_roleSRC lead    0.472    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 4:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.002399   0.010377   0.231
#> organisation_phase                          0.013387   0.003184   4.205
#> src_author_roleSRC lead                     0.036567   0.022893   1.597
#> organisation_phase:src_author_roleSRC lead -0.015461   0.007172  -2.156
#>                                            Pr(>|t|)    
#> (Intercept)                                  0.8172    
#> organisation_phase                         2.73e-05 ***
#> src_author_roleSRC lead                      0.1104    
#> organisation_phase:src_author_roleSRC lead   0.0312 *  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 5:
#> 
#> Coefficients:
#>                                              Estimate Std. Error t value
#> (Intercept)                                 0.0570869  0.0090225   6.327
#> organisation_phase                         -0.0005075  0.0028453  -0.178
#> src_author_roleSRC lead                    -0.0305499  0.0192017  -1.591
#> organisation_phase:src_author_roleSRC lead  0.0042764  0.0059676   0.717
#>                                            Pr(>|t|)    
#> (Intercept)                                3.11e-10 ***
#> organisation_phase                            0.858    
#> src_author_roleSRC lead                       0.112    
#> organisation_phase:src_author_roleSRC lead    0.474    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 6:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.026399   0.012828   2.058
#> organisation_phase                          0.016921   0.003990   4.241
#> src_author_roleSRC lead                    -0.010423   0.026699  -0.390
#> organisation_phase:src_author_roleSRC lead  0.007842   0.008313   0.943
#>                                            Pr(>|t|)    
#> (Intercept)                                  0.0397 *  
#> organisation_phase                         2.33e-05 ***
#> src_author_roleSRC lead                      0.6963    
#> organisation_phase:src_author_roleSRC lead   0.3457    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 7:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.081534   0.009601   8.492
#> organisation_phase                         -0.003471   0.003054  -1.137
#> src_author_roleSRC lead                     0.063843   0.020301   3.145
#> organisation_phase:src_author_roleSRC lead -0.010235   0.006183  -1.655
#>                                            Pr(>|t|)    
#> (Intercept)                                 < 2e-16 ***
#> organisation_phase                          0.25582    
#> src_author_roleSRC lead                     0.00169 ** 
#> organisation_phase:src_author_roleSRC lead  0.09803 .  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 8:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.069556   0.010749   6.471
#> organisation_phase                         -0.007315   0.003334  -2.194
#> src_author_roleSRC lead                     0.032771   0.020426   1.604
#> organisation_phase:src_author_roleSRC lead -0.008325   0.006324  -1.316
#>                                            Pr(>|t|)    
#> (Intercept)                                1.23e-10 ***
#> organisation_phase                           0.0283 *  
#> src_author_roleSRC lead                      0.1088    
#> organisation_phase:src_author_roleSRC lead   0.1882    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 9:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.069542   0.010816   6.429
#> organisation_phase                         -0.009293   0.003450  -2.694
#> src_author_roleSRC lead                    -0.035914   0.023126  -1.553
#> organisation_phase:src_author_roleSRC lead  0.004510   0.007050   0.640
#>                                            Pr(>|t|)    
#> (Intercept)                                1.62e-10 ***
#> organisation_phase                          0.00712 ** 
#> src_author_roleSRC lead                     0.12060    
#> organisation_phase:src_author_roleSRC lead  0.52247    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 10:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.010298   0.008828   1.167
#> organisation_phase                          0.010632   0.002753   3.861
#> src_author_roleSRC lead                     0.032415   0.017749   1.826
#> organisation_phase:src_author_roleSRC lead -0.013301   0.005615  -2.369
#>                                            Pr(>|t|)    
#> (Intercept)                                0.243552    
#> organisation_phase                         0.000117 ***
#> src_author_roleSRC lead                    0.067967 .  
#> organisation_phase:src_author_roleSRC lead 0.017941 *  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 11:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.076997   0.011795   6.528
#> organisation_phase                         -0.007359   0.003786  -1.944
#> src_author_roleSRC lead                    -0.003654   0.025052  -0.146
#> organisation_phase:src_author_roleSRC lead  0.008783   0.007957   1.104
#>                                            Pr(>|t|)    
#> (Intercept)                                8.52e-11 ***
#> organisation_phase                           0.0521 .  
#> src_author_roleSRC lead                      0.8840    
#> organisation_phase:src_author_roleSRC lead   0.2699    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 12:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                -0.012129   0.009284  -1.306
#> organisation_phase                          0.015664   0.002917   5.370
#> src_author_roleSRC lead                     0.022351   0.019284   1.159
#> organisation_phase:src_author_roleSRC lead -0.002920   0.006067  -0.481
#>                                            Pr(>|t|)    
#> (Intercept)                                   0.192    
#> organisation_phase                         8.83e-08 ***
#> src_author_roleSRC lead                       0.247    
#> organisation_phase:src_author_roleSRC lead    0.630    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 13:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.021870   0.010330   2.117
#> organisation_phase                          0.004201   0.003216   1.306
#> src_author_roleSRC lead                     0.012175   0.022449   0.542
#> organisation_phase:src_author_roleSRC lead -0.004876   0.006871  -0.710
#>                                            Pr(>|t|)  
#> (Intercept)                                  0.0344 *
#> organisation_phase                           0.1916  
#> src_author_roleSRC lead                      0.5876  
#> organisation_phase:src_author_roleSRC lead   0.4780  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 14:
#> 
#> Coefficients:
#>                                              Estimate Std. Error t value
#> (Intercept)                                 0.0605761  0.0118263   5.122
#> organisation_phase                          0.0008367  0.0037790   0.221
#> src_author_roleSRC lead                    -0.0319376  0.0246385  -1.296
#> organisation_phase:src_author_roleSRC lead -0.0007792  0.0077646  -0.100
#>                                            Pr(>|t|)    
#> (Intercept)                                3.33e-07 ***
#> organisation_phase                            0.825    
#> src_author_roleSRC lead                       0.195    
#> organisation_phase:src_author_roleSRC lead    0.920    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 15:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.080878   0.012365   6.541
#> organisation_phase                         -0.010378   0.003855  -2.692
#> src_author_roleSRC lead                    -0.033139   0.026116  -1.269
#> organisation_phase:src_author_roleSRC lead  0.008508   0.008103   1.050
#>                                            Pr(>|t|)    
#> (Intercept)                                7.84e-11 ***
#> organisation_phase                          0.00717 ** 
#> src_author_roleSRC lead                     0.20463    
#> organisation_phase:src_author_roleSRC lead  0.29384    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 16:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.029829   0.010495   2.842
#> organisation_phase                          0.007276   0.003295   2.208
#> src_author_roleSRC lead                     0.056004   0.022225   2.520
#> organisation_phase:src_author_roleSRC lead -0.015499   0.006860  -2.259
#>                                            Pr(>|t|)   
#> (Intercept)                                 0.00453 **
#> organisation_phase                          0.02738 * 
#> src_author_roleSRC lead                     0.01182 * 
#> organisation_phase:src_author_roleSRC lead  0.02398 * 
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 17:
#> 
#> Coefficients:
#>                                              Estimate Std. Error t value
#> (Intercept)                                 0.0268493  0.0124909   2.150
#> organisation_phase                          0.0095019  0.0038839   2.447
#> src_author_roleSRC lead                    -0.0112521  0.0277978  -0.405
#> organisation_phase:src_author_roleSRC lead -0.0003438  0.0084222  -0.041
#>                                            Pr(>|t|)  
#> (Intercept)                                  0.0317 *
#> organisation_phase                           0.0145 *
#> src_author_roleSRC lead                      0.6857  
#> organisation_phase:src_author_roleSRC lead   0.9674  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 18:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.103923   0.011529   9.014
#> organisation_phase                         -0.020057   0.003558  -5.637
#> src_author_roleSRC lead                    -0.025858   0.023760  -1.088
#> organisation_phase:src_author_roleSRC lead  0.003330   0.007258   0.459
#>                                            Pr(>|t|)    
#> (Intercept)                                 < 2e-16 ***
#> organisation_phase                         1.99e-08 ***
#> src_author_roleSRC lead                       0.277    
#> organisation_phase:src_author_roleSRC lead    0.646    
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 19:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.132417   0.013833   9.572
#> organisation_phase                         -0.026938   0.004288  -6.282
#> src_author_roleSRC lead                    -0.092584   0.028813  -3.213
#> organisation_phase:src_author_roleSRC lead  0.022041   0.009073   2.429
#>                                            Pr(>|t|)    
#> (Intercept)                                 < 2e-16 ***
#> organisation_phase                         4.13e-10 ***
#> src_author_roleSRC lead                     0.00133 ** 
#> organisation_phase:src_author_roleSRC lead  0.01522 *  
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> 
#> Topic 20:
#> 
#> Coefficients:
#>                                             Estimate Std. Error t value
#> (Intercept)                                 0.076036   0.007201  10.560
#> organisation_phase                         -0.010771   0.002294  -4.695
#> src_author_roleSRC lead                     0.020513   0.014881   1.378
#> organisation_phase:src_author_roleSRC lead -0.004044   0.004648  -0.870
#>                                            Pr(>|t|)    
#> (Intercept)                                 < 2e-16 ***
#> organisation_phase                         2.85e-06 ***
#> src_author_roleSRC lead                       0.168    
#> organisation_phase:src_author_roleSRC lead    0.384    
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
