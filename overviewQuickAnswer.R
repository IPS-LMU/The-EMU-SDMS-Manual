library(emuR)
library(ggplot2)
create_emuRdemoData(dir = "~/Desktop/")
# look at folder -> open TextGrid in Praat

dbHandle = load_emuDB("~/Desktop/emuR_demoData/ae_emuDB/")
sl = query(dbHandle, "Phonetic == i: | o: | V")
sl_rq = requery_hier(dbHandle, sl, level = "Syllable")
sl$labels = sl_rq$labels
td = get_trackdata(dbHandle, sl, onTheFlyFunctionName = "forest", resultType = "emuRtrackdata")
ggplot(td) +
  aes(x=times_rel,y=T1,col=labels,group=sl_rowIdx) +
  geom_line() +
  labs(x = "vowel duration", y = "F1 (Hz)")
