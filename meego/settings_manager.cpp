#include <QDebug>
#include <QSettings>
#include <QDateTime>
#include "settings_manager.h"

SettingsManager::SettingsManager(QObject *parent) :
    QObject(parent)
{
    m_apiKeyGeocoding = "YOUR_API_KEY_HERE";

    QSettings::setPath(QSettings::NativeFormat, QSettings::UserScope, "qml/google_api_latitude_qml");
    QSettings settings(QSettings::UserScope, "ICS", "Latitude Client");

    m_strAccessToken = settings.value("access_token", "").toString();
    m_strRefreshToken = settings.value("refresh_token", "").toString();

    m_strScope = "https://www.googleapis.com/auth/latitude.all.best"; //Access to Latitude service
    int num;
    num = settings.value("zoom", 8).toInt();
    if (!checkZoom(num)) {
        num = 8;
        setZoom(num);
    }
    m_nZoom = num;
    QString str = settings.value("mapTypeId", "google.maps.MapTypeId.TERRAIN").toString();
    if (!checkMapTypeId(str)) {
        str = "google.maps.MapTypeId.TERRAIN";
        setMapTypeId(str);
    }
    m_strMapTypeId = str;

    m_dLat = settings.value("lat", 55.75).toDouble();
    if (m_dLat == 0) {
        m_dLat = 55.75;
    }
    setLat(m_dLat);
    m_dLng = settings.value("lng", 37.6166667).toDouble();
    if (m_dLng == 0) {
        m_dLng = 37.6166667;
    }
    setLng(m_dLng);

    m_pNetworkAccessManager = new QNetworkAccessManager(this);
    connect(m_pNetworkAccessManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(replyFinished(QNetworkReply*)));
}

QVariant SettingsManager::accessToken() const
{
    return m_strAccessToken;
}

void SettingsManager::setAccessToken(const QVariant& token)
{
    m_strAccessToken = token.toString();
    QSettings settings(QSettings::UserScope, "ICS", "Latitude Client");
    settings.setValue("access_token", m_strAccessToken);
}

QVariant SettingsManager::refreshToken() const
{
    return m_strRefreshToken;
}

void SettingsManager::setRefreshToken(const QVariant& token)
{
    m_strRefreshToken = token.toString();
    QSettings settings(QSettings::UserScope, "ICS", "Latitude Client");
    settings.setValue("refresh_token", m_strRefreshToken);
}


QVariant SettingsManager::zoom() const
{
    return m_nZoom;
}
void SettingsManager::setZoom(const QVariant& z)
{
    qDebug() << "setZoom to " << z.toInt();
    m_nZoom = z.toInt();
    QSettings settings(QSettings::UserScope, "ICS", "Latitude Client");
    settings.setValue("zoom", m_nZoom);
}

QVariant SettingsManager::mapTypeId() const
{
    return m_strMapTypeId;
}

void SettingsManager::setMapTypeId(const QVariant& type)
{
    m_strMapTypeId = type.toString();
    QSettings settings(QSettings::UserScope, "ICS", "Latitude Client");
    settings.setValue("mapTypeId", m_strMapTypeId);
}

QString SettingsManager::ms2string(qlonglong ms) const {
    QDateTime dt;
    dt.setMSecsSinceEpoch(ms);
    return dt.toString("dd.MM.yy hh:mm:ss");
}

qlonglong SettingsManager::getCurrentTimeMs() const
{
    return QDateTime::currentMSecsSinceEpoch();
}

void SettingsManager::deleteLocation(qlonglong ms) const
{
    qDebug() << QDateTime::currentDateTime().toString("hh:mm:ss.zzz") <<  __FUNCTION__ << "ms=" << ms;

    QString query = QString("https://www.googleapis.com/latitude/v1/location/"+QString::number(ms)+
                            "?access_token=%1").arg(m_strAccessToken);
    m_pNetworkAccessManager->deleteResource(QNetworkRequest(QUrl(query)));
}

void SettingsManager::replyFinished(QNetworkReply *reply)
{
    qDebug() << QDateTime::currentDateTime().toString("hh:mm:ss.zzz") <<  __FUNCTION__ << reply->url();

    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    qDebug() << "Status Code" << statusCode;
    if (statusCode == 204) {
        if (reply->operation() == QNetworkAccessManager::DeleteOperation) {
            emit locationDeleted();
            return; //delete operation is OK
        }
    }
}

bool SettingsManager::checkZoom(int zoom)
{
    if ((zoom >= 0) && (zoom <= 21)) {
        return true;
    }
    return false;
}

bool SettingsManager::checkMapTypeId(QString type)
{
    qDebug() << "type=" << type << ", len=" << type.length();
    if (type == "google.maps.MapTypeId.ROADMAP") {
        return true;
    } else if (type == "google.maps.MapTypeId.SATELLITE") {
        return true;
    } else if (type == "google.maps.MapTypeId.TERRAIN") {
        return true;
    } else if (type == "google.maps.MapTypeId.HYBRID") {
        return true;
    }
    return false;
}
QVariant SettingsManager::lat() const
{
    return m_dLat;
}

void SettingsManager::setLat(const QVariant& lat)
{
    m_dLat = lat.toDouble();
    QSettings settings(QSettings::UserScope, "ICS", "Latitude Client");
    settings.setValue("lat", m_dLat);
    qDebug() << "setLat(): setValue=" << m_dLat;
}

QVariant SettingsManager::lng() const
{
    return m_dLng;
}

void SettingsManager::setLng(const QVariant& lng)
{
    m_dLng = lng.toDouble();
    QSettings settings(QSettings::UserScope, "ICS", "Latitude Client");
    settings.setValue("lng", m_dLng);
    qDebug() << "setLng(): setValue=" << m_dLng;
}


QVariant SettingsManager::htmlString() const
{
    QString str =
            "<html>"
            "<head>"
            "<script type=\"text/javascript\" src=\"http://maps.google.com/maps/api/js?v=3.3&sensor=true\"></script>"
            "<script>"
            "var myLatLng = null;"
            "var map = null;"
            "var myOptions = {"
            "    zoom: window.qml.zoom,"
            "    center: myLatLng,"
            "    mapTypeId: eval(window.qml.mapTypeId),"
            "    panControl: true,"
            "    zoomControl: true,"
            "    mapTypeControl: false,"
            "    mapTypeControlOptions: {"
            "       position: google.maps.ControlPosition.RIGHT_TOP"
            "    }"
            "};"
            "var marker = null;"
            "var contentString = '';"
            "var infowindow = null;"
            "function gotoLocation(lat, lng) {"
            "    myLatLng = new google.maps.LatLng(lat, lng);"
            "    myOptions.center = myLatLng;"
            "    myOptions.zoom = window.qml.zoom;"
            "    myOptions.mapTypeId = eval(window.qml.mapTypeId);"
            "    map = new google.maps.Map(document.getElementById(\"map_canvas\"), myOptions);"
            "    marker = new google.maps.Marker({"
            "        position: myLatLng,"
            "        map: map,"
            "        title:\"My current Location here\""
            "    });"
            "    contentString = '<div id=\"content\">Current Location</div>';"
            "    infowindow = new google.maps.InfoWindow({"
            "        content: contentString"
            "    }); "
            "    google.maps.event.addListener(marker, 'click', function() {"
            "        infowindow.open(map,marker);"
            "    });"
            "    google.maps.event.addListener(map, 'zoom_changed', function() {"
            "        window.qml.zoom = map.getZoom();"
            "    });"
            "    google.maps.event.addListener(map, 'maptypeid_changed', function() {"
            "        var type = map.getMapTypeId();"
            "        if (type == 'hybrid') {"
            "            window.qml.mapTypeId = 'google.maps.MapTypeId.HYBRID'"
            "        } else if (type == 'roadmap') {"
            "            window.qml.mapTypeId = 'google.maps.MapTypeId.ROADMAP'"
            "        } else if (type == 'satellite') {"
            "            window.qml.mapTypeId = 'google.maps.MapTypeId.SATELLITE'"
            "        } else if (type == 'terrain') {"
            "            window.qml.mapTypeId = 'google.maps.MapTypeId.TERRAIN'"
            "        }"
            "    });"
            "}"
            "function initialize() {"
            "    window.qml.isInited = true;"
            "}"
            "</script>"
            "</head>"
            "<body onload=\"initialize()\" leftmargin=\"0px\" topmargin=\"0px\" marginwidth=\"0px\" marginheight=\"0px\">"
            "    <div id=\"map_canvas\"  style=\"width: 100%; height: 100%\"/>"
            "</body>"
            "</html>";
    return str;
}

void SettingsManager::setHtmlString(const QVariant&)
{

}
