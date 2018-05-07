# Installing the EMU-SDMS

1. `R`
  - Download the R programming language from  [http://www.cran.r-project.org](www.cran.r-project.org)
  - Install the R programming language by executing the downloaded file and following the on-screen instructions.

2. `emuR`
  - Start up `R`.
  - Enter `install.packages("emuR")` after the `>` prompt to install the package. (You will only need to repeat this if package updates become available.)
  - As the `wrassp` package is a dependency of the `emuR` package, it does not have to be installed separately.

3. `EMU-webApp` (prerequisite)
  - The only thing needed to use the `EMU-webApp` is a current HTML5 compatible browser (Chrome/Firefox/Safari/Opera/...). However, as most of the development and testing is done using Chrome we recommend using it, as it is by far the best tested browser.




## Installing additional R-packages that are used throughout this document

- `ggplot2` for visualization purposes: `install.packages("ggplot2")`
- `dplyr` for data manipulation: `install.packages("dplyr")`

## Version disclaimer

This document describes the following versions of the software components:

- `wrassp`
    * Package version: 0.1.6
    * Git SHA1: `jsonlite::fromJSON("https://api.github.com/repos/IPS-LMU/wrassp/branches/master")$commit$sha`
    <!-- to avoid api calls the above line is not executed (== missin r prefix in code snippet) -->
- `emuR`
    * Package version: `packageVersion("emuR")`
    * Git SHA1: `jsonlite::fromJSON("https://api.github.com/repos/IPS-LMU/emuR/branches/master")$commit$sha`
    <!-- to avoid api calls the above line is not executed (== missin r prefix in code snippet) -->
- `EMU-webApp`
    * Version: `jsonlite::fromJSON("https://raw.githubusercontent.com/IPS-LMU/EMU-webApp/master/package.json")$version`
    * Git SHA1: `jsonlite::fromJSON("https://api.github.com/repos/IPS-LMU/EMU-webapp/branches/master")$commit$sha`
    <!-- to avoid api calls the above lines is not executed (== missin r prefix in code snippet) -->

As the development of the EMU Speech Database Management System is still ongoing, be sure you have the correct documentation to go with the version you are using.

## For developers and people interested in the source code

The information on how to install and/or access the source code of the developer version including the possibility of accessing the versions described in this document (via the Git SHA1 hashes mentioned above) is given below.

- `wrassp`
    * Source code is available here: [https://github.com/IPS-LMU/wrassp/](https://github.com/IPS-LMU/wrassp/)
    * Install developer version in R: `install.packages("devtools"); library("devtools"); install_github("IPS-LMU/wrassp")`
    * Bug reports: [https://github.com/IPS-LMU/wrassp/issues](https://github.com/IPS-LMU/wrassp/issues)

- `emuR`
    * Source code is available here: [https://github.com/IPS-LMU/emuR/](https://github.com/IPS-LMU/emuR/)
    * Install developer version in R: `install.packages("devtools"); library("devtools"); install_github("IPS-LMU/emuR")`
    * Bug reports: [https://github.com/IPS-LMU/emuR/issues](https://github.com/IPS-LMU/emuR/issues)

- `EMU-webApp`
    * Source code is available here: [https://github.com/IPS-LMU/EMU-webApp/](https://github.com/IPS-LMU/EMU-webApp/)
    * Bug reports: [https://github.com/IPS-LMU/EMU-webApp/issues](https://github.com/IPS-LMU/EMU-webApp/issues)

