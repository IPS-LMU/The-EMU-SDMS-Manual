# `EMU-webApp` implementation {#chap:emu-webAppImplementation}

Here, we briefly describe our strategy for implementing the `EMU-webApp`. The `EMU-webApp` is written entirely in HTML, Javascript and CSS. To ease testing and to enable easy integration and extendability we chose to use the AngularJS Javascript framework [@google:2014a]. Most of the components of the `EMU-webApp` (e.g., the spectrogram display) are implemented as so-called Angular directives. This means that, apart from dependencies on data service classes that have to be made available, these components are reusable and can be integrated into other web applications. The `EMU-webApp` makes extensive use of Angular data bindings to keep the display and the various data services in sync with each other. It is also worth noting that we chose to use the SASS (see http://sass-lang.com/) preprocessor to compile `.sass` files to CSS. This enabled us to use things like mixins, variables and inheritance for a more concise stylesheet management and generation.

The main reason we chose the JSON file format as the main file type for the EMU-SDMS is because we wanted a web application as the main GUI of the new system. Using JSON files enables the `EMU-webApp` to directly use the annotation and configuration files that are part of an `emuDB` without manipulating or reformatting the data.

The rest of this chapter will focus on the communication protocol and the URL parameters provided by the `EMU-webApp`. These should be of special interest to developers as they describe how to communicate with the web application and how to use the web application to display data that is hosted on other http web servers.

## Communication protocol[^1-subsec:emu-webAppTheProtocol] {#subsec:emu-webAppTheProtocol}

[^1-subsec:emu-webAppTheProtocol]: This section has been published in @winkelmann:2015d.

A large benefit gained by choosing the browser as the user interface is the ability to easily interact with a server using standard web protocols, such as http, https or websockets. In order to standardize the data exchange with a server, we have developed a simple request-response communication protocol on top of the websocket standard. This decision was strongly guided by the availability of the `httpuv` R package [@rstudio:2015a]. Our protocol defines a set of JSON objects for both the requests and responses. A subset of the request-response actions, most of them triggered by the client after connection, are displayed in Table \@ref(table:protocol-commands).

<!-- \begin{table}[ht!] -->
<!-- \centering -->
<!-- \small -->
<!-- \begin{tabularx}{\textwidth}{lX} -->
<!-- \hline -->
<!-- Protocol Command & Comments \\ -->
<!-- \hline -->
<!-- `GETPROTOCOL` & Check if the server implements the correct protocol \\ -->
<!-- `GETDOUSERMANAGEMENT` & See if the server handles user management (if yes, then this prompts a login dialog $\rightarrow$ `LOGONUSER`)\\ -->
<!-- `GETGLOBALDBCONFIG` & Request the configuration file for the current connection\\ -->
<!-- `GETBUNDLELIST` & Request the list of available bundles for current connection\\ -->
<!-- `GETBUNDLE` & Request data belonging to a specific bundle name \\ -->
<!-- `SAVEBUNDLE` & Save data belonging to a specific bundle name \\ -->
<!-- \end{tabularx} -->
<!-- \caption{Main `EMU-webApp` protocol commands.} -->
<!-- \label{table:protocol_commands} -->
<!-- \end{table} -->

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> Protocol_Command </th>
   <th style="text-align:left;"> Comments </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> `GETPROTOCOL` </td>
   <td style="text-align:left;"> Check if the server implements the correct protocol </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `GETDOUSERMANAGEMENT` </td>
   <td style="text-align:left;"> See if the server handles user management (if yes, then this prompts a login dialog $ightarrow$ `LOGONUSER` </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `GETGLOBALDBCONFIG` </td>
   <td style="text-align:left;"> Request the configuration file for the current connection </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `GETBUNDLELIST` </td>
   <td style="text-align:left;"> Request the list of available bundles for current connection </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `GETBUNDLE` </td>
   <td style="text-align:left;"> Request data belonging to a specific bundle name </td>
  </tr>
  <tr>
   <td style="text-align:left;"> `SAVEBUNDLE` </td>
   <td style="text-align:left;"> Save data belonging to a specific bundle name </td>
  </tr>
</tbody>
</table>

This protocol definition makes collaborative annotation efforts possible, as developers can easily implement servers for communicating with the `EMU-webApp`. Using this protocol allows a database to be hosted by a single server anywhere on the globe that then can be made available to a theoretically infinite number of users working on separate accounts logging individual annotations, time and date of changes and other activities such as comments added to problematic cases. Tasks can be allocated to and unlocked for each individual user by the project leader. As such, user management in collaborative projects is substantially simplified and trackable compared with other currently available software for annotation. 

The `emuR` package implements this websocket protocol as part of the `serve()` function utilizing the `httpuv` package. Further example implementations of this websocket protocol are provided as part of the source code repository of the `EMU-webApp` (see https://github.com/IPS-LMU/EMU-webApp/tree/master/exampleServers). A in-depth description of the protocol which includes descriptions of each request and response JSON object can be found in Appendix \@ref(app-chap:wsProtocol).

## URL parameters

The `EMU-webApp` currently implements several URL parameters (see https://en.wikipedia.org/wiki/Query_string for more information) as part of its URL query string. This section describes the currently implemented parameters and gives some accompanying examples.

### Websocket server parameters

The current URL parameters that affect the websocket server connection are:

- **serverUrl**=*URL* is a URL pointing to a websocket server that implements the EMU-webApp websocket protocol, and
- **autoConnect**=*true / false* automatically connects to a websocket server URL specified in the **serverUrl** parameter. If the **serverUrl** parameter is not set the web application defaults to the entry in its `default_emuwebappConfig.json`.

### Examples {#examples}

- auto connect to local wsServer: http://ips-lmu.github.io/EMU-webApp/?autoConnect=true&serverUrl=ws:%2F%2Flocalhost:17890

### Label file preview parameters {#label-file-preview-parameters}

The current URL parameters for using the `EMU-webApp` to visualize files that are hosted on other http servers are:

- **audioGetUrl**=*URL* GET URL that will respond with `.wav` file,
- **labelGetUrl**=*URL* GET URL that will respond with label/annotation file,
- **DBconfigGetURL**=*URL* GET URL that will respond with `_DBconfig.json` file, and
- **labelType**=*TEXTGRID / annotJSON* specifies the type of annotation file.


This mechanism is, for example, currently being used by the WebMAUS web-services of the BASWebServices (see https://clarin.phonetik.uni-muenchen.de/BASWebServices) to provide a preview of the automatically segmented speech files.

### Examples

- TextGrid example: http://ips-lmu.github.io/EMU-webApp/?audioGetUrl=https://raw.githubusercontent.com/IPS-LMU/EMU-webApp/master/app/testData/oldFormat/msajc003/msajc003.wav&labelGetUrl=https://raw.githubusercontent.com/IPS-LMU/EMU-webApp/master/app/testData/oldFormat/msajc003/msajc003.TextGrid&labelType=TEXTGRID
- annotJSON example: http://ips-lmu.github.io/EMU-webApp/?audioGetUrl=https://raw.githubusercontent.com/IPS-LMU/EMU-webApp/master/app/testData/newFormat/ae/0000_ses/msajc003_bndl/msajc003.wav&labelGetUrl=https://raw.githubusercontent.com/IPS-LMU/EMU-webApp/master/app/testData/newFormat/ae/0000_ses/msajc003_bndl/msajc003_annot.json&labelType=annotJSON
