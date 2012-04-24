import QtQuick 1.0
import QtWebKit 1.0
import "javascripts/google_oauth.js" as OAuth

//import com.nokia.symbian 1.1
import com.nokia.meego 1.0

Rectangle {
    id: google_oauth
    width:  400
    height: 400
    color: "#343434";
    property string oauth_link: "https://accounts.google.com/o/oauth2/auth?" +
                                "client_id=" + OAuth.client_id +
                                "&redirect_uri=" + OAuth.redirect_uri +
                                "&response_type=code" +
                                "&scope=https://www.googleapis.com/auth/latitude.all.best" +
                                "&access_type=offline" +
                                "&approval_prompt=force"
    property bool authorized: accessToken != ""
    property string accessToken: ""
    signal loginDone();

    onAccessTokenChanged: {
        console.log('onAccessTokenChanged');
        if(accessToken != '')
        {
            console.log("accessToken = ", accessToken)
            loginDone();
        }
    }


    function login()
    {
        loginView.url = oauth_link;
    }

    function refreshAccessToken(refresh_token)
    {
        OAuth.refreshAccessToken(refresh_token)
    }

    //Header!!!
    BorderImage {
        id: top_tool_bar
        anchors { left:  parent.left; right: parent.right; top: parent.top }
        //x: 0; y:0; width:360; height: mainWindow.tb_height
        height: 60
        source: "images/toolbar-top.png"
        Text {
            id: titleText
            text: "Login"
            anchors.centerIn:  parent
            color: "white"
            font.pixelSize: 25
            font.bold: true;
            wrapMode: Text.WordWrap
        }
//        MouseArea {
//            anchors { left: parent.left; top: parent.top; bottom: parent.bottom; right: closeButton.left }
//            onClicked: {
//                console.log("Header clicked");
//                textEditToHideKeyboard.closeSoftwareInputPanel();
//            }
//        }
        TextEdit{
            id: textEditToHideKeyboard
            visible: false
        }

        Button {
            id: closeButton
            text: "Close"
            width: 80
            height: 40
            anchors { right:  parent.right; verticalCenter: parent.verticalCenter }
            onClicked: {
                textEditToHideKeyboard.closeSoftwareInputPanel();
                google_oauth.visible = false;
            }
        }
        Button {
            id: hideKeyboardButton
            text: "Hide Keyboard"
            width: 200
            height: 40
            anchors { left:  parent.left; verticalCenter: parent.verticalCenter }
            onClicked: {
                textEditToHideKeyboard.closeSoftwareInputPanel();
            }
        }
    }


    Flickable {
        id: web_view_window

        property bool loading:  false;
        anchors { top: top_tool_bar.bottom; right: parent.right; left: parent.left; bottom: parent.bottom }

        contentWidth: Math.max(width,loginView.width)
        contentHeight: Math.max(height,loginView.height)
        clip: true

        WebView {
            id: loginView

            preferredWidth: web_view_window.width
            preferredHeight: web_view_window.height
            contentsScale: 2.0

            url: ""
            onUrlChanged: OAuth.urlChanged(url)

            onLoadFinished: {
                console.log("onLoadFinished");
                busy_indicator.running = false;
                busy_indicator.visible = false;
            }

            onLoadStarted: {
                console.log("onLoadStarted");
                busy_indicator.running = true;
                busy_indicator.visible = true;
            }

            BusyIndicator {
                id: busy_indicator;
                running: false
                width:  100;
                height: 100;
                anchors.centerIn:  parent;
                visible: false
            }

        }
    }


}
