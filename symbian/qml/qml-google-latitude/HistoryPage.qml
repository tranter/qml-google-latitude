// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import com.nokia.symbian 1.1
//import com.nokia.meego 1.0


Page {
    id: pageLocationHistory
//    width: 360
//    height: 360

    BorderImage {
        id: pageHeader
        height: 60
        width: parent.width
        anchors {top: parent.top}
        source: "images/toolbar-top.png"

        Text {
            anchors {horizontalCenter: parent.horizontalCenter;verticalCenter: parent.verticalCenter}
            text: "Location History"
            font.bold: true
            font.pixelSize: 30
            color: "white"
        }
    } //pageHeader

    BorderImage {
        id: pageFooter
        height: 60
        width: parent.width
        anchors {bottom: parent.bottom}
        source: "images/toolbar-bottom.png"

        Button {
            id: buttonBack
            anchors {verticalCenter: parent.verticalCenter; left: parent.left}
            text: "Back"
            width: 120
            height: 40
            onClicked: {
                console.log("Go to LocationPage.qml...");
                stack.pop();
            }
        } //buttonBack
        Button {
            id: buttonPlus
            anchors {verticalCenter: parent.verticalCenter; right: buttonMinus.left}
            text: "Add"
            iconSource: "images/plus.png"
            width: 120
            height: 40
            onClicked: {
                console.log("Set as currentLocation...");
                var item = historyLocationModel.get(listView.currentIndex)
                appendCurrentLocation( item.latitude, item.longitude, item.timeLocation);
                root.state = "stateLocation";
            }
        } //buttonPlus
        Button {
            id: buttonMinus
            anchors {verticalCenter: parent.verticalCenter; right: parent.right}
            text: "Delete"
            iconSource: "images/minus.png"
            width: 150
            height: 40
            onClicked: {
                console.log("Delete location... latitude="+historyLocationModel.get(listView.currentIndex).timeLocation);
                deleteLocation(historyLocationModel.get(listView.currentIndex).timeLocation,listView.currentIndex);
            }
        } //buttonMinus
    } //pageFooter

    Component {
        id: historyDelegate
        Item {
            id: itemWrapper
            height: 80
            width: parent.width

            Rectangle {
                id: rectTime
                height: parent.height
                width: parent.width * 0.4
                anchors {left: parent.left}
                color:  index % 2 ? root.light_color : root.dark_color;
                clip: true
                TextEdit {
                    id: textTime
                    width: parent.width
                    font.bold: true
                    font.pixelSize: 30
                    color: "white"
                    anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
                    wrapMode: TextEdit.Wrap
                    text: settingsManager.ms2string(timeLocation)
                }
            } //rectTime
            Rectangle {
                id: rectLat
                height: parent.height
                width: parent.width * 0.3
                anchors {left: rectTime.right}
                clip: true
                color:  index % 2 ? root.light_color : root.dark_color;
                TextEdit {
                    id: textLat
                    width: parent.width
                    font.bold: true
                    font.pixelSize: 30
                    color: "white"
                    anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
                    wrapMode: TextEdit.Wrap
                    text: latitude
                }
            } //rectLat
            Rectangle {
                id: rectLng
                height: parent.height
                width: parent.width * 0.3
                anchors {left: rectLat.right}
                clip: true
                color:  index % 2 ? root.light_color : root.dark_color;
                TextEdit {
                    id: textLng
                    width: parent.width
                    font.bold: true
                    font.pixelSize: 30
                    color: "white"
                    anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
                    wrapMode: TextEdit.Wrap
                    text: longitude
                }
            } //rectLng
            MouseArea {
                id: maLocation
                anchors.fill: parent
                onClicked: {
                    listView.currentIndex = index;
                }
                onDoubleClicked: {
                    console.log("HistoryPage: onDoubleClicked... index="+index);
                    stack.pop();
                    pageLocation.gotoLocation(latitude,longitude);
                }
            } //maLocation
            states: State {
                name: "Current"
                when: itemWrapper.ListView.isCurrentItem
                PropertyChanges { target: rectTime; color: "lightblue" }
                PropertyChanges { target: textTime; color: "black" }
                PropertyChanges { target: rectLat; color: "lightblue" }
                PropertyChanges { target: textLat; color: "black" }
                PropertyChanges { target: rectLng; color: "lightblue" }
                PropertyChanges { target: textLng; color: "black" }
            }
        } //itemWrapper
    } //historyDelegate

    ListView {
        id: listView
        anchors { left:  parent.left; right: parent.right; bottom: pageFooter.top; top: pageHeader.bottom }
        model: historyLocationModel
        delegate: historyDelegate
        focus: true
        clip: true
    }

}
