# `wrassp` {#app-chap:wrassp}

## Using Praat's signal processing routines in the EMU-SDMS {#sec:app-chap-wrassp-praatsSigProc}

### `To Formant (burg)...` to SSFF files

The R code snippet below shows how generating an `AsspDataObj` from scratch can be used in a function to place data from other sources into SSFF files. In this case it uses the `PraatR` R package (see http://www.aaronalbin.com/praatr/index.html) to execute Praat's `"To Formant (burg)..."` function to then store the data to a comma separated file using `"Down to Table..."`. The generated table is then read into R and the appropriate columns are placed into tracks of a `AsspDataObj` object. The `PraatToFormants2AsspDataObj` can be viewed as a template function as it can easily be adapted to use other functions provided by Praat or even other external tools.

NOTE: this function can be accessed directly: `source("https://raw.githubusercontent.com/IPS-LMU/The-EMU-SDMS-Manual/master/R/praatToFormants2AsspDataObj.R")`



```r
###################################
# uncomment and execute the next
# two lines to install PraatR
# library(devtools)
# install_github('usagi5886/PraatR')
library(PraatR)

##' Call Praat's To Formant (burg)... function and
##' convert the output to an AsspDataObj object
##' @param path path to wav file
##' @param command Praat command to use
##' @param arguments arguments passed to \code{PraatR::praat()} arguments argument
##' @param columnNames specify column names of AsspDataObj
praatToFormants2AsspDataObj <- function(path,
                                        command = "To Formant (burg)...",
                                        arguments = list(0.0,
                                                         5,
                                                         5500,
                                                         0.025,
                                                         50),
                                        columnNames = c("fm", "bw")){

  tmp1FileName = "tmp.ooTextFile"
  tmp2FileName = "tmp.table"

  tmp1FilePath = file.path(tempdir(), tmp1FileName)
  tmp2FilePath = file.path(tempdir(), tmp2FileName)

  # remove tmp files if they already exist
  unlink(file.path(tempdir(), tmp1FileName))
  unlink(file.path(tempdir(), tmp2FileName))

  # generate ooTextFile
  PraatR::praat(command = command,
                input=path,
                arguments = arguments,
                output = tmp1FilePath)

  # convert to Table
  PraatR::praat("Down to Table...",
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

  tmpObj = wrassp::read.AsspDataObj(path)
  attr(ado, "origFreq") = attr(tmpObj, "sampleRate")

  attr(ado, "startTime") = startTime

  # attr(ado, "startRecord") = as.integer(1)

  attr(ado, "endRecord") = as.integer(nrow(fmVals))

  class(ado) = "AsspDataObj"

  wrassp::AsspFileFormat(ado) <- "SSFF"
  wrassp::AsspDataFormat(ado) <- as.integer(2) # == binary

  ado = wrassp::addTrack(ado, columnNames[1], fmVals, "INT16")

  ado = wrassp::addTrack(ado, columnNames[2], bwVals, "INT16")

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
```

How this function can be applied to wav files of an emuDB is shown below.


```r
library(emuR)

# create demo data in tempdir()
create_emuRdemoData(tempdir())

# create path to demo database
path2ae = file.path(tempdir(), "emuR_demoData", "ae_emuDB")

# list all .wav files in the ae emuDB
paths2wavFiles = list.files(path2ae, pattern = "*.wav$", 
                            recursive = TRUE, full.names = TRUE)

# loop through files
for(fp in paths2wavFiles){
  ado = praatToFormants2AsspDataObj(fp)
  newPath = paste0(tools::file_path_sans_ext(fp), '.praatFms')
  # print(paste0(fp, ' -> ', newPath)) # uncomment for simple log
  wrassp::write.AsspDataObj(ado, file = newPath)
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



### `To Pitch...` to SSFF files

The R code snippet below does the following:

a) calculates f0 via Praat's "To Pitch..." command;
b) smooths the f0 contour via Praat's "Smooth" command, if parameter "smooth" is set to TRUE
c) creates a PitchTier and then a TableOfReal
d) converts all of this into an AsspDataObj (which later on can be saved as an SSFF-file.)

A few comments about synchronized F0 and Formant values, whenever `praatToFormants2AsspDataObj()` and
`praatToPitch2AsspDataObj()` are involved:

- Be careful with the arguments list: 
- **The first entry is "Time step (s) (standard value: 0.0) the measurement interval (frame duration), in seconds.**
If you supply 0, Praat will use a time step of 0.75 / (pitch floor), e.g. 0.01 seconds if the pitch floor is 75 Hz;
in this example, Praat computes 100 pitch values per second. "
Here parameter 1 - Time step - is set to 0.00625 (Seconds) (as opposed to Praat's default of 0.0) in order
to keep it in line with Time step in "To Formant...",
because Time step in "To Formants..." is derived from
window length (which in "To Formant..." defaults to 0.025) (window length/4 (--> Time step in "To Formant..."
will usually be 0.00625))
- **The second parameter "Pitch floor (Hz) (standard value: 75 Hz)**:
candidates below this frequency will not be recruited.
This parameter determines the length of the analysis window: it will be 3 longest periods long, i.e.,
if the pitch floor is 75 Hz, the window will be 3/75 = 0.04 seconds long.
Note that if you set the time step to zero, the analysis windows for consecutive measurements will overlap appreciably:
Praat will always compute 4 pitch values within one window length, i.e., the degree of oversampling is 4."
Importantly, this parameter is set NOT to praat's default 75 Hz, but to 60 Hz, again because of correspondance
of window lengths between "To Pitch..." and "To Formants...". The actual window length in "To Formants..." will be twice as long
as the value given in the "To Formants..." command, i.e. the default of 0.025 will result in a window length of 0.05.
A window length in "To Pitch..." can indirectly achieved by using a pitch floor value of 60 Hz (given that 3/60 = 0.05).
In most cases, differing window lengths will not affect the temporal position of the F0 and Formant values, however, due
to problems near the edges, sometimes they will (and therefore result in non-synchronized F0 and Formant values).
Due to rounding errors, F0 and Formant values still might be slightly asynchronous; to avoid this, `praatToPitch2AsspDataObj()`
rounds the start time with a precicion of 0.001 ms (via round(attr(ado, "startTime"),6) in the very end).
- **The third parameter (default: 600) is the pitch ceiling** (and this parameter will not affect any other parameters indirectly)

NOTE: this function can be accessed directly: `source("https://raw.githubusercontent.com/IPS-LMU/The-EMU-SDMS-Manual/master/R/praatToPitch2AsspDataObj.R")`



```r
###################################
# uncomment and execute the next
# two lines to install PraatR
# library(devtools)
# install_github('usagi5886/PraatR')
library(PraatR)

##' Call Praat's To Pitch... function and
##' convert the output to an AsspDataObj object
##' @param path path to wav file
##' @param command Praat command to use
##' @param arguments arguments passed to \code{PraatR::praat()} arguments argument
##' @param columnNames specify column names of AsspDataObj
##' @param smooth apply Praat's "Smooth" command
praatToPitch2AsspDataObj <- function(path,
                                     command = "To Pitch...",
                                     arguments = list(0.00625,
                                                      60.0,
                                                      600.0),
                                     columnNames = c("f0"),
                                     smooth = TRUE){

  tmp1FileName = "tmp.ooTextFile"
  tmp2FileName = "tmp2.ooTextFile"
  tmp3FileName = "tmp3.PitchTier"
  tmp4FileName = "tmp4.txt"

  tmp1FilePath = file.path(tempdir(), tmp1FileName)
  tmp2FilePath = file.path(tempdir(), tmp2FileName)
  tmp3FilePath = file.path(tempdir(), tmp3FileName)
  tmp4FilePath = file.path(tempdir(), tmp4FileName)

  # remove tmp files if they already exist
  unlink(file.path(tempdir(), tmp1FileName))
  unlink(file.path(tempdir(), tmp2FileName))
  unlink(file.path(tempdir(), tmp3FileName))
  unlink(file.path(tempdir(), tmp4FileName))

  # generate ooTextFile
  PraatR::praat(command = command,
                input=path,
                arguments = arguments,
                output = tmp1FilePath,
                overwrite = TRUE)

  if (smooth){
    PraatR::praat("Smooth...",
                  input = tmp1FilePath,
                  arguments = list(10),
                  output = tmp2FilePath,
                  overwrite = TRUE)
  } else {
    tmp2FilePath = tmp1FilePath
  }
  nframes = as.numeric(PraatR::praat("Get number of frames",
                                     input = tmp2FilePath,
                                     simplify = TRUE))
  timestep = as.numeric((PraatR::praat("Get time step",
                                       input = tmp2FilePath,
                                       simplify = TRUE)))
  sR = 1/timestep
  start = as.numeric((PraatR::praat("Get time from frame number...",
                                    input = tmp2FilePath,
                                    simplify = TRUE,
                                    arguments = list(1))))
  end = as.numeric((PraatR::praat("Get time from frame number...",
                                  input = tmp2FilePath,
                                  simplify = TRUE,
                                  arguments = list(nframes))))



  # convert to PitchTier
  PraatR::praat("Down to PitchTier",
                input = tmp2FilePath,
                output = tmp3FilePath,
                overwrite = TRUE)

  # Down to TableOfReal: "Hertz"
  PraatR::praat("Down to TableOfReal...",
                input = tmp3FilePath,
                output = tmp4FilePath,
                arguments = list("Hertz"),
                filetype = "headerless spreadsheet",
                overwrite = TRUE)

  # create empty df that holds all time steps
  df = data.frame(Time = seq(start, end, by = timestep), F0 = 0)
  # get vals
  df_tmp = read.csv(tmp4FilePath, stringsAsFactors = FALSE, sep = "\t")[,2:3]
  # and fill up empty df (ensures every timestep has a value)
  df$F0[df$Time %in% df_tmp$Time] = df_tmp$F0
  df

  # create AsspDataObj
  ado = list()

  attr(ado, "trackFormats") = c("INT16")
  attr(ado, "sampleRate") = sR

  tmpObj = wrassp::read.AsspDataObj(path)
  attr(ado, "origFreq") = attr(tmpObj, "sampleRate")

  attr(ado, "startTime") = start
  attr(ado, "endRecord") = as.integer(nframes)

  class(ado) = "AsspDataObj"

  wrassp::AsspFileFormat(ado) <- "SSFF"
  wrassp::AsspDataFormat(ado) <- as.integer(2)
  f0Vals = as.integer(df[,"F0"])
  ado = wrassp::addTrack(ado, "f0", f0Vals, "INT16")

  # prepend missing values as praat sometimes
  # starts fairly late
  if(start > 1 / sR){
    nr_of_missing_samples = floor(start / (1/sR))

    missing_f0_vals = matrix(0,
                             nrow = nr_of_missing_samples,
                             ncol = ncol(ado$f0))

    # prepend values
    ado$f0 = rbind(missing_f0_vals, ado$f0)

    # fix start time
    attr(ado, "startTime") = start - nr_of_missing_samples * (1 / sR)
    attr(ado, "startTime") = round(attr(ado, "startTime"), 6)
  }
  return(ado)
}
```

How this function can be applied to wav files of an emuDB is shown below.


```r
library(emuR)

# create demo data in tempdir()
create_emuRdemoData(tempdir())

# create path to demo database
path2ae = file.path(tempdir(), "emuR_demoData", "ae_emuDB")

# test the function of converting praat formant data to emuR
paths2wavFiles = list.files(path2ae,
                            pattern = "wav$",
                            recursive = TRUE,
                            full.names = TRUE)

# loop through files
for(fp in paths2wavFiles){
  ado = praatToPitch2AsspDataObj(fp)
  newPath = paste0(tools::file_path_sans_ext(fp), '.praatF0')
  # print(paste0(fp, ' -> ', newPath)) # uncomment for simple log
  wrassp::write.AsspDataObj(ado, file = newPath)
}

# load emuDB
ae = load_emuDB(path2ae, verbose = FALSE)

# add SSFF track definition
add_ssffTrackDefinition(ae,
                        name = "praatF0",
                        columnName = "f0",
                        fileExtension = "praatF0")

# test query + get_trackdata
sl = query(ae, "Phonetic == n")

td = get_trackdata(ae, sl, ssffTrackName = "praatF0", verbose = F)

# configure EMU-webApp to show new track
sc_order = get_signalCanvasesOrder(ae, "default")

set_signalCanvasesOrder(ae, "default", c(sc_order, "praatF0"))

# serve(ae) # uncomment to view in EMU-webApp
```





## Using OpenSMILE signal processing routines in the EMU-SDMS {#sec:app-chap-wrassp-opensmileSigProc}

NOTE: this function can be accessed directly as follows: `source("https://raw.githubusercontent.com/IPS-LMU/The-EMU-SDMS-Manual/master/R/SMILExtract2AsspDataObj.R")`


```r
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

  tmpObj = wrassp::read.AsspDataObj(path)
  attr(ado, "origFreq") = attr(tmpObj, "sampleRate")

  attr(ado, "startTime") = startTime

  # attr(ado, "startRecord") = as.integer(1)

  attr(ado, "endRecord") = as.integer(nrow(df))

  class(ado) = "AsspDataObj"

  wrassp::AsspFileFormat(ado) <- "SSFF"
  wrassp::AsspDataFormat(ado) <- as.integer(2)

  # add every column as new track
  if(columsAsTracks){
    attr(ado, "trackFormats") = rep("REAL32", ncol(df))
    for(i in 1:ncol(df)){
      ado = wrassp::addTrack(ado,
                             trackname = colNames[i],
                             data = df[,i],
                             format = "REAL32")
    }
  }else{
    attr(ado, "trackFormats") = "REAL32"
    ado = wrassp::addTrack(ado,
                           trackname = "SMILExtractAll",
                           data = df,
                           format = "REAL32")

  }

  return(ado)
}
```

How this function can be applied to wav files of an emuDB is shown below.


```r
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

# serve(ae) # uncomment to view in EMU-webApp
```



