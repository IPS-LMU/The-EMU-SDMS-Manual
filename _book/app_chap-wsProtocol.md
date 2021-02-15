# The `EMU-webApp-websocket-protocol` Version 2.0 [^1-app-chap:wsProtocol] {#app-chap:wsProtocol}

[^1-app-chap:wsProtocol]: This appendix chapter is an updated version of a similar description that is part of the `EMU-webApp` manual.

This chapter describes the `EMU-webApp-websocket-protocol` in its current version.

## Protocol overview

The `EMU-webApp-websocket-protocol` consists of a set of request-response JSON files that control the interaction between the client (the `EMU-webApp`) and a server supporting the protocol. A graph depicting the protocol is shown in the Figure \@ref(fig:app-chapWsProtocolGraph).


<div class="figure" style="text-align: center">
<img src="pics/protocol.png" alt="Schematic of the `EMU-webApp-websocket-protocol`." width="75%" />
<p class="caption">(\#fig:app-chapWsProtocolGraph)Schematic of the `EMU-webApp-websocket-protocol`.</p>
</div>

## Protocol commands

### `GETPROTOCOL` {#getprotocol}

Initial request to see if client and server speak the same protocol.

- Request (sent JSON file):


```javascript
{
  'type': 'GETPROTOCOL',
  'callbackID': 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
}
```

- Response (sent JSON file):



```javascript
{
  'callbackID': request.callbackID,
  'data': {
    'protocol': 'EMU-webApp-websocket-protocol',
    'version': '0.0.2'
  },
  'status': {
    'type': 'SUCCESS',
    'message': ''
  }
}
```

### `GETDOUSERMANAGEMENT`

Ask server if it wishes to perform user management (will toggle user login modal window if `data` is `YES`).

- Request (sent JSON file):


```javascript
{
  'type': 'GETDOUSERMANAGEMENT',
  'callbackID': 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
}
```

- Response (sent JSON file):



```javascript
{
  'callbackID': request.callbackID,
  'data': 'NO'
  'status': {
    'type': 'SUCCESS',
    'message': ''
  }
}
```

### `LOGONUSER`

Ask server to log user on. Username and password are sent to server (please only use `wss` to avoid password being sent in plain text!). This protocol command is sent by the user login modal window.

- Request (sent JSON file):


```javascript
{
  'type': 'LOGONUSER',
  'data': {
    'userName': 'smith',
    'pwd':'mySecretPwd'
  },
  'callbackID': 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
}
```

- Response (sent JSON file):


```javascript
{
  'callbackID': request.callbackID,
  'data': 'BADUSERNAME' | 'BADPASSWORD' | 'LOGGEDON'
  'status': {
    'type': 'SUCCESS',
    'message': ''
  }
}
```

### `GETGLOBALDBCONFIG`

Request the `_DBconfig.json` file.

- Request (sent JSON file):


```javascript
{
  'type': 'GETGLOBALDBCONFIG',
  'callbackID': 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
}
```

- Response (sent JSON file):


```javascript
{
  'callbackID': request.callbackID,
  'data': configData,
  'status': {
    'type': 'SUCCESS',
    'message': ''
  }
}
```

In the above Listing, `configData` represents the Javascript object that is the `_DBconfig.json` file of the respective database.

### `GETBUNDLELIST`

Next a `_bundleList.json` is requested containing the available bundles. The information contained in this file is what is displayed in the bundle list side bar. An example of a `_bundleList.json` file is shown in Appendix \@ref(subsec:app-chapExampleFilesBundleList).

- Request (sent JSON file):


```javascript
{
  'type': 'GETBUNDLELIST',
  'callbackID': 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
}
```

- Response (sent JSON file):


```javascript
{
  'callbackID': request.callbackID,
  'data': bundleList,
  'status': {
    'type': 'SUCCESS',
    'message': ''
  }
}
```

### `GETBUNDLE`

After receiving the `_bundleList.json` file by default, the first bundle in the file is requested in the form of a `_bndl.json` file. This request is also sent when the user clicks a bundle in the bundle list side bar of the `EMU-webApp`.

- Request (sent JSON file):


```javascript
{
  'type': 'GETBUNDLE',
  'name': 'msajc003',
  'session': '0000',
  'callbackID': 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
}
```

- Response (sent JSON file):


```javascript
{
  'callbackID': request.callbackID,
  'data': bundleData,
  'status': {
    'type': 'SUCCESS',
    'message': ''
  }
}
```

In the Listing above `bundleData` is the Javascript object containing all SSFF files (encoded as a base64 strings) and audio (encoded as a base64 string) and `_annot.json` that are associated with this bundle. An example of `_bndl.json` is given in Appendix \@ref(subsec:app-chapExampleFilesBndlJSON).

### `SAVEBUNDLE`

This function should be called if the user saves a loaded bundle (by pushing the save button in the bundle list side bar).

- Request (sent JSON file):


```javascript
{
  'type': 'SAVEBUNDLE',
  'data': bundleData,
  'callbackID': 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
}
```

In the Listing above `bundleData` is a Javascript object that corresponds to a `_bndl.json` file. As currently only annotations and formant tracks can be altered by the `EMU-webApp`, only the `_annot.json` and formant track SSFF file (if applicable) are sent to the server to be saved.

- Response (sent JSON file):


```javascript
{
  'callbackID': request.callbackID,
  'status': {
    'type': 'SUCCESS',
    'message': ''
  }
}
```

### `DISCONNECTWARNING`

Function that tells the server that it is about to disconnect. This is currently needed because the `httpuv` R package cannot listen to the websocket's own ``close'' event.

- Request (sent JSON file):


```javascript
{
  'type': 'DISCONNECTWARNING'
  'callbackID': 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
}
```

- Response (sent JSON file):


```javascript
{
  'callbackID': request.callbackID,
  'status': {
    'type': 'SUCCESS',
    'message': ''
  }
}
```

### Error handling

If an error occurs with any of the request types above, a response should still be sent to the client. The status of this response should be set to `ERROR` and an error message should be given in the message field. This message will then be displayed by the `EMU-webApp`.

- ERROR response:


```javascript
{
  'callbackID': request.callbackID,
  'status': {
    'type': 'ERROR',
    'message': 'An error occured trying to read a file from disk. Please make sure: /path/to/file exists or check the config...
  }
}
```

