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
