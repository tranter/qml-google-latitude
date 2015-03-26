# Introduction #

Information about use Google API, testing platforms, Qt versions.

# Details #

Project **qml-google-latitude** uses Google Maps API v3 and Google Latitude API. Project contains 2 subprojects - version for **meego** and version for **symbian**.

### Google API ###

Project **qml-google-latitude** uses Google Maps API v3 and Google Latitude API.

How it works:
WebView (in QML-file) contains html-page with **JavaScripts**. Work with Google-API perfomed by execute **JavaScripts**, which generated in run-time.

API features used in this project:
|Create and tuning map|
|:--------------------|
|Create placemarks (markers)|
|Get current location|
|Insert current location|
|Get history of location|
|Insert to history of location|
|Goto address|

File **[HowToRegisterYourAppIicationInGoogle](http://code.google.com/p/qml-google-latitude/wiki/HowToRegisterYourAppIicationInGoogle)** describes how register your own application on Google.

### Tested platforms ###
Both subproject were tested on:
| **OS** | **Qt version** |
|:-------|:---------------|
|Arch Linux 64bit in simulator|Qt 4.7.4 (QtSDK 1.2.1)|
|Windows 7 64bit/32bit in simulator|Qt 4.7.4 (QtSDK 1.2.1)|

**Symbian** subproject was tested on:
| **Phone** | **Qt version** |
|:----------|:---------------|
|---|---|

You can download package for symbian from [Downloads](http://code.google.com/p/qml-google-latitude/downloads/list) tab ([qml-google-latitude-symbian.sis](http://qml-google-latitude.googlecode.com/files/qml-google-latitude-symbian.sis)).

**MeeGo** subproject was tested on:
| **Phone** | **Qt version** |
|:----------|:---------------|
|---|---|


# Various comments #
1. **Caution!** In version for symbian maybe you need replace string "import com.nokia.symbian 1.0" to string "import com.nokia.symbian 1.1" (or backwards) in qml-files depending on version QtSDK.

2. You need to install Qt and qt-components on your phone.