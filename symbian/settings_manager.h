#ifndef SETTINGS_MANAGER_H
#define SETTINGS_MANAGER_H

#include <QObject>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QtDeclarative/qdeclarative.h>

class SettingsManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariant accessToken  READ accessToken  WRITE setAccessToken  NOTIFY accessTokenChanged)
    Q_PROPERTY(QVariant refreshToken READ refreshToken WRITE setRefreshToken NOTIFY refreshTokenChanged)
    Q_PROPERTY(QVariant keyGeocoding READ keyGeocoding)
    Q_PROPERTY(QVariant strScope READ strScope)

    Q_PROPERTY(QVariant zoom READ zoom WRITE setZoom NOTIFY zoomChanged)
    Q_PROPERTY(QVariant mapTypeId READ mapTypeId WRITE setMapTypeId NOTIFY mapTypeIdChanged)
    Q_PROPERTY(QVariant htmlString READ htmlString WRITE setHtmlString NOTIFY htmlStringChanged)
    Q_PROPERTY(QVariant lat READ lat WRITE setLat NOTIFY latChanged)
    Q_PROPERTY(QVariant lng READ lng WRITE setLng NOTIFY lngChanged)

public:
    explicit SettingsManager(QObject *parent = 0);

    QVariant accessToken() const;
    void setAccessToken(const QVariant& z);

    QVariant refreshToken() const;
    void setRefreshToken(const QVariant& z);

    QVariant keyGeocoding() const {return m_apiKeyGeocoding;}
    QVariant strScope() const {return m_strScope;}

    QVariant zoom() const;
    void setZoom(const QVariant& z);

    QVariant mapTypeId() const;
    void setMapTypeId(const QVariant& type);

    QVariant htmlString() const;
    void setHtmlString(const QVariant& id);

    QVariant lat() const;
    void setLat(const QVariant& id);

    QVariant lng() const;
    void setLng(const QVariant& id);

    Q_INVOKABLE QString ms2string(qlonglong ms) const;
    Q_INVOKABLE qlonglong getCurrentTimeMs() const;
    Q_INVOKABLE void deleteLocation(qlonglong ms) const;

Q_SIGNALS:
    void accessTokenChanged();
    void refreshTokenChanged();
    void zoomChanged();
    void mapTypeIdChanged();
    void htmlStringChanged();
    void latChanged();
    void lngChanged();
    void locationDeleted();

private slots:
    void replyFinished(QNetworkReply*);


private:
    QNetworkAccessManager* m_pNetworkAccessManager;

    QString m_strAccessToken;
    QString m_strRefreshToken;
    QString m_apiKeyGeocoding;
    QString m_strScope;
    int m_nZoom;
    QString m_strMapTypeId;
    double m_dLat;
    double m_dLng;

    bool checkZoom(int zoom);
    bool checkMapTypeId(QString type);

    QString m_organization;
    QString m_application;
};

QML_DECLARE_TYPE(SettingsManager)

#endif // SETTINGS_MANAGER_H
