# File Formats {#app_chap:fileFormats}

## File descriptions

### `_DBconfig.json` {#subsec:app-chapFileFormatsDBconfig}

The `_DBconfig.json` file contains the configuration options of the database. People familiar with the legacy EMU system will recognize this as the replacement file for the legacy template (`.tpl`) file. By convention, variables or strings written entirely in capital letters indicate a constant variable that usually has a special meaning. This is also the case with strings like this found in the `_DBconfig.json` (`"STRING"`, `"ITEM"` ,`"SEGMENT"`, `"EVENT"`, `"OSCI"`, ... ).

The `_DBconfig.json` file contains the following fields:

<!-- max indentation seems to be 4 -->

-   `"name"` specifies the name of the database

-   `"UUID"` a unique ID given to each database

-   `"mediafileExtension"` the main mediafileExtension (currently only uncompressed `.wav` files are supported in every component of the EMU system. This is also the recommended audio format for the [emu-sdms]{acronym-label="emu-sdms" acronym-form="singular+short"}.)

-   `"ssffTrackDefinitions"` an array of definitions defining the SSFF tracks of the database. Each `ssffTrackDefinition` consists of:

    -   `"name"` the name of the `ssffTrackDefinition`

    -   `"columnName"` the name of the column of the matching SSFF file. For more information on the columns the various functions of the `wrassp` produce, see the track fields of the `wrasspOutputInfos` object that is part of the `wrassp` package. Further, although the SSFF is a binary file format, it has a plain text header. This means that if you open a SSFF file in the text editor of your choice, you will be able to see the columns contained within it. Another way of accessing column information about a specific SSFF file is to use the `wrassp` function `res = read.AsspDataObj(/path/2/SSFF/file)` to read the file from the file system. `names(res)` will then give you the names of the columns present in this file. In the context of the SSFF, we use the term "column", while in the context of the EMU system we use either "track" or "SSFF track". Both refer to the same data.

    -   `"fileExtention"` the file extension of the matching SSFF file. See also `?wrasspOutputInfos` for the default extensions produced by the `wrassp` functions.

-   `"levelDefinitions"` array of definitions defining the levels of the database. Each `"levelDefinitions"` consists of:

    -   `"name"` The name of the `levelDefinition`.

    -   `"type"` Specifies the type of level (either `"ITEM"` | `"EVENT"` | `"SEGMENT"`).

    -   `"attributeDefinitions"` an array of definitions defining the
        attributes of the level. Each `attributeDefinition` consists of:

        -   `"name"` The name of the `"attributeDefinition"`.

        -   `"type"` Specifies the type of the attribute (currently only
            `"STRING"` permitted)

        -   `"labelGroups"` An (optional) array containing label group
            definitions. These can be used as a shorthand notation for
            querying certain groups of labels and comprise the
            following:

            -   `"name"` The name of the label group. This will be the
                value used in a query to refer to this group.

            -   `"values"` An array of strings representing the labels.

        -   `"legalLabels"` An (optional) array of strings specifying
            which labels are valid or legal for this attribute
            definition.

    -   `"anagestConfig"` If specified (optional), this will convert the
        level into a special type of level for labeling articulatory
        data. This will also serve as a marker for the EMU-webApp to
        treat this level differently. This optional field may only be
        set for levels of the type `"EVENT"`.

        -   `"verticalPosSsffTrackName"` The name of the
            SSFF
            track containing the vertical position data.

        -   `"velocitySsffTrackName"` The name of the
            SSFF
            track containing the velocity data.

        -   `"autoLinkLevelName"` The name of the level to which created
            events will be linked.

        -   `"multiplicationFactor"` The factor to multiply with (either
            `-1` `1`).

        -   `"threshold"` A value between 0 and 1 defining the absolute
            threshold.

        -   `"gestureOnOffsetLabels"` An array containing two strings
            that specify the on- and offset labels.

        -   `"maxVelocityOnOffsetLabels"` An array containing two
            strings that specify the on- and offset labels.

        -   `"constrictionPlateauBeginEndLabels"` An array containing
            two strings that specify the begin- and end labels.

        -   `"maxConstrictionLabel"` A string specifying the maximum
            constriction label.

-   `"linkDefinitions"` An array of the definitions defining the links
    between levels of the database. The combination of all link
    definitions specifies the hierarchy of the database. Each
    `linkDefinition` consists of:

    -   `"type"` Specifies the type of link (either `"ONE_TO_MANY"`
        `"MANY_TO_MANY"` `"ONE_TO_ONE"`).

    -   `"superlevelName"` Specifies the name of the super-level.

    -   `"sublevelName"` Specifies the name of the sub-level.

-   `"labelGroups"` An (optional) array containing label group
    definitions. These can be used as a shorthand notation for querying
    certain groups of labels. Compared to the `"labelGroups"`, which can
    be defined within an `attributeDefinition`, the `labelGroups`
    defined here are globally defined for the entire database as
    follows:

    -   `"name"` The name of the label group.

    -   `"values"` An array of strings containing labels.

-   `"EMUwebAppConfig"` Specifies the configuration options intended for
    the\
    `EMU-webApp` (i.e., how the database is to be displayed). This field
    can contain all the configurations options that are specified in the
    EMU-webApp's configuration schema (see
    <https://github.com/IPS-LMU/EMU-webApp/tree/master/dist/schemaFiles>).
    The `"EMUwebAppConfig"` contains the following fields:

    -   `"main"` Main behavior options:

        -   `"autoConnect"`: Auto connect to the `"serverUrl"` on the
            initial load of the webApp to automatically load a database
            (mainly used for development).

        -   `"serverUrl"`: The default server URL that is displayed in
            the connect modal window (and used if `"autoConnect"` is set
            to `true`). The default: `"ws://localhost:17890"` points to
            the server started by the `serve()` function of the `emuR`
            package.

        -   `"serverTimeoutInterval"`: The maximum amount of time the
            `EMU-webApp` waits (in milliseconds) for the server to
            respond.

        -   `"comMode"`: Specifies the communication mode the
            `EMU-webApp` is in. Currently the only option that is
            available is `"WS"` (websocket).

        -   `"catchMouseForKeyBinding"`: Check if mouse has to be in
            labeler for key bindings to work.

    -   `"keyMappings"` Keyboard shortcut definitions. For the sake of
        brevity, not every key-code is shown (see schema:
        <https://github.com/IPS-LMU/EMU-webApp/blob/master/dist/schemaFiles/emuwebappConfigSchema.json>
        for extensive list).

        -   `"toggleSideBarLeft"` integer value that represents the
            key-code that toggles the left side bar (== bundleList side
            bar)

        -   `"toggleSideBarRight"` integer value that represents the
            key-code that toggles the right side bar (== perspective
            side bar)

        -   ...

    -   `"spectrogramSettings"` Specifies the default settings of the
        spectrogram. The possible settings are:

        -   `"windowSizeInSecs"` Specifies the window size in seconds.

        -   `"rangeFrom"` Specifies the lowest frequency (in Hz) that
            will be displayed by the spectrogram.

        -   `"rangeTo"` Specifies the highest frequency (in Hz) that
            will be displayed by the spectrogram.

        -   `"dynamicRange"` Specifies the dynamic rang for maximum
            decibel dynamic range.

        -   `"window"` Specifies the window type (`"BARTLETT"`
            `"BARTLETTHANN"` `"BLACKMAN"` `"COSINE"` `"GAUSS"`
            `"HAMMING"` `"HANN"` `"LANCZOS"` `"RECTANGULAR"`
            `"TRIANGULAR"`).

        -   `"preEmphasisFilterFactor"` Specifies the preemphasis factor
            (in formula: s'(k) = s(k) - preEmphasisFilterFactor \*
            s(k-1) ).

        -   `"transparency"` Specifies the transparency of the
            spectrogram (integer from 0 to 255).

        -   `"drawHeatMapColors"` (optional) Defines whether the
            spectrogram should be drawn using heat-map colors (either
            true or false)

        -   `"heatMapColorAnchors"` (optional) Specifies the heat-map color anchors (array of the form `[[255, 0, 0], [0, 255, 0], [0, 0, 255]]`)

    -   `"perspectives"` An array containing perspective configurations.
        Each `"perspective"` consists of:

        -   `"name"` Name of the perspective.

        -   `"signalCanvases"` Configuration options for the
            `signalCanvases`.

            -   `"order"` An array specifying the order in which the
                [ssff]{acronym-label="ssff"
                acronym-form="singular+short"} tracks are to be
                displayed. Note that the [ssff]{acronym-label="ssff"
                acronym-form="singular+short"} track names "OSCI" and
                "SPEC" are always available in addition to the
                [ssff]{acronym-label="ssff"
                acronym-form="singular+short"} track defined in the
                database.

            -   `"assign"` An array of configuration options that assign
                one [ssff]{acronym-label="ssff"
                acronym-form="singular+short"} track to another,
                effectively creating a visual overlay of one track over
                another. Each array element consists of:

<!--                 -   `"signalCanvasName"` The name of the signal -->
<!--                     specified in the `"order"` array. -->

<!--                 -   `"ssffTrackName"` The name of the -->
<!--                     [ssff]{acronym-label="ssff" -->
<!--                     acronym-form="singular+short"} track to overlay onto -->
<!--                     `"signalCanvasName"`. -->

            -   `"minMaxValLims"` An array of configuration options to
                limit the y-axis range that is displayed for a specified
                SSFF track.

<!--                 -   `"ssffTrackName"`: A name specifying which ssffTrack -->
<!--                     should be limited. -->

<!--                 -   `"minVal"`: The minimum value which defines the -->
<!--                     lower y-axis limit. -->

            -   `"contourLims"` An array containing contour limit values
                that specify an index range that is to be displayed. As
                a track or column can contain multi-dimensional data
                (e.g. four formant values per time stamp, 256 DFT values
                per time stamp, etc.) it is possible to specify an index
                range that specifies which values should be displayed
                (e.g., display formant 2 through 4).

<!--                 -   `"ssffTrackName"` A name specifying which ssffTrack -->
<!--                     should be limited. -->

<!--                 -   `"minContourIdx"` The minimum contour index to -->
<!--                     display (starts at index 0). -->

<!--                 -   `"maxContourIdx"` The maximum contour index to -->
<!--                     display. -->

            -   `"contourColors"` An array to specify colors of
                individual contours. This overrides the default of
                automatically calculating distinct colors for each
                contour.

<!--                 -   `"ssffTrackName"` The name of the `ssffTrackName` -->
<!--                     for which colors are defined. -->

<!--                 -   `"colors"` An array of RGB strings (e.g. -->
<!--                     `["rgb(238,130,238)"`, `"rgb(127,255,212)"]`) that -->
<!--                     specify the color of the contour (first value = -->
<!--                     first contour color and so on). -->

        -   `"levelCanvases"` Configuration options for the
            `levelCanvases`:

<!--             -   `"order"` An array specifying the order in which the -->
<!--                 levels are to be displayed. Note that only levels of the -->
<!--                 type `EVENT` or `SEGMENT` can be displayed as -->
<!--                 `levelCanvases`. -->

        -   `"twoDimCanvases"` Configuration options for the 2D canvas.

            -   `"order"` An array specifying the order in which the
                levels are to be displayed. Note that currently only a
                single\
                `twoDimDrawingDefinition` can be displayed so this array
                can currently only contain a single element.

            -   `"twoDimDrawingDefinitions"` An array containing two
                dimensional drawing definitions. Each two dimensional
                drawing definition consists of:

<!--                 -   `"dots"` An array containing dot definitions. Each -->
<!--                     dot definition consist of: -->

<!--                     -   `"name"` The name of the dot. -->

<!--                     -   `"xSsffTrack"` The `ssffTrackName` of the track -->
<!--                         that contains the x axis values. -->

<!--                     -   `"xContourNr"` The contour number of the track -->
<!--                         that contains the x-axis values. -->

<!--                     -   `"ySsffTrack"` The `ssffTrackName` of the track -->
<!--                         that contains the y-axis values. -->

<!--                     -   `"yContourNr"` The contour number of the track -->
<!--                         that contains the y-axis values. -->

<!--                     -   `"color"` The RGB color string specifying the -->
<!--                         color given to dot. -->

<!--                 -   `"connectLines"` An array specifying which of the -->
<!--                     dots specified in the `"dots"` definition array -->
<!--                     should be connected by a line. -->

<!--                     -   `"fromDot"` The dot from which the line should -->
<!--                         start. -->

<!--                     -   `"toDot"` The dot at which the line should end. -->

<!--                     -   `"color"` The RGB string defining the color of -->
<!--                         the line. -->

<!--                 -   `"staticDots"` An array containing static dot -->
<!--                     definitions: -->

<!--                     -   `"name"` The name of the static dots. -->

<!--                     -   `"xNameCoordinate"` An x-coordinate specifying -->
<!--                         the location at which name should be drawn. -->

<!--                     -   `"yNameCoordinate"` y-coordinate specifying the -->
<!--                         location at which name should be drawn. -->

<!--                     -   `"xCoordinates"` An array of x-coordinates (e.g. -->
<!--                         `[300, 300, 900, 900, 300]`). -->

<!--                     -   `"yCoordinates"` An array of y-coordinates (e.g. -->
<!--                         `[880, 2540, 2540, 880, 880]`). -->

<!--                     -   `"connect"` A boolean value that specifies -->
<!--                         whether or not to connect the static dots with -->
<!--                         lines. -->

<!--                     -   `"color"` An RGB string specifying the color of -->
<!--                         static dots. -->

<!--                 -   `"staticContours"` An array containing static -->
<!--                     contour definitions: -->

<!--                     -   `"name"` The name of static contour. -->

<!--                     -   `"xSsffTrack"` The `ssffTrackName` of the track -->
<!--                         that contains the x-axis values. -->

<!--                     -   `"xContourNr"` The contour number of the track -->
<!--                         that contains the x-axis values. -->

<!--                     -   `"ySsffTrack"` The `ssffTrackName` of the track -->
<!--                         that contains the y-axis values. -->

<!--                     -   `"yContourNr"` The contour number of the track -->
<!--                         that contains the y-axis values. -->

<!--                     -   `"connect"` A boolean value that specifies -->
<!--                         whether or not to connect the static dots with -->
<!--                         lines. -->

<!--                     -   `"color"` An RGB string specifying color of the -->
<!--                         static contour. -->

    -   `"labelCanvasConfig"` Configuration options for the label
        canvases:

        -   `"addTimeMode"` The mode in which time to boundaries is
            added and subtracted (`"absolute"` or `"relative"`).

        -   `"addTimeValue"`: The amount of samples added to or
            subtracted from boundaries.

        -   `"newSegmentName"` The value given to the default label if a
            new SEGMENT is added (default is "" == empty string).

        -   `"newEventName"` The value given to the default label if a
            new EVENT is added (default is "" == empty string).

    -   `"restrictions"`:

        -   `"playback"` A boolean value specifying whether to allow
            audio playback.

        -   `"correctionTool"` A boolean value specifying whether
            correction tools are available.

        -   `"editItemSize"` A boolean value specifying whether to allow
            the size of a `SEGMENT` or `EVENT` to be changed (i.e., move
            boundaries).

        -   `"editItemName"` A boolean value specifying whether to allow
            the label of an `ITEM` to be changed.

        -   `"deleteItemBoundary"` A boolean value specifying whether to
            allow the deletion of boundaries.

        -   `"deleteItem"` A boolean value specifying whether to allow
            the deletion of entire `ITEM`s

        -   `"deleteLevel"` A boolean value specifying whether to allow
            the deletion of entire levels.

        -   `"addItem"` A boolean value specifying whether to allow new
            `ITEM`s to be added.

        -   `"drawCrossHairs"` A boolean value specifying whether to
            draw the cross hairs on signal canvases.

        -   `"drawSampleNrs"` A boolean value specifying whether to draw
            the sample numbers in the OSCI canvas if zoomed in close
            enough to see samples (mainly for debugging and development
            purposes).

        -   `"drawZeroLine"` A boolean value specifying whether to draw
            the zero value line in OSCI canvas.

        -   `"bundleComments"` A boolean value specifying whether to
            allow the annotator to add comments to bundles she or he has
            annotated. A bundle comment field will show up in the bundle
            list side bar for each bundle if this is set to true. Note
            that the server has to support saving these comments, which
            the `serve()` function of the `emuR` package does not.

        -   `"bundleFinishedEditing"` A boolean value specifying whether
            to allow the annotator to mark when she or he has finished
            annotating a bundle. A finished editing toggle button will
            show up in the bundle list side bar for each bundle if this
            is set to `true`. Note that the server has to support saving
            these comments which the `serve()` function of the `emuR`
            package does not.

        -   `"showPerspectivesSidebar"` A boolean value specifying
            whether to show the perspectives side bar.

    -   `"activeButtons"` Specifies which top- or bottom-menu buttons
        should be displayed by the `EMU-webApp`.

        -   `"addLevelSeg"` A boolean value specifying whether to show
            the `add SEGMENT level` button in the top menu bar.

        -   `"addLevelEvent"` A boolean value specifying whether to show
            the `add EVENT level button` in the top menu bar.

        -   `"renameSelLevel"` A boolean value specifying whether to
            allow the user to rename the currently selected level.

        -   `"downloadTextGrid"` A boolean value specifying whether to
            allow the user to download the current annotation as a
            `.TextGrid` file by displaying a `download TextGrid` button
            in the top menu bar.

        -   `"downloadAnnotation"` A boolean value specifying whether to
            allow the user to download the current annotation as an
            `_annot.json` file by displaying a `download annotJSON`
            button in the top menu bar.

        -   `"specSettings"` A boolean value specifying whether to
            display the `spec. settings` button in the top menu bar.

        -   `"connect"` A boolean value specifying whether to display
            the `connect` button in the top menu bar.

        -   `"clear"` A boolean value specifying whether to display the
            `clear` button in the top menu bar.

        -   `"deleteSingleLevel"` A boolean value specifying whether to
            allow the user to delete a level containing time
            information.

        -   `"resizeSingleLevel"` A boolean value specifying whether to
            allow the user to resize a level.

        -   `"saveSingleLevel"` A boolean value specifying whether to
            allow the user to download a single level in the ESPS/waves+
            format.

        -   `"resizeSignalCanvas"` A boolean value specifying whether to
            allow the user to resize the `signalCanvases` (`"OSCI"`,
            `"SPEC"`, ...).

        -   `"openDemoDB"` A boolean value specifying whether to show
            the `open demoDB` button.

        -   `"saveBundle"` A boolean value specifying whether to show
            the save button in bundle list side bar for each bundle.

        -   `"openMenu"` A boolean value specifying whether open bundle
            list side bar button is displayed.

        -   `"showHierarchy"` A boolean value specifying whether to
            display the `show hierarchy` button.

-   `"demoDBs"` An array of strings specifying which demoDBs to display
    in the `open demo` drop-down menu. Currently available demo
    databases are `["ae", "ema", "epgdorsal"]`.

### `_annot.json` {#subsec:app_chapFileFormatsAnnotJSON}

The `_annot.json` files contain the actual annotation information as
well as the hierarchical linking information. Legacy EMU users should
note that all the information that used to be split into several
ESPS/waves+ label files and a `.hlb` file is now contained in this
single file.

The `_annot.json` file contains the following fields:

-   `"name"` Specifies the name of the annotation file (has to be equal
    to the bundle directory prefix as well as the `_annot.json` prefix).

-   `"annotates"` Specifies the (relative) media file path that this
    `_annot.json` file annotates.

-   `"sampleRate"` Specifies the sample rate of the annotation (should
    be the same as the sample rate of the file listed in `"annotates"`).

-   `"levels"` Contains an array of level annotation informations. Each
    element consists of:

    -   `"name"` Specifies the name of the level.

    -   `"items"` An array containing the annotation items of the level.

        -   `"id"` The unique ID of the item (only unique within an
            `_annot.json` file or bundle, not globally for the `emuDB`).

        -   `"sampleStart"` Contains start sample value of `SEGMENT`
            item.

        -   `"sampleDur"` Contains sample duration value of `SEGMENT`
            item. Note that the `EMU-webApp` does not support
            overlapping `SEGMENT`s or `SEGMENT` sequences containing
            gaps. This infers that each sample is explicitly and
            unambiguously associated with a single `SEGMENT`. This means
            that the `sampleStart` value of a following `SEGMENT` has to
            be `sampleStart` + `sampleDur` + 1 of the previous
            `SEGMENT`. When converting the sample values to time values,
            the `start` time value is calculated with the formula
            $start = \frac{sampleStart}{sampleRate} - \frac{0.5}{sampleRate}$
            and the `end` time value with the formula
            $end = \frac{sampleStart + sampleDur}{sampleRate} + \frac{0.5}{ sampleRate}$.
            This is done to have gapless time values for successive
            `SEGMENT`s. To avoid a negative time value when dealing with
            the first sample of an audio file (`sampleStart` value of
            $0$), the `start` time value is simply set to $0$ in this
            case. The `start` and `end` time value calculation is
            performed by both the query engine of `emuR` if the
            `calcTimes` parameter is set to `TRUE` and the `EMU-webApp`
            to display the time information in the signal canvases.

        -   `"samplePoint"` Contains sample point values of `EVENT`
            items. When calculating the `start` time values for `EVENT`s
            the following formula is used:
            $start = \frac{samplePoint}{sampleRate}$

        -   `"labels"` An array containing labels that belong to this
            item. Each element consists of:

            -   `"name"` Specifies the `attributeDefinition` that this
                label is for.

            -   `"value"` Specifies the label value.

-   `"links"` An array containing links between two items. These links have to adhere to the links specified in `linkDefinitions` of the corresponding `emuDB`. Each link consists of:

    -   `"fromID"` The ID value of the item to link from (i.e., item in super-level).

    -   `"toID"` The ID value of item to link to (i.e., item in sub-level).

### The SSFF file format {#subsec:app_chapFileFormatsSSFF}

The SSFF file format is a binary file format which has a plain text header. This means that the header is human-readable and can be viewed with any text editor including common UNIX command line tools such as `less` or `cat`. Within R it is possible to view the header by using R's `readLines()` function as displayed in R Example \@ref(rexample:wrassp-readSSFF).


```r
# load the emuR and wrassp packages
library(emuR, warn.conflicts = FALSE)
library(wrassp)

# create demo data in directory 
# provided by tempdir()
create_emuRdemoData(dir = tempdir())

# create path to demo database
path2ae = file.path(tempdir(), "emuR_demoData", "ae_emuDB")

# create path to bundle in database
path2bndl = file.path(path2ae, "0000_ses", "msajc003_bndl")

# create path to .fms file 
path2fmsFile = file.path(path2bndl, 
                        paste0("msajc003.", 
                               wrasspOutputInfos$forest$ext))

# read in first 8 lines of .fms file.
# Note that the header length may vary in other SSFF files.
readLines(path2fmsFile, n = 8)
```

```
## [1] "SSFF -- (c) SHLRC"            "Machine IBM-PC"              
## [3] "Record_Freq 200.0"            "Start_Time 0.0025"           
## [5] "Column fm SHORT 4"            "Column bw SHORT 4"           
## [7] "Original_Freq DOUBLE 20000.0" "-----------------"
```


The general line item structure of the plain text head of an SSFF file can be described as follows:

-   `SSFF – (c) SHLRC` (required line): File type marker.

-   `Machine IBM-PC` (required line): System architecture of the machine that generated the file. This is mainly used to specify the endianness of the data block (see below). `Machine IBM-PC` indicates little-endian and `Machine SPARC` indicates big-endian. To date, we have not encountered other machine types.

-   `Record_Freq SR` (required line): Sample rate of current file in Hz. If, for example, `SR` is 200.0 (see R Example \@ref(rexample:wrassp-readSSFF)) then the sample rate is 200 Hz.

-   `Start_Time ST` (required line): Time of first sample block in data block in seconds. This often deviates from 0.0 as `wrassp`'s windowed signal processing functions start with the first window centered around `windowShift` / 2. If the `windowShift` parameter's default value is 5 ms, the start time `ST` of the first sample block will be 0.0025 sec (see R Example \@ref(rexample:wrassp-readSSFF)).

-   `Column CN CDT CDL` (required line(s)): A `Column` line entry contains four space-separated values, where `Column` is the initial key word value. The second value, `CN` (`fm` in R Example \@ref(rexample:wrassp-readSSFF)), specifies the name for the column; the third, `CDT` (`SHORT` in R Example \@ref(rexample:wrassp-readSSFF)), indicates the column's data type; and the fourth, `CDL` (`4` in R Example \@ref(rexample:wrassp-readSSFF)), is the column's data length in bytes. As can be seen in R Example \@ref(rexample:wrassp-readSSFF), it is quite common for SSFF files to have multiple column entries. The sequence of these entries is relevant, as it specifies the sequence of the data in the binary data block (see below).

-   `NAME DT DV` (optional line(s)): Optional single value definitions that have a `NAME`, a data type `DT` and a data value `DV` (see `Original_Freq DOUBLE 20000.0` in R Example \@ref(rexample:wrassp-readSSFF) specifying the original sample rate of the audio file the `.fms` file was generated from).

-   `Comment CHAR string of variable length` (optional line(s)): The `Comment CHAR` allows for comment strings to be added to the header.

-   `—————–` (required line): marks the end of the plain text header.

The binary data block of the SSFF file format stores its data in a so-called interleaved fashion. This means it does not store the binary data belonging to every column in a separate data block. Rather, it interleaves the columns to form sample blocks that occur at the same point in time. Figure \@ref(fig:wrassp-ssffDataBlock) displays a sequence of short integer values where the subscript text indicates the index in the sequence. This sequence represents a schematic representation of the data block of the `.fms` file of R Example \@ref(fig:wrassp-ssffDataBlock). The first four [`INT16`~`1-4`~]{style="color: three_color_c1"} (green) blocks represent the first four `INT16` formant values that belong to the `fm` column and the next four [`INT16`~`5-8`~]{style="color: three_color_c2"} (orange) represent the first four bandwidth values belonging to the `bm` column. Therefore, the dashed square marks the first sample block (i.e., the first eight F1, F2, F3 and F4; and F1~bandwidth~, F2~bandwidth~, F3~bandwidth~ and F4~bandwidth~ values) that occur at the time specified by the `Start_Time 0.0025` header entry. The time of all subsequent sample blocks of eight `INT16` values (e.g., `INT16`~`9-16`~) can be calculated as follows:
`0.0025 (== Start_Time) + 1 / 200.0 (== Record_Freq) * sample block index`.

<div class="figure" style="text-align: center">
<img src="pics/ssffDataBlock.png" alt="Schematic representation of the data block of the `msajc003.fms` file of R Example ref{rexample:wrassp-readSSFF}." width="100%" />
<p class="caption">(\#fig:wrassp-ssffDataBlock)Schematic representation of the data block of the `msajc003.fms` file of R Example ref{rexample:wrassp-readSSFF}.</p>
</div>

## Example files

### `_bundleList.json` {#subsec:app-chapExampleFilesBundleList}

Compared to the `_DBconfig.json` and `_annot.json` files, the `_bndl.json` format is not part of the `emuDB` database specification. Rather, it is part of the `EMU-webApp-websocket-protocol` and is used as a standardized format to transport information about all the available bundles to the `EMU-webApp`. It is not meant as an on-disk file format but rather should be generated on-demand by the server implementing the `EMU-webApp-websocket-protocol`. A schematic example of a `_bndl.json` file is displayed in Listing \@ref(lst:bndlListJSON).

<!-- caption="Schematic example of a \_bundleList.json file" language="json" label="lst:bndlListJSON" startFrom="1" -->

```json
[
  {
  "name": "msajc003",
  "session": "0000",
  "finishedEditing": false,
  "comment": "",
  "timeAnchors": [
    {
      "sample_start": 1000,
      "sample_end": 2000
    }, ...
  ]
  },
  {
  "name": "msajc010",
  "session": "0000",
  "finishedEditing": false,
  "comment": ""
  }
]
```

### `_bndl.json` {#subsec:app_chapExampleFilesBndlJSON}

Compared to the `_DBconfig.json` and `_annot.json` files, the `_bndl.json` format is not part of the `emuDB` database specification. Rather, it is part of the `EMU-webApp-websocket-protocol` and is used as a standardized format to transport all the data belonging to a single bundle to the `EMU-webApp`. It is not meant as an on-disk file format by rather should generated on-demand by the server implementing the `EMU-webApp-websocket-protocol`. A schematic example of a `_bndl.json` file is displayed in Listing \@ref(lst:bndlJSON).

<!-- lst:bndlJSON caption="Schematic example of a _bndl.json file" language="json" startFrom="1" -->

```json
{
 "ssffFiles": [
  {
   "fileExtension": "fms",
   "encoding": "BASE64",
   "data": "U1N..."
  }
 ],
 "mediaFile": {
  "encoding": "BASE64",
  "data": "Ukl..."
 },
 "annotation": contentOfAnnot.json
}
```

`contentOfAnnot.json` in Listing \@ref(lst:bndlJSON) refers to the content of a `_annot.json` file.


