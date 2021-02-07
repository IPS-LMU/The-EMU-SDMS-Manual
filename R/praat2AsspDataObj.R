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
#' @param object Praat object to generate (`"formant"` or `"pitch"`).
#' @param time_step Praat argument: The time between the centres of consecutive analysis frames.
#' @param max_fm Formant argument: Maximum number of formants per frames.
#' @param ceiling Formant argument: The maximum frequency of the formant search range in Hz.
#' @param window Formant argument: The effective duration of the analysis window in seconds.
#' @param pre_emph Formant argument: The +3 dB point for an inverted low-pass filter with a slope of +6 dB/octave.
#' @param pitch_floor Pitch argument: Candidates below this frequency will not be recruited.
#' @param pitch_ceiling Pitch argument: Candidates above this frequency will be ignored.
#' @param pitch_units Pitch argument: Pitch unit as character (`"Herz"` or `"semitones"`).
#' @param smooth Pitch argument: If `TRUE`, the pitch track is smoothed using `smooth_bw` as bandwidth.
#' @param smooth_bw Pitch argument: Smoothing bandwidth in Hz.
praat2AsspDataObj <- function(
  path,
  object = "formant",
  time_step = 0.0,
  # formant settings
  max_fm = 5,
  ceiling = 5500.0,
  window = 0.025,
  pre_emph = 50.0,
  # pitch settings
  pitch_floor = 75.0,
  pitch_ceiling = 600.0,
  pitch_units = "Hertz",
  smooth = FALSE,
  smooth_bw = 10.0
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

  if (object == "formant") {
    ado <- praat_run_formant(tmpPraatScript,
                             path,
                             time_step,
                             max_fm,
                             ceiling,
                             window,
                             pre_emph,
                             tmpPraatOut,
                             columnNames = c("fm", "bw"))
  } else if (object == "pitch") {
    tmpPitchInfo = file.path(tempdir(), "pitchInfo.csv")
    unlink(tmpPitchInfo)

    ado <- praat_run_pitch(tmpPraatScript,
                            path,
                            time_step,
                            pitch_floor,
                            pitch_ceiling,
                            pitch_units,
                            smooth,
                            smooth_bw,
                            tmpPraatOut,
                            tmpPitchInfo,
                            columnNames = c("f0"))
  }

  return(ado)
}


######################################################################
#
# function to run Praat formant script
praat_run_formant <- function(tmpPraatScript,
                             path,
                             time_step,
                             max_fm,
                             ceiling,
                             window,
                             pre_emph,
                             tmpPraatOut,
                             columnNames) {
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
  if(startTime > 1/sR) {
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
    return(ado)
  }
}





######################################################################
#
# function to run Praat formant script
praat_run_pitch <- function(tmpPraatScript,
                            path,
                            time_step,
                            pitch_floor,
                            pitch_ceiling,
                            pitch_units,
                            smooth,
                            smooth_bw,
                            tmpPraatOut,
                            tmpPitchInfo,
                            columnNames) {
  if (smooth) {
    smooth = 1
  } else {
    smooth = 0
  }

  # run Praat script
  speakr::praat_run(
    tmpPraatScript,
    path,
    time_step,
    pitch_floor,
    pitch_ceiling,
    pitch_units,
    smooth,
    smooth_bw,
    tmpPraatOut,
    tmpPitchInfo
  )

  pitchInfo = read.csv(tmpPitchInfo, stringsAsFactors = FALSE)

  nframes = pitchInfo$nframes[1]
  timestep = pitchInfo$timestep[1]
  sR = 1/timestep
  start = pitchInfo$start[1]
  end = pitchInfo$end[1]

  # create empty df that holds all time steps
  df = data.frame(Time = seq(start, end, by = timestep), F0 = 0)
  # get vals
  df_tmp = read.csv(tmpPraatOut, stringsAsFactors = FALSE, sep = "\t")[,2:3]
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


######################################################################
#
# write Praat script to tmp dir
write_praat_script <- function(script, tmp_out) {
  if (script == "formant") {
    readr::write_lines(formant_text, tmp_out)
  } else if (script == "pitch") {
    readr::write_lines(pitch_text, tmp_out)
  } else {
    stop()
  }
}

######################################################################
#
# formant Praat script text
formant_text = "# To Formant (burg)

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


######################################################################
#
# formant pitch script text
pitch_text = "# To Pitch

form To pitch
  text path ./
  real time_step 0.0
  real pitch_floor 75.0
  real pitch_ceiling 600.0
  word pitch_units Hertz
  boolean smooth 0
  real smooth_bw 10.0
  text out ./
  text pitchInfo ./
endform

sound = Read from file: path$

pitch = To Pitch: time_step, pitch_floor, pitch_ceiling

if smooth == 0
  pitch = Smooth: smooth_bw
endif

nframes = Get number of frames
timestep = Get time step
start = Get time from frame number: 1
end = Get time from frame number: nframes

header$ = \"nframes,timestep,start,end\"
writeFileLine(pitchInfo$, header$)
line$ = \"'nframes','timestep','start','end'\"
appendFileLine(pitchInfo$, line$)

Down to PitchTier

Down to TableOfReal: pitch_units$

Save as headerless spreadsheet file: out$

"
