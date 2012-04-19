// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import QtWebKit 1.0
import "javascripts/latitude_data_manager.js" as LatitudDataManager
import ICS 1.0
//import com.nokia.symbian 1.1
import com.nokia.meego 1.0


Page {
//    width: 360
//    height: 360
    id: pageLocation

    property bool bFirst: true;
    property variant currentLocation;
    property variant locationHistory;
    property variant addressLocationsList;
    property variant propertyLat;
    property variant propertyLng;
    property variant propertyMs;
    property variant locationInserted;
    property int deletedIndex: -1;

    function beginWebView() {
        webView.html = settingsManager.htmlString;
    }

    function runBusyIndicator(b)
    {
        busy_indicator.visible = b;
        busy_indicator.running = b;
    }

    function gotoLocation(lat,lng)
    {
        console.log("LocationPage. gotoLocation(): latitude="+lat+", longitude="+lng+", propertyLat="+propertyLat+", propertyLng="+propertyLng);
        if ((typeof(lat) === 'undefined') || (lat === null) || (typeof(lng) === 'undefined') || (lng === null)) {
            if ((typeof(propertyLat) === 'undefined') || (propertyLat === null) || (typeof(propertyLng) === 'undefined') || (propertyLng === null)) {
                lat = settingsManager.lat;
                lng = settingsManager.lng;
            } else {
                lat = propertyLat;
                lng = propertyLng;
            }
        }
        settingsManager.lat = lat;
        settingsManager.lng = lng;
        propertyLat = lat;
        propertyLng = lng;

        console.log("LocationPage. gotoLocation() to webView: latitude="+lat+", longitude="+lng+", propertyLat="+propertyLat+", propertyLng="+propertyLng);
        webView.evaluateJavaScript(
                    "gotoLocation("+lat+", "+lng+");"
                    );
    }

    function insertCurrentLocation(lat,lng)
    {
        console.log("LocationPage. insertCurrentLocation(): lat="+lat+", lng="+lng);
        LatitudDataManager.insertCurrentLocation(lat,lng);
    }
    function insertHistoryLocation(lat, lng, ms)
    {
        console.log("LocationPage. insertHistoryLocation(): lat="+lat+", lng="+lng+", ms="+ms);
        LatitudDataManager.insertHistoryLocation(lat, lng, ms)
    }

    function deleteLocationRequest(ms)
    {
        console.log("LocationPage. deleteLocation(): ms="+ms);
        settingsManager.deleteLocation(ms);
    }
    function deleteLocationFromList(index)
    {
        console.log("LocationPage. deleteLocationFromList(): index="+index);
        historyLocationModel.remove(index);
    }

    onLocationInsertedChanged: {
        if (typeof(locationInserted) === 'number') {
            console.log("Error occur, status=" + locationInserted);
            queryDialog.titleText = "Error occur, status " + locationInserted;
            queryDialog.message = "Can't insert New Location. Wrong status returned.\nAre you opted in Latitude data sharing?"
            queryDialog.open();
            locationInserted = undefined;
        } else if (locationInserted) {
            console.log("LocationPage.qml: onLocationInsertedChanged...")
            historyLocationModel.insert(0,{"timeLocation":propertyMs,"latitude":propertyLat,"longitude":propertyLng})
            locationInserted = false;
        }
    }

    onCurrentLocationChanged: {
        console.log("LocationPage.qml: onCurrentLocationChanged... typeof(currentLocation) is " + typeof(currentLocation));
        if (typeof(currentLocation) === 'number') {
            console.log("Error occur, status=" + currentLocation);
            queryDialog.titleText = "Error occur, status " + currentLocation;
            queryDialog.message = "Can't get Current Location. Wrong status returned.\nAre you opted in Latitude data sharing?"
            queryDialog.open();
        }

        gotoLocation();
        runBusyIndicator(false);
    }

    onLocationHistoryChanged: {
        var lst = [];
        if (typeof(locationHistory) === 'number') {
            console.log("Error occur, status=" + locationHistory);
            queryDialog.titleText = "Error occur, status " + locationHistory;
            queryDialog.message = "Can't get Location History. Wrong status returned.\nAre you opted in Latitude data sharing?"
            queryDialog.open();
        } else if (typeof(locationHistory) !== 'undefined') {
            historyLocationModel.clear()
            for (var i=0; i<locationHistory.length; i++) {
                historyLocationModel.append({"timeLocation":locationHistory[i]["timestampMs"],"latitude":locationHistory[i]["latitude"],"longitude":locationHistory[i]["longitude"]});
            }
        }
    }

    BorderImage {
        id: rUp
        source: "images/toolbar-top.png"
        height: 100
        width: parent.width
        anchors.top: parent.top
        visible: true

        Button {
            id: buttonMap
            text: "Map";
            width: 120; height: 40
            anchors { top: parent.top; right: parent.right; topMargin: 5 }
            onClicked: {
                console.log("Map clicked")
                selectionDialog.selectedIndex = -1;
                selectionDialog.open();
            } //onClicked: {
        } //buttonMap

        Button {
            id: buttonGo
            text: "Go";
            width: 120; height: 40
            anchors { top: parent.top; right: buttonMap.left; topMargin: 5 }
            onClicked: {
                console.log("Go clicked, location=", lineEdit.text)
                if (lineEdit.text !== "") {
                    LatitudDataManager.gotoAddress(lineEdit.text,settingsManager.keyGeocoding)
                }
            } //onClicked: {
        } //buttonGo

        TextField {
            id: lineEdit
            height: 40;
            anchors { top: parent.top; right: buttonGo.left; left: parent.left; topMargin: 5 }
            text: ""
        } //lineEdit

        Button {
            id: buttonQuit
            text: "Quit"
            anchors { bottom: parent.bottom; left: parent.left; bottomMargin: 5 }
            height: 40
            width: 120
            onClicked: {
                Qt.quit();
            }
        }
        Button {
            id: buttonCurrentLocation
            text: "Home"
            height: 40
            width: 120
            anchors { bottom: parent.bottom; left: buttonQuit.right; bottomMargin: 5 }
            onClicked: {
                if (typeof(currentLocation) === 'number') {
                    queryDialog.titleText = "Error occur, status " + currentLocation;
                    queryDialog.message = "No valid Current Location present.\nAre you opted in Latitude data sharing?"
                    queryDialog.open();
                } else {
                    gotoLocation(currentLocation["latitude"],currentLocation["longitude"]);
                }

            }
        }
        Button {
            id: buttonInsertLocation
            text: "Insert"
            height: 40
            width: 120
            anchors { bottom: parent.bottom; right: buttonLocationHistory.left; bottomMargin: 5}
            onClicked: {
                console.log("Insert clicked")
                propertyMs = settingsManager.getCurrentTimeMs();
                LatitudDataManager.insertHistoryLocation(propertyLat, propertyLng, propertyMs);
            }
        }
        Button {
            id: buttonLocationHistory
            text: "History"
            height: 40
            width: 120
            anchors { bottom: parent.bottom; right: parent.right; bottomMargin: 5 }
            onClicked: {
                console.log("Go to HistoryPage.qml...");
//                root.state = "stateHistory";
//                stack.replace(pageLocationHistory);
                stack.push(pageLocationHistory);
            }
        }
    } //rUp
    WebView {
        id: webView
        objectName: "webView"
        anchors { top: rUp.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }

        javaScriptWindowObjects:
            QtObject {
            id: windowObject
            WebView.windowObjectName: "qml"
            property bool isInited: false
            property int zoom: settingsManager.zoom;
            property variant mapTypeId: settingsManager.mapTypeId;
            property double lat: settingsManager.lat
            property double lng: settingsManager.lng

            onIsInitedChanged: {
                console.log("WebView, onIsInitedChanged()...");
                LatitudDataManager.getCurrentLocation();
                LatitudDataManager.getHistoryLocation();
            }
            onZoomChanged: {
                settingsManager.zoom = zoom;
            }
            onMapTypeIdChanged: {
                console.log("MapTypeId changed. type="+mapTypeId);
                settingsManager.mapTypeId = mapTypeId;
            }
        }
    } //webView

    Component.onCompleted: {
        console.log("onCompleted!!, mapTypeId="+settingsManager.mapTypeId);

        if(settingsManager.refreshToken === "") {
            console.log("onCompleted. Begin Login procedure...")
            google_oauth.visible = true;
            google_oauth.login();
        } else {
            google_oauth.refreshAccessToken(settingsManager.refreshToken);
        }
        runBusyIndicator(true);
    } //Component.onCompleted: {

    ListModel {
        id: mapTypeModel
        ListElement { modelData: "RoadMap";      type: "google.maps.MapTypeId.ROADMAP"}
        ListElement { modelData: "Satellite";    type: "google.maps.MapTypeId.SATELLITE"}
        ListElement { modelData: "Hybrid";       type: "google.maps.MapTypeId.HYBRID"}
        ListElement { modelData: "Terrain";      type: "google.maps.MapTypeId.TERRAIN"}
    }

    QueryDialog {
        id: queryDialog
        acceptButtonText: "Ok"
    }

    SelectionDialog {
        id: selectionDialog
        titleText: "Select type of Map"
        selectedIndex: -1

        model: mapTypeModel

        onSelectedIndexChanged: {
            console.log("Selected index = ", selectedIndex);
            if(-1 < selectedIndex && selectedIndex < model.count)
                changeMapType(model.get(selectedIndex).type);
        }
    } //selectionDialog

    function changeMapType(type) {
        console.log("Changing map type to:", type);
        windowObject.mapTypeId = type;
        gotoLocation();
    }
}
