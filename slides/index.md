##   {#section .hideslideheader data-background="#061C30"}

::: {style="display:table;width:100%;table-layout: fixed;"}
::: {.title-without-logo style="display:table-cell;width:100%;padding-right:3%;padding-left:3%;vertical-align:middle;"}
SRC PhD R course Module 3

RMarkdown, Github & Co

 

 

 

 
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

 

*16. June 2022*
:::
:::

# Why learn RMarkdown & git/Github?

## Key motivation

Avoid repetitive and error-prone tasks.

## You should use RMarkdown if you want to ...

> -   concentrate on content rather than formatting
> -   share one document in many different formats (Markdown, PDF, Word,
>     HTML)
> -   ensure correct citations and bibliographies
> -   switch between different citation formats
> -   integrate your data analysis automatically, not statically
> -   ... and much more

# (R)Markdown

## Markdown vs markup

**Markdown** allows us to concentrate on document structure and content.
We can then worry about styling and presentation later.

**Markdown** is a type of **markup language** (like HTML), but it is
lightweight and more readable.

## Some text with simple formatting {#some-text-with-simple-formatting .left-aligned-slide}

This is a list:

-   with some **bold** and
-   some *italic* text.

And a [hyperlink](https://bookdown.org/yihui/rmarkdown/) for good
measure.

## Markup samples

::: {style="display:table;width:100%;table-layout:fixed;"}
::: {style="display:table-cell;width:50%;padding-left:1%;vertical-align:top;"}
**HTML**

    <p>This is a list:</p>
    <ul>
    <li>with some <strong>bold</strong> and</li>
    <li>some <em>italic</em> text.</li>
    </ul>
    <p>And a <a href="https://bookdown.org/yihui/rmarkdown/">hyperlink</a>
    for good measure.</p>
:::

::: {style="display:table-cell;width:50%;padding-right:1%;vertical-align:top;"}
**LaTeX**

    This is a list:

    \begin{itemize}
    \tightlist
    \item
      with some \textbf{bold} and
    \item
      some \emph{italic} text.
    \end{itemize}

    And a \href{https://bookdown.org/yihui/rmarkdown/}{hyperlink} for good
    measure.
:::
:::

## The same with Markdown

::: {style="display:table;width:100%;table-layout:fixed;"}
::: {style="display:table-cell;width:50%;padding-left:1%;vertical-align:top;"}
**Basic Markdown**

    This is a list:

    * with some **bold** and 
    * some *italic* text.

    And a [hyperlink](https://bookdown.org/yihui/rmarkdown/) for good measure.
:::

::: {style="display:table-cell;width:50%;padding-right:1%;text-align:left;vertical-align:top;"}
Typical workflow with markdown:

1.  **write** content as a Markdown document,
2.  **generate** the final document in a suitable output format
    (commonly HTML, PDF, Word)
3.  **publish**
:::
:::

# Essential markdown syntax

## Basic formatting and structuring

`<img src="./images/markdown_basic.jpg" width="1301" />`{=html}

## Lists and links

`<img src="./images/markdown_lists_links.jpg" width="1304" />`{=html}

## Even tables

`<img src="./images/markdown_tables.jpg" width="1302" />`{=html}

An overview of core markdown syntax can be found in [this RMarkdown book
chapter](https://bookdown.org/yihui/rmarkdown/markdown-syntax.html) and
even more options in a condensed form as an [RMarkdown cheat
sheet](https://raw.githubusercontent.com/rstudio/cheatsheets/main/rmarkdown.pdf).

```{=html}
<aside class="notes">
```
-   Tables (but now it gets complicated and RMarkdown makes an entry);
    show but then lead to RMarkdown; use mtcars or similar

```{=html}
</aside>
```
## 'R Markdown' vs 'Markdown'

-   Purpose: dynamically weave together text, data and analysis
    workflows.
-   This is accomplished with the [`knitr`](https://yihui.org/knitr/)
    package, an R package conveniently integrated into the R Studio UI.

## Differences to basic Markdown

-   R Markdown files use the file extension **`.Rmd`** instead of
    **`.md`**.
-   R Markdown files must start with a so-called **YAML header**
    section.

## YAML - Yet Another Markup Language?

The **YAML header** must be placed at the beginning of a document and is
enclosed by three dashes `---`.

``` default
---
title: "Untitled"
output: html_document
date: '2022-06-14'
---
```

Above is the default *YAML header* when generating an `RMarkdown` file
in R Studio.

```{=html}
<aside class="notes">
```
-   see RMarkdown book for details
-   show the YAML header and explain; output format (default HTML,
    others are possible)

```{=html}
</aside>
```
## YAML Ain't Markup Language!

The **YAML header** contains meta-data (e.g. title, date, author(s) etc)
as well as information about the output format and style.

A YAML header with more options might look like this:

``` default
---
title: "R Course SRC"
subtitle: "Module 3"
date: "`r Sys.Date()`"
author: 'Stefan Daume' 
output: 
  html_document:
    toc: yes
bibliography: references.bib 
link-citations: yes
---
```

## Exercise

::: {style="display:table;width:100%;table-layout:fixed;"}
::: {style="display:table-cell;width:50%;padding-left:1%;text-align:left;vertical-align:middle;"}
1.  Create a default 'R Markdown' document in R Studio.
2.  "knit" the document to HTML and view the result.
3.  Use the **Knit** button to select different output formats and check
    the YAML header afterwards.
:::

::: {style="display:table-cell;width:50%;padding-right:1%;vertical-align:middle;"}
`<img src="./images/rstudio_knit.jpg" width="399" />`{=html}
:::
:::

```{=html}
<aside class="notes">
```
-   may have to [install
    TinyTeX](https://bookdown.org/yihui/rmarkdown-cookbook/install-latex.html)
    to get PDF to work #tinytex::install_tinytex()

-   pandoc is bundled, but may not be the latest; hence may need to
    install pandoc [see
    here](https://bookdown.org/yihui/rmarkdown-cookbook/install-pandoc.html)

-   check installed version #rmarkdown::find_pandoc()

```{=html}
</aside>
```
## R Markdown: data-driven documents

-   You can now integrate your analysis as **R code** into the document
-   The analysis (i.e. the R code) is executed and the results updated
    when you **`knit`** the document.
-   Text and code are **interspersed**.
-   Code sections are included in **code chunks** like this.

```` default
```{r some-explanatory-label, echo=FALSE}
# here goes your R code
```
````

```{=html}
<aside class="notes">
```
-   contains an **optional** label (can be used for references), options
    controlling the output, such as figure size, caption, resolution

```{=html}
</aside>
```
## An example from the previous sessions

```` default
```{r life-expectancy, echo=FALSE}
library(gapminder)

gapminder %>% 
    group_by(year) %>%
    summarise(ale = mean(lifeExp)) %>%
    ggplot(aes(x = year, y = ale)) +
    geom_line(color = "orange") +
    labs(x = "Year", 
         y = "Average life expectancy") +
    theme_classic(base_size = 16)
```
````

## Plots in R Markdown

::: {style="display:table;width:100%;table-layout:fixed;"}
::: {style="display:table-cell;width:50%;padding-left:1%;vertical-align:middle;"}
```` default
```{r life-expectancy, echo=FALSE}
library(gapminder)

gapminder %>% 
    group_by(year) %>%
    summarise(ale = mean(lifeExp)) %>%
    ggplot(aes(x = year, y = ale)) +
    geom_line(color = "orange") +
    labs(x = "Year", 
         y = "Average life expectancy") +
    theme_classic(base_size = 16)
```
````
:::

::: {style="display:table-cell;width:50%;padding-right:1%;vertical-align:middle;"}
![](index_files/figure-markdown/life-expectancy-1.png)
:::
:::

## Remember the Markdown table format?

`<img src="./images/markdown_tables.jpg" width="1302" />`{=html}

## Dynamic tables with R Markdown

::: {style="display:table;width:100%;table-layout:fixed;"}
::: {style="display:table-cell;width:50%;padding-right:5%;vertical-align:top;"}
**This code ...**

```` default
```{r}
# summarize gapminder data by continent
gapminder_latest <- gapminder %>% 
  filter(year == year_of_interest) %>%
  group_by(continent) %>%
  summarise(avrg_le = mean(lifeExp),
            avrg_gdp = mean(gdpPercap))
              
# print the results as a table
gapminder_latest %>%
  knitr::kable()
```
````
:::

::: {style="display:table-cell;width:50%;padding-left:5%;vertical-align:top;"}
**... creates this table:**

  continent      avrg_le    avrg_gdp
  ----------- ---------- -----------
  Africa        54.80604    3089.033
  Americas      73.60812   11003.032
  Asia          70.72848   12473.027
  Europe        77.64860   25054.482
  Oceania       80.71950   29810.188
:::
:::

## Customizing `kable` tables

::: {style="display:table;width:100%;table-layout:fixed;"}
::: {style="display:table-cell;width:50%;padding-right:5%;vertical-align:top;"}
**This code ...**

```` default
```{r}
# summarize gapminder data by continent
gapminder_latest <- gapminder %>% 
  filter(year == year_of_interest) %>%
  group_by(continent) %>%
  summarise(avrg_le = mean(lifeExp),
            avrg_gdp = mean(gdpPercap))
              
# print the results as a table
gapminder_latest %>%
  knitr::kable(digits = c(0,1,2))
```
````
:::

::: {style="display:table-cell;width:50%;padding-left:5%;vertical-align:top;"}
**... creates this table:**

  continent     avrg_le   avrg_gdp
  ----------- --------- ----------
  Africa           54.8    3089.03
  Americas         73.6   11003.03
  Asia             70.7   12473.03
  Europe           77.6   25054.48
  Oceania          80.7   29810.19
:::
:::

## More expressive tables with `kableExtra`

::: {style="display:table;width:100%;table-layout:fixed;"}
::: {style="display:table-cell;width:50%;padding-right:5%;text-align:left;vertical-align:top;"}
The
[`kableExtra`](https://cran.r-project.org/web/packages/kableExtra/vignettes/awesome_table_in_html.html)
package offers even more options:

-   data-driven colouring

-   interactive tables

-   grouped headers

-   tables with (interactive) sparklines

-   and more ...

    ```{=html}
    </div>
    ```
    ```{=html}
    <div style="display:table-cell;width:50%;padding-left:5%;vertical-align:top;">
    ```

```{=html}
<table class="table lightable-paper" style="font-size: 10px; margin-left: auto; margin-right: auto; font-family: &quot;Arial Narrow&quot;, arial, helvetica, sans-serif; width: auto !important; margin-left: auto; margin-right: auto;">
```
```{=html}
<caption style="font-size: initial !important;">
```
Table caption: Dynamic formatting with the the help of `kableExtra`.
This example shows Gapminder data summarised by continent for the year
2007.
```{=html}
</caption>
```
```{=html}
<thead>
```
```{=html}
<tr>
```
```{=html}
<th style="text-align:left;">
```
Continent
```{=html}
</th>
```
```{=html}
<th style="text-align:right;">
```
Mean life expectancy
```{=html}
</th>
```
```{=html}
<th style="text-align:right;">
```
Mean GDP
```{=html}
</th>
```
```{=html}
</tr>
```
```{=html}
</thead>
```
```{=html}
<tbody>
```
```{=html}
<tr>
```
```{=html}
<td style="text-align:left;">
```
Africa
```{=html}
</td>
```
```{=html}
<td style="text-align:right;color: white !important;background-color: rgba(68, 1, 84, 1) !important;">
```
54.8
```{=html}
</td>
```
```{=html}
<td style="text-align:right;color: white !important;background-color: rgba(68, 1, 84, 1) !important;">
```
3089.03
```{=html}
</td>
```
```{=html}
</tr>
```
```{=html}
<tr>
```
```{=html}
<td style="text-align:left;">
```
Americas
```{=html}
</td>
```
```{=html}
<td style="text-align:right;color: white !important;background-color: rgba(80, 196, 106, 1) !important;">
```
73.6
```{=html}
</td>
```
```{=html}
<td style="text-align:right;color: white !important;background-color: rgba(53, 95, 141, 1) !important;">
```
11003.03
```{=html}
</td>
```
```{=html}
</tr>
```
```{=html}
<tr>
```
```{=html}
<td style="text-align:left;">
```
Asia
```{=html}
</td>
```
```{=html}
<td style="text-align:right;color: white !important;background-color: rgba(37, 172, 130, 1) !important;">
```
70.7
```{=html}
</td>
```
```{=html}
<td style="text-align:right;color: white !important;background-color: rgba(46, 109, 142, 1) !important;">
```
12473.03
```{=html}
</td>
```
```{=html}
</tr>
```
```{=html}
<tr>
```
```{=html}
<td style="text-align:left;">
```
Europe
```{=html}
</td>
```
```{=html}
<td style="text-align:right;color: white !important;background-color: rgba(176, 221, 47, 1) !important;">
```
77.6
```{=html}
</td>
```
```{=html}
<td style="text-align:right;color: white !important;background-color: rgba(137, 213, 72, 1) !important;">
```
25054.48
```{=html}
</td>
```
```{=html}
</tr>
```
```{=html}
<tr>
```
```{=html}
<td style="text-align:left;">
```
Oceania
```{=html}
</td>
```
```{=html}
<td style="text-align:right;color: white !important;background-color: rgba(253, 231, 37, 1) !important;">
```
80.7
```{=html}
</td>
```
```{=html}
<td style="text-align:right;color: white !important;background-color: rgba(253, 231, 37, 1) !important;">
```
29810.19
```{=html}
</td>
```
```{=html}
</tr>
```
```{=html}
</tbody>
```
```{=html}
</table>
```
:::
:::

## Central 'Setup' code section

```` default
```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = FALSE)

library(readr)
library(dplyr)
library(ggplot2)
library(gapminder)

year_of_interest <- 2007
```
````

Simplify library import and prepare datasets for reference in the whole
document.

# Handling citations

## Citations and bibliographies

One of the most useful and powerful features for researchers using R
Markdown.

## Requires a BibTeX database

A **BibTeX** database is simply a text file with the extension
**`.bib`** and entries such as:

    @misc{XieAllaire_et_2022,
      author = {Xie, Yihui and Allaire, J. J. and Grolemund, Garrett},
      title = {{R Markdown: The Definitive Guide}},
      url = {https://bookdown.org/yihui/rmarkdown/},
      urldate = {2022-06-07},
      year = {2022}
    }

No need to write those. Export from your reference manager or journal
pages.

```{=html}
<aside class="notes">
```
-   requires a ".bib" (BibTeX format) file of citations;
-   looks like this: ...
-   easy to export from the reference manager of your choice

```{=html}
</aside>
```
## Include citations

::: {style="display:table;width:100%;table-layout:fixed;"}
::: {style="display:table-cell;width:50%;padding-right:5%;text-align:left;vertical-align:top;"}
**Point to the `.bib` file in the YAML header.**

    ---
    title: "R Course SRC"
    subtitle: "Module 3"
    date: "2022-06-15"
    author: 'Stefan Daume' 
    output: 
      html_document:
        toc: yes
    bibliography: references.bib 
    link-citations: yes
    ---
:::

::: {style="display:table-cell;width:50%;padding-left:5%;text-align:left;vertical-align:top;"}
And then include citations in the text with the format
**`[@CitationKey]`**, which in the previously shown example was
**`[@XieAllaire_et_2022]`**, which is a reference to
[@XieAllaire_et_2022].
:::
:::

```{=html}
<aside class="notes">
```
-   you then point to the ".bib" file in the document's YAML header and
    include citations of your references as such `[@CitationKey]` in
    your text
-   and add a `# References` section at the end of your header

```{=html}
</aside>
```
## Include a bibliography

``` default
After presenting all results we have now reached the end of the document. Here should follow the bibliograpy.

# References
```

Add the header `# References` at the end of your document, `knit` and
the complete bibliography is added to the output document.

## Include a bibliography

::: {style="display:table;width:100%;table-layout:fixed;"}
::: {style="display:table-cell;width:50%;padding-right:5%;text-align:left;vertical-align:top;"}
``` default
After presenting all results we have now reached the end of the manuscript. As a final section should follow the bibliography.

# References
```
:::

::: {style="display:table-cell;width:50%;padding-left:5%;text-align:left;vertical-align:top;"}
Add the header **`# References`** at the end of your document,
**`knit`** and the complete bibliography is added to the output
document.
:::
:::

## Switch citation and bibliography styles dynamically

::: {style="display:table;width:100%;table-layout:fixed;"}
::: {style="display:table-cell;width:50%;padding-right:5%;text-align:left;vertical-align:top;"}
**Specify citation style in the YAML header.**

    ---
    title: "R Course SRC"
    subtitle: "Module 3"
    date: "2022-06-15"
    author: 'Stefan Daume' 
    output: 
      html_document:
        toc: yes
    bibliography: references.bib 
    link-citations: yes
    csl: ecology-and-society.csl
    ---
:::

::: {style="display:table-cell;width:50%;padding-left:5%;text-align:left;vertical-align:top;"}
The **[Citation Style Database](https://www.zotero.org/styles)**
database contains thousands of journal [citation
styles](https://citationstyles.org/). Download the relevant one,
reference in the YAML header and the output document will have the
required citation style.
:::
:::

```{=html}
<aside class="notes">
```
-   now you `knit` and get ... pure magic!
-   goodbye to: incorrect citations, missing citations, incorrect
    bibliographies and wasted time
-   even better: switch styles dynamically for the target journal

```{=html}
</aside>
```
## Easy sharing and online publishing

1.  `knit` your R Mardown document to HTML
2.  push the HTML to Github (next part of this module)
3.  enable sharing of **Github Pages**

This is how this presentation works (and the others before).

## "Continous Analysis" as the ultimate goal

# Thank You!

## Colophon {#colophon .colophon}

**SRC PhD R course Module 3 --- RMarkdown, Github & Co"** by *Stefan
Daume*

 

Presented on 16. June 2022.

 

This presentation can be cited using: *doi:...*

 

**PRESENTATION DETAILS**

**Author/Affiliation:** Stefan Daume, Stockholm Resilience Centre,
Stockholm University

**Presentation URL:**
<https://sdaume.github.io/r-course-module-3/slides>

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
images) of this presentation are **Copyright © 2022 of the Author** and
provided under a *CC BY 4.0* public domain license.

## Key Resources

-   R Markdown
    -   [R Markdown: The Definitive
        Guide](https://bookdown.org/yihui/rmarkdown/)
        [@XieAllaire_et_2022]
    -   [Cheatsheet: Dynamic documents with rmarkdown
        cheatsheet](https://raw.githubusercontent.com/rstudio/cheatsheets/main/rmarkdown.pdf)
-   Git/Github:
    -   [Happy Git and GitHub for the useR](https://happygitwithr.com/)
        [@Bryan2021]
    -   "Excuse me, do you have a moment to talk about version control?"
        [@Bryan2017]
    -   Advanced git use: [Pro Git](https://git-scm.com/book/en/v2) book
        [@Chacon_et_2014_Book]
    -   [How to write a great commit
        message](https://cbea.ms/git-commit/)

## References

::: {#refs}
:::

# Appendix (some notes on Github)

## You need git and Github if ... (non-exhaustive list)

-   ... you have files like this, but realise that this is not efficient
    -   my_paper_draft_2021_05_16.docx
    -   my_paper_draft_2021_05_18.docx
    -   my_paper_draft_2021_05_19.docx
    -   my_paper_draft_2021_05_19_v1.docx
    -   my_paper_draft_2021_05_19_v2.docx
    -   my_paper_draft_2021_05_19_v3_with_comments.docx
-   ... you are not creating regular backups of your work
-   ... you want to collaborate with others
-   ... you want to maintain projects rather than a single file (Google
    Doc)
-   ... you want to be able to easily revert back to previous versions
    of your work

## Git history

-   linux development, started 2005
-   a version management system, i.e. tracks changes in project
    resources
-   git takes snapshots of a managed project (image)
-   distributed version control system (that means you always have a
    complete copy of your version history on your local computer)

## Key concepts

-   repo
-   staging
-   commit
-   diff
-   push
-   pull
-   branch (advanced)
-   remote origin

## Useful things

-   .gitignore

## How to write a great commit comment {#how-to-write-a-great-commit-comment .left-aligned-slide}

Most important:

-   Keep things atomic!

Document consistently:

-   Keep the subject line short.
-   Use the imperative mood in the subject line (Because a commit
    message should always complete the following line: "If applied, this
    commit will \[YOUR_SUBJECT_LINE\].")
-   Use the body to explain what and why vs. how (Because "the how" can
    be obtained from the *diff*. The commit message should provide the
    context for "the how".)

# Setting Git up with R Studio

## Do this once:

-   install git locally (see [@Bryan2021])
-   sign up for a Github account
-   create a personal access token
    -   either via Github (<https://github.com/settings/tokens>)
    -   or via R with: `usethis::create_github_token()`
    -   and then store it with `gitcreds::gitcreds_set()`

## Do this for every new project:

-   create a Github repo first (follow the [New project, Github
    first](https://happygitwithr.com/new-github-first.html) workflow in
    [@Bryan2021])
    -   say yes to creating a README
    -   why? its easiest! you have everything in place to create remote
        backups!
-   copy the HTTPS link of your new repo
-   then create an R Studio project with the option from "version
    control \> git"

## When your new project is set up

-   make a change to the `README.md` (a useful project description)
-   `commit` the changes of the README file
-   and `push` to the remote Github repo
-   check the Github repo

```{=html}
<aside class="notes">
```
-   Show a basic workflow
-   screenshots

```{=html}
</aside>
```
