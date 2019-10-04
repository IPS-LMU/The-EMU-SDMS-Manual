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
