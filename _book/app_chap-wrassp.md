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
  
  # attr(ado, "startRecord") = as.integer(1)
  
  attr(ado, "endRecord") = as.integer(nrow(fmVals))
  
  class(ado) = "AsspDataObj"
  
  AsspFileFormat(ado) <- "SSFF"
  AsspDataFormat(ado) <- as.integer(2)
  
  ado = addTrack(ado, columnNames[1], fmVals, "INT16")
  
  ado = addTrack(ado, columnNames[2], bwVals, "INT16")
  
  # add missing values at the start as Praat sometimes 
  # has very late start values which causes issues 
  # in the SSFF file format as this sets the startRecord 
  # depending on the start time of the first sample
  if(startTime > 1/sR){
    nr_of_missing_samples = floor(startTime / (1/sR))
    
    missing_fm_vals = matrix(0,
                             nrow = nr_of_missing_samples, 
                             ncol = ncol(ado$fm))
    
    
    missing_bw_vals = matrix(0,
                             nrow = nr_of_missing_samples, 
                             ncol = ncol(ado$bw))
    
    # prepend values
    ado$fm = rbind(missing_fm_vals, ado$fm)
    ado$bw = rbind(missing_fm_vals, ado$bw)
    
    # fix start time
    attr(ado, "startTime") = startTime - nr_of_missing_samples * (1/sR)
  }  

  
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



## Using OpenSMILE signal processing routines in the EMU-SDMS {#sec:app-chap-wrassp-opensmileSigProc}


```r
library(wrassp)
library(tools)
##' convert CSV output of SMILExtract to AsspDataObject
##' @param path path to wav file
##' @param SMILExtractPath path to SMILExtract executable
##' @param configPath path to openSMILE config file
##' @param columsAsTracks if TRUE -> every column will be placed in it's own track
##' if FALSE -> every column is placed into a single track called SMILExtractAll
SMILExtract2AsspDataObj <- function(path,
                                    SMILExtractPath,
                                    configPath,
                                    columsAsTracks = TRUE){
  
  tmp1FileName = "tmp.csv"
  
  tmp1FilePath = file.path(tempdir(), tmp1FileName)
  
  # remove tmp file if it already exists
  unlink(file.path(tempdir(), tmp1FileName))
  
  system(paste0(SMILExtractPath, 
                " -C ", configPath,
                " -I ", path,
                " -O ", tmp1FilePath), 
         ignore.stdout = T, 
         ignore.stderr = T)
  
  # get vals
  df = suppressMessages(readr::read_delim(tmp1FilePath, 
                                          delim = ";"))
  
  # extract + remove frameIndex/frameTime
  frameIndex = df$frameIndex
  frameTime = df$frameTime
  
  df$frameIndex = NULL
  df$frameTime = NULL
  
  df = as.matrix(df) 
  
  colNames = colnames(df)
  
  # get start time
  startTime = frameTime[1]
  
  # create AsspDataObj
  ado = list()
  
  attr(ado, "sampleRate") = 1/frameTime[2] # second frameTime should be stepsize
  
  tmpObj = read.AsspDataObj(path)
  attr(ado, "origFreq") = attr(tmpObj, "sampleRate")
  
  attr(ado, "startTime") = startTime
  
  # attr(ado, "startRecord") = as.integer(1)
  
  attr(ado, "endRecord") = as.integer(nrow(df))
  
  class(ado) = "AsspDataObj"
  
  AsspFileFormat(ado) <- "SSFF"
  AsspDataFormat(ado) <- as.integer(2)
  
  # add every column as new track
  if(columsAsTracks){
    attr(ado, "trackFormats") = rep("REAL32", ncol(df))
    for(i in 1:ncol(df)){
      ado = addTrack(ado, 
                     trackname = colNames[i], 
                     data = df[,i], 
                     format = "REAL32")  
    }
  }else{
    attr(ado, "trackFormats") = "REAL32"
    ado = addTrack(ado, 
                   trackname = "SMILExtractAll", 
                   data = df, 
                   format = "REAL32")
    
  }
  
  return(ado)
}

########################################
# Use of function on 'ae' emuDB
library(emuR)

# create demo data in tempdir()
create_emuRdemoData(tempdir())

# create path to demo database
path2ae = file.path(tempdir(), "emuR_demoData", "ae_emuDB")

# list all .wav files in the ae emuDB
paths2wavFiles = list.files(path2ae, 
                            pattern = "*.wav$", 
                            recursive = TRUE, 
                            full.names = TRUE)

# loop through files
for(fp in paths2wavFiles){
  ado = SMILExtract2AsspDataObj(fp,                                
                                SMILExtractPath = "~/programs/opensmile-2.3.0/bin/SMILExtract",
                                configPath = "~/programs/opensmile-2.3.0/config/demo/demo1_energy.conf")
  newPath = paste0(file_path_sans_ext(fp), '.SMILExtract')
  # print(paste0(fp, ' -> ', newPath)) # uncomment for simple log
  write.AsspDataObj(ado, file = newPath)
}

# load emuDB
ae = load_emuDB(path2ae, verbose = FALSE)

# add SSFF track definition
add_ssffTrackDefinition(ae, 
                        name = "SMILExtract", 
                        columnName = "pcm_LOGenergy",
                        fileExtension = "SMILExtract")

# test query + get_trackdata
sl = query(ae, "Phonetic == n")

td = get_trackdata(ae, 
                   sl, 
                   ssffTrackName = "SMILExtract",
                   verbose = F)

# test display
set_signalCanvasesOrder(ae, 
                        perspectiveName = "default",
                        order = c("OSCI", "SPEC", "SMILExtract"))

# serve(ae)
```



