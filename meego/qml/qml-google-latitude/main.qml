// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import ICS 1.0
//import com.nokia.symbian 1.1
import com.nokia.meego 1.0

Window {
    id: root

    anchors {
        fill: parent
    }

    property int deleteLocationIndex: -1

    onOrientationChangeAboutToStart: {
        console.log("orientationChangeAboutToStart");
    }

    GoogleOAuth {
        id: google_oauth
        visible: false
        anchors.fill: parent
        z: 10
        onLoginDone: {
            visible = false;
            console.log("LocationPage.qml: Login Done")
            settingsManager.accessToken = google_oauth.accessToken;
//            webView.url = "qrc:/html/google_maps.html"
//            webView.html = settingsManager.htmlString
            pageLocation.beginWebView();
        }

    } //GoogleOAuth {

    BusyIndicator {
        id: busy_indicator;
        running: false
        width:  100;
        height: 100;
        anchors.centerIn:  parent;
        visible: false
    } //BusyIndicator {

    PageStack {
        id: stack
        anchors.fill: parent
    }

    SettingsManager {
        id: settingsManager

        onLocationDeleted: {
            console.log("onLocationDeleted.!!!.#######..");
            pageLocation.deleteLocationFromList(deleteLocationIndex);
        }
    }

    ListModel {
        id: historyLocationModel
    }

    LocationPage {id: pageLocation}

    HistoryPage {id: pageLocationHistory}

    Component.onCompleted: {
        console.log("onCompleted")
        //stack.push(pageLocationHistory,{},true);
        stack.push(pageLocation,{},true);
    }

    property string light_color: "#272727"
    property string dark_color:  "#181818"

    function setLatLng(lat, lng)
    {
        pageLocation.gotoLocation(lat,lng);
    }

    function appendCurrentLocation(lat, lng)
    {
        pageLocation.insertHistoryLocation(lat,lng, settingsManager.getCurrentTimeMs());
        pageLocation.gotoLocation(lat,lng);
    }

    function deleteLocation(ms,index)
    {
        deleteLocationIndex = index;
        pageLocation.deleteLocationRequest(ms);
    }
}

