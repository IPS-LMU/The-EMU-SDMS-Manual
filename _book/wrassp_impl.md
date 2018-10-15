# `wrassp` implementation {#chap:wrassp_impl}

The `libassp` was originally written by Michel Scheffers as a C library which could be linked against or compiled into separate executable signal processing command line tools. To extend the legacy EMU system, the `libassp` it was integrated into it by using the Tcl Extension Architecture (TEA) to create a native extension to the Tcl programming language. The bulk of this work was done by Lasse Bombien in collaboration with Michel Scheffers. Lasse Bombien also implemented the `tkassp` user interface module as part of the legacy EMU system to allow the user full access to the functionality of the `libassp` from a GUI. The `wrassp` R package was written by Lasse Bombien and Raphael Winkelmann based on a similar approach as the `tclassp` port using the TEA. Since the `libassp` was put under the GPL version 3 (see https://www.gnu.org/licenses/gpl-3.0.en.html) by Michel Scheffers, the `wrassp` also carries this license.


## The `libassp` port

Here, we briefly describe our strategy for porting the `libassp` to R. The port of the `libassp` to the R eco-system was achieved using the foreign language interface provided by the R system as is described in the R Extensions manual (see https://cran.r-project.org/doc/manuals/r-release/R-exts.htmlWriting). To port the various signal processing routines provided by the `libassp` and to avoid code redundancy a single C function called `performAssp()` was created. This function acts as a C wrapper function interface to `libassp`'s internal functions and handles the data conversion between `libassp`'s internal and R's data structures. However, to provide the user with a clear and concise API we chose to implement separate R functions for every signal processing function. This also allowed us to formulate more concise manual entries for each of the signal processing function provided by `wrassp`. The R code snippet below is a pseudo-code example of the layout of each signal processing function `wrassp` provides.


```r
##' roxygen2 documentation for genericWrasspFun
genericWrasspSigProcFun = function(listOfFiles,
                                   ...,
                                   forceToLog = useWrasspLogger){
  
  ###########################
  # perform parameter checks
  if (is.null(listOfFiles)) {
		stop(paste("listOfFiles is NULL! ..."))
  }
  # ...
  
  # call performAssp
  externalRes = invisible(.External("performAssp", listOfFiles, 
                                    fname = "forest", ...))
  
  
  ############################
  # write options to options log file
  if (forceToLog){
	  optionsGivenAsArgs = as.list(match.call(
	    expand.dots = TRUE))
	  wrassp.logger(optionsGivenAsArgs[[1]], 
	                optionsGivenAsArgs[-1],
	                optLogFilePath, listOfFiles)
  }    
  
  return(externalRes)
}
```

To provide access to the file handling capabilities of the `libassp`, we implemented two C interface functions called `getDObj2()` (where `2` is simply used as a function version marker) and `writeDObj()`. These functions use `libassp`'s `asspFOpen()`, `asspFFill()`, `asspFWrite()` and `asspFClose()` function to read and write files supported by the `libassp` from and to files on disk into R. The public API functions `read.AsspDataObj()` and `write.AsspDataObj()` are the R wrapper functions around `getDObj2()` and `writeDObj()`.

To be able to access some of `libassp`'s internal variables further wrapper functions were implemented. It was necessary to have access to these variables to be able to perform adequate parameter checks in various functions. The R code snippet below shows these functions.



```r
# load the wrassp package
library(wrassp)

# show AsspWindowTypes
AsspWindowTypes()
```

```
##  [1] "RECTANGLE" "TRIANGLE"  "PARABOLA"  "COS"       "HANN"     
##  [6] "COS_3"     "COS_4"     "HAMMING"   "BLACKMAN"  "BLACK_X"  
## [11] "BLACK_3"   "BLACK_M3"  "BLACK_4"   "BLACK_M4"  "NUTTAL_3" 
## [16] "NUTTAL_4"  "GAUSS2_5"  "GAUSS3_0"  "GAUSS3_5"  "KAISER2_0"
## [21] "KAISER2_5" "KAISER3_0" "KAISER3_5" "KAISER4_0"
```

```r
# show wrasspOutputInfos
AsspLpTypes()
```

```
## [1] "ARF" "LAR" "LPC" "RFC"
```

```r
# show wrasspOutputInfos
AsspSpectTypes()
```

```
## [1] "DFT" "LPS" "CSS" "CEP"
```

The `wrassp` package provides two R objects that contain useful information regarding the supported file format types (`AsspFileFormats`) and the output created by the various signal processing functions. The R code snippet below shows the content of these two objects.


```r
# show AsspFileFormats
AsspFileFormats
```

```
##     RAW   ASP_A   ASP_B   XASSP  IPDS_M  IPDS_S    AIFF    AIFC     CSL 
##       1       2       3       4       5       6       7       8       9 
##    CSRE    ESPS     ILS     KTH   SWELL   SNACK     SFS     SND      AU 
##      10      11      12      13      13      13      14      15      15 
##    NIST  SPHERE PRAAT_S PRAAT_L PRAAT_B    SSFF    WAVE  WAVE_X  XLABEL 
##      16      16      17      18      19      20      21      22      24 
##    YORK     UWM 
##      25      26
```

```r
# show first element of wrasspOutputInfos
wrasspOutputInfos[[1]]
```

```
## $ext
## [1] "acf"
## 
## $tracks
## [1] "acf"
## 
## $outputType
## [1] "SSFF"
```

As a final remark, it is worth noting that porting the C library `libassp` to R enables the functions provided by the `wrassp` package to run at near native speeds on every platform supported by R and avoids almost any interpreter overhead.
