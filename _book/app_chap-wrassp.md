# `wrassp` {#app-chap:wrassp}

## Using Praat's signal processing routines in the EMU-SDMS {#sec:app-chap-wrassp-praatsSigProc}

The R code snippet below shows how generating an `AsspDataObj` from scratch can be used in a function to place data from other sources into SSFF files. In this case it uses the `PraatR` R package (see http://www.aaronalbin.com/praatr/index.html) to execute Praat's `"To Formant (burg)..."` function to then store the data to a comma separated file using `"Down to Table..."`. The generated table is then read into R and the appropriate columns are placed into tracks of a `AsspDataObj` object. The `PraatToFormants2AsspDataObj` can be viewed as a template function as it can easily be adapted to use other functions provided by Praat or even other external tools.


```r
###################################
# uncomment and execute the next 
# two lines to install PraatR
# library(devtools)
# install_github('usagi5886/PraatR')
library(PraatR)
library(wrassp)
library(tools)

PraatToFormants2AsspDataObj <- function(path,
                                        command = 
                                          "To Formant (burg)...",
                                        arguments = list(0.0, 
                                                         5, 5500, 
                                                         0.025, 50), 
                                        columnNames = c("fm", "bw")){
  
  tmp1FileName = "tmp.ooTextFile"
  tmp2FileName = "tmp.table"
  
  tmp1FilePath = file.path(tempdir(), tmp1FileName)
  tmp2FilePath = file.path(tempdir(), tmp2FileName)
  
  # remove tmp files if they already exist
  unlink(file.path(tempdir(), tmp1FileName))
  unlink(file.path(tempdir(), tmp2FileName))
  
  # generate ooTextFile
  praat(command = command, 
        input=path, 
        arguments = arguments, 
        output = tmp1FilePath)
  
  # convert to Table
  praat("Down to Table...",
        input = tmp1FilePath,
        arguments = list(F, T, 6, F, 3, T, 3, T), 
        output = tmp2FilePath,
        filetype="comma-separated")
  
  # get vals
  df = read.csv(tmp2FilePath, stringsAsFactors=FALSE)
  df[df == '--undefined--'] = 0
  
  fmVals = df[,c(3, 5, 7, 9, 11)]
  fmVals = sapply(colnames(fmVals), function(x){
    as.integer(fmVals[,x])
    })
  colnames(fmVals) = NULL
  bwVals = data.matrix(df[,c(4, 6, 8, 10, 12)])
  bwVals = sapply(colnames(bwVals), function(x){
    as.integer(bwVals[,x])
    })
  colnames(bwVals) = NULL
  
  # get start time
  startTime = df[1,1]

  # create AsspDataObj
  ado = list()
  
  attr(ado, "trackFormats") =c("INT16", "INT16")
  
  if(arguments[[1]] == 0){
    sR = 1 / (0.25 * arguments[[4]])
  }else{
    sR = 1 / arguments[[1]]
  }
  
  attr(ado, "sampleRate") = sR
  
  tmpObj = read.AsspDataObj(path)
  attr(ado, "origFreq") = attr(tmpObj, "sampleRate")
  
  attr(ado, "startTime") = startTime
  
  attr(ado, "startRecord") = as.integer(1)
  
  attr(ado, "endRecord") = as.integer(nrow(fmVals))
  
  class(ado) = "AsspDataObj"
  
  AsspFileFormat(ado) <- "SSFF"
  AsspDataFormat(ado) <- as.integer(2)
  
  ado = addTrack(ado, columnNames[1], fmVals, "INT16")
  
  ado = addTrack(ado, columnNames[2], bwVals, "INT16")
  
  return(ado)
}

########################################
# Use of function on 'ae' emuDB
library(emuR)
```

```
## 
## Attaching package: 'emuR'
```

```
## The following object is masked from 'package:base':
## 
##     norm
```

```r
# create demo data in tempdir()
create_emuRdemoData(tempdir())

# create path to demo database
path2ae = file.path(tempdir(), "emuR_demoData", "ae_emuDB")

# list all .wav files in the ae emuDB
paths2wavFiles = list.files(path2ae, pattern = "*.wav$", 
                            recursive = TRUE, full.names = TRUE)

# loop through files
for(fp in paths2wavFiles){
  ado = PraatToFormants2AsspDataObj(fp)
  newPath = paste0(file_path_sans_ext(fp), '.praatFms')
  # print(paste0(fp, ' -> ', newPath)) # uncomment for simple log
  write.AsspDataObj(ado, file = newPath)
}

# load emuDB
ae = load_emuDB(path2ae, verbose = FALSE)

# add SSFF track definition
add_ssffTrackDefinition(ae, 
                        name = "praatFms", 
                        columnName = "fm",
                        fileExtension = "praatFms")

# test query + get_trackdata
sl = query(ae, "Phonetic == n")

td = get_trackdata(ae, sl, ssffTrackName = "praatFms", verbose = F)
```

```{r echo=FALSE, results='hide', message=FALSE>>=
# clean up emuR_demoData
unlink(file.path(tempdir(), "emuR_demoData"), recursive = TRUE)
```
