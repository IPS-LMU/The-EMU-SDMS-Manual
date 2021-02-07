######################################################################
# The script uses speakr::praat_run()
# The following will install speakr if not already installed
if (!require("speakr", character.only = TRUE)) {
  install.packages("speakr", dependences = TRUE)
}

#' Convert the output of a Praat procedure to a ASSP data object
#'
#' This function creates a Praat object from a sound file (available outputs:
#' "formants") and converts it into an ASSP data object which can be read by
#' wrassp.
#'
#' @param path Path to the .wav file.
#' @param object Praat object to generate (`"formant"`).
#' @param time_step Praat argument: The time between the centres of consecutive analysis frames.
#' @param max_fm Praat argument: Maximum number of formants per frames.
#' @param ceiling Praat argument: The maximum frequency of the formant search range in Hz.
#' @param window Praat argument: The effective duration of the analysis window in seconds.
#' @param pre_emph Praat argument: The +3 dB point for an inverted low-pass filter with a slope of +6 dB/octave.
#' @param columnNames Specify column names of the `AsspDataObj`.
praat2AsspDataObj <- function(
  path,
  object = "formant",
  time_step = 0.0,
  max_fm = 5,
  ceiling = 5500.0,
  window = 0.025,
  pre_emph = 50.0,
  columnNames = c("fm", "bw")
) {

  # Praat script path
  tmpPraatScript = file.path(tempdir(), "script.praat")
  # tmp Praat output path
  tmpPraatOut = file.path(tempdir(), "out.table")

  # remove tmp files if they already exist
  unlink(tmpPraatScript)
  unlink(tmpPraatOut)

  # write Praat script to tmp location
  write_praat_script(object, tmpPraatScript)

  # run Praat script
  speakr::praat_run(
    tmpPraatScript,
    path,
    time_step,
    max_fm,
    ceiling,
    window,
    pre_emph,
    tmpPraatOut
  )

  # get vals
  df = read.csv(tmpPraatOut, stringsAsFactors = FALSE)
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

  if(time_step == 0){
    sR = 1 / (0.25 * window)
  }else{
    sR = 1 / time_step
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

write_praat_script <- function(script, tmp_out) {
  if (script == "formant") {
    text = "# To Formant (burg)

form To formants
  text path ./
  real time_step 0.0
  integer max_fm 5
  real ceiling 5500.0
  real window 0.025
  real pre_emph 50.0
  text out ./
endform

sound = Read from file: path$

formant = To Formant (burg): time_step, max_fm, ceiling, window, pre_emph

table = Down to Table: \"no\", \"yes\", 6, \"no\", 3, \"yes\", 3, \"yes\"

Save as comma-separated file: out$

    "

    readr::write_lines(text, tmp_out)
  } else {
    stop()
  }
}
