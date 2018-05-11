# (PART) Main `emuR` function and object index {-}

# `emuR` - package functions {#chap:emuRpackageDetails}


This chapter gives an overview of the essential functions and central objects provided by the `emuR` package. It is not meant as a comprehensive list of every function and object provided by `emuR`, but rather tries to group the essential functions into meaningful categories for easier navigation. The categories presented in this chapter are:


- Import and conversion routines (Section \@ref(sec:emuRpackageDetails-importRoutines)),
- `emuDB` interaction and configuration routines (Section \@ref(sec:emuRpackageDetails-emuDBinteract)),
- `EMU-webApp` configuration routines (Section \@ref(sec:emuRpackageDetails-emuWebAppConfig)),
- Data extraction routines (Section \@ref(sec:emuRpackageDetails-dataExtr)),
- Central objects in `emuR` (Section \@ref(sec:emuRpackageDetails-centralObjects)), and
- Export routines (Section \@ref(sec:emuRpackageDetails-exportRoutines)).

If a comprehensive list of every function and object provided by the `emuR` package is required, R's `help()` function (see R Example \@ref(rexample:emuRfuncs-help)) can be used.



```r
help(package="emuR")
```

## Import and conversion routines {#sec:emuRpackageDetails-importRoutines}

As most people that are starting to use the EMU-SDMS will probably already have some form of annotated data, we will first show how to convert existing data to the `emuDB` format. For a guide to creating an `emuDB` from scratch and for information about this format see Chapter \@ref(chap:emuDB).

### Legacy EMU databases

For people transitioning to `emuR` from the legacy EMU system, `emuR` provides a function for converting existing legacy EMU databases to the new `emuDB` format. R Example \@ref(rexample:emuRpackageDetailsConvLegacy) shows how to convert a legacy database that is part of the demo data provided by the `emuR` package.



```r
# load the package
library(emuR)

# create demo data in directory provided by the tempdir() function
create_emuRdemoData(dir = tempdir())

# get the path to a .tpl file of
# a legacy EMU database that is part of the demo data
tplPath = file.path(tempdir(),
                    "emuR_demoData",
                    "legacy_ae",
                    "ae.tpl")

# convert this legacy EMU database to the emuDB format
convert_legacyEmuDB(emuTplPath = tplPath, targetDir = tempdir())
```

This will create a new `emuDB` in a temporary directory, provided by R's `tempdir()` function, containing all the information specified in the `.tpl` file. The name of the new `emuDB` is the same as the basename of the `.tpl` file from which it was generated. In other words, if the template file of the legacy EMU database has path `A` and the directory to which the converted database is to be written has path `B`, then  `convert_legacyEmuDB(emuTplPath = "A", targetdir = "B")` will create an `emuDB` directory in `B` from the information stored in  `A`.




### TextGrid collections

A further function provided is the `convert_TextGridCollection()` function. This function converts an existing `.TextGrid` and `.wav` file collection to the `emuDB` format. In order to pair the correct files together the `.TextGrid` files and the `.wav` files must have the same name (i.e., file name without extension). A further restriction is that the tiers contained within all the `.TextGrid` files have to be equal in name and type (equal subsets can be chosen using the `tierNames` argument of the function). For example, if all `.TextGrid` files contain the tiers `Syl: IntervalTier`, `Phonetic: IntervalTier` and `Tone: TextTier` the conversion will work. However, if a single `.TextGrid` of the collection has the additional tier `Word: IntervalTier` the conversion will fail, although it can be made to work by specifying the equal tier subset `equalSubset = c('Syl', 'Phonetic', 'Tone')` and passing it into the function argument `convert\_TextGridCollection(..., tierNames = equalSubset, ...)`. R Example \@ref(rexample:emuRpackageDetailsConvTGcol) shows how to convert a TextGrid collection to the `emuDB` format.


```r
# get the path to a directory containing
# .wav & .TextGrid files that is part of the demo data
path2directory = file.path(tempdir(),
                           "emuR_demoData",
                           "TextGrid_collection")

# convert this TextGridCollection to the emuDB format
convert_TextGridCollection(path2directory, dbName = "myTGcolDB",
                           targetDir = tempdir())
```

R Example \@ref(rexample:emuRpackageDetailsConvTGcol) will create a new `emuDB` in the directory `tempdir()` called `myTGcolDB`. The `emuDB` will contain all the tier information from the `.TextGrid` files but will not contain hierarchical information, as `.TextGrid` files do not contain any linking information. It is worth noting that it is possible to semi-automatically generate links between time-bearing levels using the `autobuild_linkFromTimes()` function. An example of this was given in Chapter \@ref(chap:tutorial).
R Example \@ref(rexample:emuRpackageDetailsConvTGcol) creates a new `emuDB` in the directory `tempdir()` called `myTGcolDB`. The `emuDB` contains all the tier information from the `.TextGrid` files no hierarchical information, as `.TextGrid` files do not contain any linking information. Further, it is possible to semi-automatically generate links between time-bearing levels using the `autobuild_linkFromTimes()` function. An example of this was given in Chapter \@ref(chap:tutorial).



### BPF collections

Similar to the `convert_TextGridCollection()` function, the `emuR` package also provides a function for converting file collections consisting of BPF and `.wav` files to the `emuDB` format. R Example \@ref(rexample:emuRpackageDetailsConvBPFcol) shows how this can be achieved.


```r
# get the path to a directory containing
# .wav & .par files that is part of the demo data
path2directory = file.path(tempdir(),
                           "emuR_demoData",
                           "BPF_collection")

# convert this BPFCollection to the emuDB format
convert_BPFCollection(path2directory, dbName = 'myBPF-DB',
                      targetDir = tempdir(), verbose = F)
```

As the BPF format also permits annotation items to be linked to one another, this conversion function can optionally preserve this hierarchical information by specifying the `refLevel` argument.



### txt collections

A further conversion routine provided by the `emuR` package is the `convert_txtCollection()` function. As with other file collection conversion functions, it converts file pair collections but this time consisting of plain text `.txt` and `.wav` files to the `emuDB` format. Compared to other conversion routines it behaves slightly differently, as unformatted plain text files do not contain any time information. It therefore places all the annotations of a single `.txt` file into a single timeless annotation item on a level of type `ITEM` called *bundle*.


```r
# get the path to a directory containing .wav & .par
# files that is part of the demo data
path2directory = file.path(tempdir(),
                           "emuR_demoData",
                           "txt_collection")

# convert this txtCollection to the emuDB format
convert_txtCollection(sourceDir = path2directory,
                      dbName = "txtCol",
                      targetDir = tempdir(),
                      attributeDefinitionName = "transcription",
                      verbose = F)
```

Using this conversion routine creates a bare-bone, single route node `emuDB` which either can be further manually annotated or automatically hierarchically annotated using the `runBASwebservice_*`[^1-chap:emuRpackageDetails] functions of `emuR`. It is worth noting that these functions are already part of the `emuR` package; however, they are still considered to have a beta status which is why they are omitted from this documentation. In future versions of this documentation a section or chapter will be dedicated to using the BAS Webservices [@kisler:2012a] to automatically generate a hierarchical annotation structure for an entire `emuDB`.

[^1-chap:emuRpackageDetails]: Functions contributed by Nina Pörner.

## `emuDB` interaction and configuration routines {#sec:emuRpackageDetails-emuDBinteract}

This section provides a tabular overview of all the `emuDB` interaction routines provided by the `emuR` package and also provides a short description of each function or group of functions.


```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

<table>
<caption>(\#tab:emuRpackageDetails-emuDBinteract)Overview of the `emuDB` interaction routines provided by `emuR`.</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Functions </th>
   <th style="text-align:left;"> Description </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> `add/list/remove_attrDefLabelGroup()` </td>
   <td style="text-align:left;"> Add / list / remove label group to / of / from `attributeDefinition` of `emuDB` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `add/list/remove_labelGroup()` </td>
   <td style="text-align:left;"> Add / list / remove global label group to / of / from `emuDB` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `add/list/remove_levelDefinition()` </td>
   <td style="text-align:left;"> Add / list / remove level definition to / of / from `emuDB` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `add/list/remove_linkDefinition()` </td>
   <td style="text-align:left;"> Add / list / remove link definition to / of / from `emuDB` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `add/list/ remove_ssffTrackDefinition()` </td>
   <td style="text-align:left;"> Add / list / remove SSFF track definition to / of / from `emuDB` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `add/list/rename/remove_attributeDefinition()` </td>
   <td style="text-align:left;"> Add / list / rename / remove attribute definition to / of / from `emuDB` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `add_files()` </td>
   <td style="text-align:left;"> Add files to `emuDB` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `autobuild_linkFromTimes()` </td>
   <td style="text-align:left;"> Autobuild links between two levels using their time information `emuDB` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `create_emuDB()` </td>
   <td style="text-align:left;"> Create empty `emuDB` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `duplicate_level()` </td>
   <td style="text-align:left;"> Duplicate level </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `import_mediaFiles()` </td>
   <td style="text-align:left;"> Import media files to `emuDB` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `list_bundles()` </td>
   <td style="text-align:left;"> List bundles of `emuDB` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `list_files()` </td>
   <td style="text-align:left;"> List files of `emuDB` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `list_sessions()` </td>
   <td style="text-align:left;"> List sessions of `emuDB` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `load_emuDB()` </td>
   <td style="text-align:left;"> Load `emuDB` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `replace_itemLabels()` </td>
   <td style="text-align:left;"> Replace item labels </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `set/get/remove_legalLabels()` </td>
   <td style="text-align:left;"> Set / get / remove legal labels of attribute definition of `emuDB` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `rename_emuDB()` </td>
   <td style="text-align:left;"> Rename `emuDB` </td>
  </tr>
</tbody>
</table>

## `EMU-webApp` configuration routines {#sec:emuRpackageDetails-emuWebAppConfig}

This section provides a tabular overview of all the `EMU-webApp` configuration routines provided by the `emuR` package and also provides a short description of each function or group of functions. See Chapter \@ref(chap:emu-webApp) for examples of how to use these functions.

<table>
<caption>(\#tab:emuRpackageDetails-emuWebAppConfig)Overview of the `EMU-webApp` configuration functions provided by `emuR`.</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Functions </th>
   <th style="text-align:left;"> Description </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> `add/list/remove_perspective()` </td>
   <td style="text-align:left;"> Add / list / remove perspective to / of / from `emuDB` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `set/get_levelCanvasesOrder()` </td>
   <td style="text-align:left;"> Set / get level canvases order for `EMU-webApp` of `emuDB` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `set/get_signalCanvasesOrder()` </td>
   <td style="text-align:left;"> Set / get signal canvases order for `EMU-webApp` of `emuDB` </td>
  </tr>
</tbody>
</table>

It is worth noting that the legal labels configuration of the `emuDB` configuration will also affect how the `EMU-webApp` behaves, as it will not permit any other labels to be entered except those defined as legal labels.

## Data extraction routines {#sec:emuRpackageDetails-dataExtr}

This section provides a tabular overview of all the data extraction routines provided by the `emuR` package and also provides a short description of each function or group of functions. See Chapter \@ref(chap:querysys) and Chapter \@ref(chap:sigDataExtr) for multiple examples of how the various data extraction routines can be used.

<table>
<caption>(\#tab:emuRpackageDetails-dataExtr)Overview of the data extraction functions provided by `emuR`.</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Functions </th>
   <th style="text-align:left;"> Description </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> `query()` </td>
   <td style="text-align:left;"> Query `emuDB` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `requery_hier()` </td>
   <td style="text-align:left;"> Requery hierarchical context of a segment list in an `emuDB` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `requery_seq()` </td>
   <td style="text-align:left;"> Requery sequential context of segment list in an `emuDB` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `get_trackdata()` </td>
   <td style="text-align:left;"> Get trackdata from loaded `emuDB` </td>
  </tr>
</tbody>
</table>

An overview of how the various data extraction functions in the `emuR` package interact is displayed in Figure \@ref(fig:emuRpackageDetails-dataExtrRel). It is an updated version of a figure presented in @harrington:2010a on page 121 that additionally shows the output type of various post-processing functions (e.g., `dcut()`).


<div class="figure" style="text-align: center">
<img src="pics/keyFuncsRel.png" alt="Relationship between various key functions in `emuR` and their output. Figure is an updated version of Figure 5.7 in @harrington:2010a on page 121." width="75%" />
<p class="caption">(\#fig:emuRpackageDetails-dataExtrRel)Relationship between various key functions in `emuR` and their output. Figure is an updated version of Figure 5.7 in @harrington:2010a on page 121.</p>
</div>

## Central objects {#sec:emuRpackageDetails-centralObjects}

This section provides a tabular overview of the central objects  provided by the `emuR` package and also provides a short description of each object. See Chapter \@ref(chap:querysys) and \@ref(chap:sigDataExtr) for examples of functions returning these objects and how they can be used.

<table>
<caption>(\#tab:emuRpackageDetails-centralObjects)Overview of the central objects of the `emuR` package.</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Object </th>
   <th style="text-align:left;"> Description </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> `emuRsegs` </td>
   <td style="text-align:left;"> A `emuR` segment list is a list of segment descriptions. Each segment descriptions describes a sequence of annotation items. The list is usually a result of an `emuDB` query using the `query()` function. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `trackdata` </td>
   <td style="text-align:left;"> A track data object is the result of `get_trackdata()` and usually contains the extracted signal data tracks belonging to segments of a segment list. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `emuRtrackdata` </td>
   <td style="text-align:left;"> A `emuR` track data object is the result of `get_trackdata()` if the `resultType` parameter is set to `emuRtrackdata` or the result of an explicit call to `create_emuRtrackdata`. Compared to the `trackdata` object it is a sub-class of a `data.table`/`data.frame` which is meant to ease integration with other packages for further processing. It can be viewed as an amalgamation of an `emuRsegs` and a `trackdata` object as it contains the information stored in both objects (see also `?create_emuRtrackdata()`). </td>
  </tr>
</tbody>
</table>


## Export routines {#sec:emuRpackageDetails-exportRoutines}

Although associated with data loss, the `emuR` package provides an export routine to the common TextGrid collection format called `export_TextGridCollection()`. While exporting is sometimes unavoidable, it is essential that users are aware that exporting to other formats which do not support or only partially support hierarchical annotations structures will lead to the loss of the explicit linking information. Although the `autobuild_linkFromTimes()` can partially recreate some of the hierarchical structure, it is advised that the export routine be used with extreme caution. R Example \@ref(rexample:emuR-funcsExport) shows how `export_TextGridCollection()` can be used to export the levels *Text*, *Syllable* and *Phonetic* of the *ae* demo `emuDB` to a TextGrid collection. Figure \@ref(fig:emuRfuncs-msajc003-fromExport) show the content of the created `msajc003.TextGrid` file as displayed by Praat's `"Draw visible sound and Textgrid..."` procedure.



```r
# get the path to "ae" emuDB
path2ae = file.path(tempdir(), "emuR_demoData", "ae_emuDB")

# load "ae" emuDB
ae = load_emuDB(path2ae)

# export the levels "Text", "Syllable"
# and "Phonetic" to a TextGrid collection
export_TextGridCollection(ae,
                          targetDir = tempdir(),
                          attributeDefinitionNames = c("Text",
                                                       "Syllable",
                                                       "Phonetic"))
```



<div class="figure" style="text-align: center">
<img src="pics/msajc003_fromExport.png" alt="TextGrid annotation generated by the `export_TextGridCollection()` function containing the tiers (from top to bottom): *Text*, *Syllable*, *Phonetic*." width="75%" />
<p class="caption">(\#fig:emuRfuncs-msajc003-fromExport)TextGrid annotation generated by the `export_TextGridCollection()` function containing the tiers (from top to bottom): *Text*, *Syllable*, *Phonetic*.</p>
</div>

Depending on user requirements, additional export routines might be added to the `emuR` in the future.


## Conclusion

This chapter provided an overview of the essential functions and central objects, grouped into meaningful categories, provided by the `emuR` package. It is meant as a quick reference for the user to quickly find functions she or he is interested in.



