# (PART) Appendices {-}

# Use cases {#app-chap:useCases}

To add to the tutorial of Chapter \@ref(chap:tutorial), this chapter will present a few short use cases extracted and updated from the `emuR_intro` vignette. These use cases are meant as practical guides to answering research questions and are to be viewed as generic template procedures that can be altered and applied to similar research questions. They are meant to give practical examples of what it is like working with the EMU-SDMS to answer research questions common in speech and spoken language research. Every use case will start off by asking a question about the *ae* demo database and will continue by walking through the process of answering this question by using the mechanics the `emuR` package provides. The four questions this chapter will address are:


- Section \@ref(sec:app-chap-useCases-q1): What is the average length of all *n* phonetic segments in the *ae* `emuDB`?
- Section \@ref(sec:app-chap-useCases-q2): What does the F1 and F2 distribution of all phonetic segments that contain the labels *I*, *o:*, *u:*, *V* or *\@* look like?
- Section \@ref(sec:app-chap-useCases-q3): What words do the phonetic segments that carry the labels *s*, *z*, *S* or *Z* in the *ae* `emuDB` occur in and what is their phonetic context?
- Section \@ref(sec:app-chap-useCases-q4): Do the phonetic segments that carry the labels *s*, *z*, *S* or *Z* in the *ae* `emuDB` differ with respect to their first spectral moment?
\end{itemize}


The R code snippet below shows how the `emuR` demo data used in this chapter is created.


```r
# load the package 
library(emuR)

# create demo data in directory provided by the tempdir() function
create_emuRdemoData(dir = tempdir())

# get the path to emuDB called 'ae' that is part of the demo data
path2directory = file.path(tempdir(), "emuR_demoData", "ae_emuDB")

# load emuDB into current R session
ae = load_emuDB(path2directory)
```


## What is the average length of all *n* phonetic segments in the *ae* `emuDB`? {#sec:app-chap-useCases-q1}

The first thing that has to be done to address this fairly simple question is to query the database for all *n* segments. This can be achieved using the `query()` function as shown in the R code snippet below.


```r
# query segments
sl = query(ae, query = "Phonetic == n")

# show first row of sl
head(sl, n = 1)
```

```
## segment  list from database:  ae 
## query was:  Phonetic == n 
##   labels    start      end session   bundle    level    type
## 1      n 1031.925 1195.925    0000 msajc003 Phonetic SEGMENT
```

The second argument of the `query()` contains a string that represents an EQL statement. This fairly simple EQL statement consists of `==`, which is the equality operator of the EQL, and on the right hand side of the operator the label *n* that we are looking for.

The `query()` function returns an object of the class `emuRsegs` that is a superclass of the well known `data.frame`. The various columns of this object should be fairly self-explanatory: `labels` displays the extracted labels, `start` and `end` are the start time and end times in milliseconds of each segment and so on. We can now use the information in this object to calculate the mean durations of these segments as shown in the R code snippet below.


```r
# calculate durations
d = dur(sl)

# calculate mean
mean(d)
```

```
## [1] 67.05833
```

## What does the F1 and F2 distribution of all phonetic segments that contain the labels *I*, *o:*, *u:*, *V* or *\@* look like? {#sec:app-chap-useCases-q2}

Once again we will initially query the `emuDB` to retrieve the segments we are interested in as shown in the R code snippet below.


```r
# query emuDB
sl = query(ae, query = "Phonetic == I|o:|u:|V|@")
```


Now that the necessary segment information has been extracted, the `get\_trackdata()` function can be used to calculate the formant values for these segments as displayed in the R code snippet below.


```r
# get formant values for these segments
td = get_trackdata(ae, sl,
                   onTheFlyFunctionName = "forest",
                   resultType = "emuRtrackdata")
```

In this example, the `get_trackdata()` function uses a formant estimation function called `forest()` to calculate the formant values in real time. This signal processing function is part of the `wrassp` package, which is used by the `emuR` package to perform signal processing duties with the `get_trackdata()` command (see Chapter \@ref(chap:wrassp) for details).

If the `resultType` parameter is set to `emuRtrackdata` in the call to `get\_trackdata()`, an object of the class `emuRtrackdata` is returned. The class vector of the `td` object is displayed in the R code snippet below.


```r
# show class vector of td
class(td)
```

```
## [1] "emuRtrackdata" "data.frame"
```

```r
# show first line of td
head(td, n = 1)
```

```
##   sl_rowIdx labels   start     end session   bundle    level    type
## 1         1      V 187.425 256.925    0000 msajc003 Phonetic SEGMENT
##   times_orig times_rel times_norm T1   T2   T3   T4
## 1      187.5         0          0  0 1293 2424 3429
```

As the `emuRtrackdata` class is a superclass to the common `data.table` and `data.frame` classes, packages like `ggplot2` can be used to visualize our F1 and F2 distribution as shown in the R code snippet below (see Figure \@ref(fig:usecases-uc2plot) for the resulting plot).


```r
# load package
library(ggplot2)

# scatter plot of F1 and F2 values using ggplot
ggplot(td, aes(x=T2, y=T1, label=td$labels)) +
  geom_text(aes(colour=factor(labels))) +
  scale_y_reverse() + scale_x_reverse() +
  labs(x = "F2(Hz)", y = "F1(Hz)") +
  guides(colour=FALSE)
```

<div class="figure" style="text-align: center">
<img src="app_chap-useCases_files/figure-epub3/usecases-uc2plot-1.png" alt="F1 by F2 distribution for *I*, *o:*, *u:*, *V* and *@*."  />
<p class="caption">(\#fig:usecases-uc2plot)F1 by F2 distribution for *I*, *o:*, *u:*, *V* and *@*.</p>
</div>

## What words do the phonetic segments that carry the labels *s*, *z*, *S* or *Z* in the *ae* `emuDB` occur in and what is their phonetic context? {#sec:app-chap-useCases-q3}

As with the previous use cases, the initial step is to query the database to extract the relevant segments as shown in the R code snippet below.


```r
# query segments
sibil = query(ae,"Phonetic==s|z|S|Z")

# show first element of sibil
head(sibil, n = 1)
```

```
## segment  list from database:  ae 
## query was:  Phonetic==s|z|S|Z 
##   labels   start     end session   bundle    level    type
## 1      s 483.425 566.925    0000 msajc003 Phonetic SEGMENT
```


The `requery_hier()` function can now be used to perform a hierarchical requery using the set resulting from the initial query. This requery follows the hierarchical links of the annotations in the database to find the linked annotation items on a different level. The R code snippet below shows how this can achieved.


```r
# perform requery
words = requery_hier(ae, sibil, level = "Word")

# show first element of words
head(words, n = 1)
```

```
## segment  list from database:  ae 
## query was:  FROM REQUERY 
##   labels   start     end session   bundle level type
## 1      C 187.425 674.175    0000 msajc003  Word ITEM
```

As seen in the above R code snippet, the result is not quite what one would expect as it does not contain the orthographic word transcriptions but a classification of the words into content words (*C*) and function words (*F*). Calling the `summary()` function on the `emuDBhandle` object `ae` would show that the *Words* level has multiple attribute definitions indicating that each annotation item in the *Words* level has multiple parallel labels defined for it. The R code snippet below shows an additional requery that queries the *Text* attribute definition instead.


```r
# perform requery
words = requery_hier(ae, sibil, level = "Text")

# show first element of words
head(words, n = 1)
```

```
## segment  list from database:  ae 
## query was:  FROM REQUERY 
##   labels   start     end session   bundle level type
## 1      C 187.425 674.175    0000 msajc003  Word ITEM
```

As seen in the above R code snippet, the first segment in `sibil` occurred in the word *amongst*, which starts at 187.475 ms and ends at 674.225 ms. It is worth noting that this two-step querying procedure (`query()` followed by `requery_hier()`) can also be completed in a single hierarchical query using the dominance operator (^).

As we have answered the first part of the question, the R code snippet below will extract the context to the left of the extracted sibilants by using the `requery_seq()` function.


```r
# get left context by off setting the 
# annotation items in sibil one unit to the left
leftContext = requery_seq(ae, sibil, offset = -1)

# show first element of leftContext
head(leftContext, n = 1)
```

```
## segment  list from database:  ae 
## query was:  FROM REQUERY 
##   labels   start     end session   bundle    level    type
## 1      N 426.675 483.425    0000 msajc003 Phonetic SEGMENT
```

The R code snippet below attempts to extract the right context in the same manner as above R code snippet, but in this case we encounter a problem.


```r
# get right context by off-setting the 
# annotation items in sibil one unit to the right
rightContext = requery_seq(ae, sibil, offset = 1)
```

```
## Error in requery_seq(ae, sibil, offset = 1): 4 of the requested sequence(s) is/are out of boundaries.
## Set parameter 'ignoreOutOfBounds=TRUE' to get residual result segments that lie within the bounds.
```

As can be seen by the error message in the above R code snippet, four of the sibilants occur at the very end of the recording and therefore have no phonetic post-context. The remaining post-contexts can be retrieved by setting the `ignoreOutOfBounds` argument to `TRUE` as displayed in the R code snippet below.


```r
rightContext = requery_seq(ae, sibil,
                           offset = 1,
                           ignoreOutOfBounds = TRUE)
```

```
## Warning in requery_seq(ae, sibil, offset = 1, ignoreOutOfBounds = TRUE):
## Found missing items in resulting segment list! Replacing missing rows with
## NA values.
```

```r
# show first element of rightContext
head(rightContext, n = 1)
```

```
## segment  list from database:  ae 
## query was:  FROM REQUERY 
##   labels   start     end session   bundle    level    type
## 1      t 566.925 596.675    0000 msajc003 Phonetic SEGMENT
```

However, the resulting `rightContext` and the original `sibil` objects are not aligned any more. It is therefore dangerous to use this option by default, as one often relies on the rows in multiple `emuRsegs` objects that were created from each other by using either `requery_hier()` or `requery_seq()` to be aligned with each other (i.e., that the same row index implicitly indicates a relationship).


## Do the phonetic segments labeled *s*, *z*, *S* or *Z* in the *ae* `emuDB` differ with respect to their first spectral moment?\protect\footnote{The original version of this use case was written by Florian Schiel as part of the `emuR_intro` vignette that is part of the `emuR` package. {#sec:app-chap-useCases-q4}

Once again, the segments of interest are queried first. The R code snippet below shows how this can be achieved, this time using the new regular expression operand of the EQL (see Chapter \@ref(chap:querysys) for details).


```r
sibil = query(ae,"Phonetic =~ '[szSZ]'")
```

The R code snippet below shows how the `get_trackdata()` function can be used to calculate the Discrete Fourier Transform values for the extracted segments.


```r
dftTd = get_trackdata(ae,
                      seglist = sibil,
                      onTheFlyFunctionName = 'dftSpectrum')
```


As the `resultType` parameter was not explicitly set, an object of the class `trackdata` is returned. This object, just like an object of the class `emuRtrackdata`, contains the extracted trackdata information. Compared to the `emuRtrackdata` class, however, the object is not "flat" and in the form of a `data.table` or `data.frame` but has a more nested structure (see `?trackdata` for more details).

Since we want to analyze sibilant spectral data we will now reduce the spectral range of the data to 1000 - 10000 Hz. This is due to the fact that there is a lot of unwanted noise in the lower bands that is irrelevant for the problem at hand and can even skew the end results. To achieve this we can use a property of a `trackdata` object that also carries the class `spectral`, which means that it is indexed using frequencies. The R code snippet below shows how to use this feature to extract the relevant spectral frequencies of the `trackdata` object.


```r
dftTdRelFreq = dftTd[, 1000:10000]
```

The R code snippet below shows how the `fapply()` function can be used to apply the `moments()` function to all elements of `dftTdRelFreq`.


```r
dftTdRelFreqMom = fapply(dftTdRelFreq, moments, minval = T)
```

The resulting `dftTdRelFreqMom` object is once again a `trackdata` object of the same length as the `dftTdRelFreq` `trackdata` object. It contains the first four spectral moments as shown in the R code snippet below.


```r
# show first row of data belonging 
# to first element of dftTdRelFreqMom
dftTdRelFreqMom[1]$data[1,]
```

```
## [1]  5.335375e+03  6.469573e+06  6.097490e-02 -1.103308e+00
```

The information stored in the `dftTdRelFreqMom` and `sibil` objects can now be used to plot a time-normalized version of the first spectral moment trajectories, color coded by sibilant class, using `emuR`'s `dplot()` function. The R code snippet below shows the R code that produces Figure \@ref(fig:usecases-uc4dplot1).


```r
dplot(dftTdRelFreqMom[, 1],
      sibil$labels,
      normalise = TRUE,
      xlab = "Normalized Time [%]",
      ylab = "1st spectral moment [Hz]")
```

<div class="figure" style="text-align: center">
<img src="app_chap-useCases_files/figure-epub3/usecases-uc4dplot1-1.png" alt="Time-normalized first spectral moment trajectories color coded by sibilant class."  />
<p class="caption">(\#fig:usecases-uc4dplot1)Time-normalized first spectral moment trajectories color coded by sibilant class.</p>
</div>


As one might expect, the first spectral moment (the center of gravity) is significantly lower for postalveolar *S* and *Z* (green and blue lines) than for alveolar *s* and *z* (black and red lines). 

The R code snippet below shows how to create an alternative plot (see Figure \@ref(fig:usecases-uc4dplot2)) that averages the trajectories into ensemble averages per sibilant class by setting the `average` parameter of `dplot()` to `TRUE`.


```r
dplot(dftTdRelFreqMom[,1],
      sibil$labels,
      normalise = TRUE,
      average = TRUE,
      xlab = "Normalized Time [%]",
      ylab = "1st spectral moment [Hz]")
```

<div class="figure" style="text-align: center">
<img src="app_chap-useCases_files/figure-epub3/usecases-uc4dplot2-1.png" alt="Time-normalized first spectral moment ensemble average trajectories per sibilant class."  />
<p class="caption">(\#fig:usecases-uc4dplot2)Time-normalized first spectral moment ensemble average trajectories per sibilant class.</p>
</div>



As can be seen from the previous two plots (Figure \@ref(fig:usecases-uc4dplot1) and \@ref(fig:usecases-uc4dplot2)), transitions to and from a sort of steady state around the temporal midpoint of the sibilants are clearly visible. To focus on this steady state part of the sibilant we will now extract those spectral moments that fall between the proportional timepoints 0.2 and 0.8 of each segment (i.e., the central 60\%) using the `dcut()` function as is shown in the R code snippet below.


```r
# cut out the middle 60% portion
dftTdRelFreqMomMid = dcut(dftTdRelFreqMom,
                          left.time = 0.2,
                          right.time = 0.8,
                          prop = T)
```

Finally, the R code snippet below shows how to calculate the averages of these trajectories using the `trapply()` function.


```r
meanFirstMoments = trapply(dftTdRelFreqMomMid[,1],
                           fun = mean,
                           simplify = T)
```


As the resulting `meanFirstMoments` vector has the same length as the initial `sibil` segment list, we can now easily visualize these values in the form of a boxplot. The R code below shows the R code that produces Figure \@ref(fig:usecases-uc4boxplot).


```r
boxplot(meanFirstMoments ~ sibil$labels, 
        xlab = "Sibilant class labels",
        ylab = "First spectral moment values [Hz]")
```

<div class="figure" style="text-align: center">
<img src="app_chap-useCases_files/figure-epub3/usecases-uc4boxplot-1.png" alt="Boxplots of the first spectral moments grouped by their sibilant class."  />
<p class="caption">(\#fig:usecases-uc4boxplot)Boxplots of the first spectral moments grouped by their sibilant class.</p>
</div>

As final remark, it is worth noting that using the `emuRtrackdata` `resultType` (not the `trackdata` `resultType`) of `get_trackdata()` function we could have performed a comparable analysis by utilizing packages such as `dplyr` for `data.table` or `data.frame` manipulation and `lattice` or `ggplot2` for data visualisation.




