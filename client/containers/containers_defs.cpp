#include "containers_defs.h"

#include "QJsonObject"
#include "QJsonDocument"

QDebug operator<<(QDebug debug, const amnezia::DockerContainer &c)
{
    QDebugStateSaver saver(debug);
    debug.nospace() << ContainerProps::containerToString(c);

    return debug;
}

amnezia::DockerContainer ContainerProps::containerFromString(const QString &container)
{
    QMetaEnum metaEnum = QMetaEnum::fromType<DockerContainer>();
    for (int i = 0; i < metaEnum.keyCount(); ++i) {
        DockerContainer c = static_cast<DockerContainer>(i);
        if (container == containerToString(c))
            return c;
    }
    // Unknown (e.g. removed protocol containers from old installs) — skip
    // silently apart from a log note, never crash.
    if (!container.isEmpty() && container != containerToString(DockerContainer::None)) {
        qWarning() << "ContainerProps::containerFromString: unknown container" << container << ", ignoring";
    }
    return DockerContainer::None;
}

QString ContainerProps::containerToString(amnezia::DockerContainer c)
{
    if (c == DockerContainer::None)
        return "none";
    if (c == DockerContainer::Awg)
        return "amnezia-awg";
    if (c == DockerContainer::Awg2)
        return "amnezia-awg2";
    QMetaEnum metaEnum = QMetaEnum::fromType<DockerContainer>();
    QString containerKey = metaEnum.valueToKey(static_cast<int>(c));

    return "amnezia-" + containerKey.toLower();
}

QString ContainerProps::containerTypeToString(amnezia::DockerContainer c)
{
    if (c == DockerContainer::None)
        return "none";
    if (c == DockerContainer::Awg)
        return "awg";
    if (c == DockerContainer::Awg2)
        return "awg";
    QMetaEnum metaEnum = QMetaEnum::fromType<DockerContainer>();
    QString containerKey = metaEnum.valueToKey(static_cast<int>(c));

    return containerKey.toLower();
}

QVector<amnezia::Proto> ContainerProps::protocolsForContainer(amnezia::DockerContainer container)
{
    switch (container) {
    case DockerContainer::None: return {};

    case DockerContainer::Xray: return { Proto::Xray };

    case DockerContainer::SSXray: return { Proto::SSXray };

    case DockerContainer::Dns: return { Proto::Dns };

    case DockerContainer::Sftp: return { Proto::Sftp };

    case DockerContainer::Socks5Proxy: return { Proto::Socks5Proxy };

    case DockerContainer::Awg: return { Proto::Awg };
    case DockerContainer::Awg2: return { Proto::Awg };
    default: return { defaultProtocol(container) };
    }
}

QList<DockerContainer> ContainerProps::allContainers()
{
    QMetaEnum metaEnum = QMetaEnum::fromType<DockerContainer>();
    QList<DockerContainer> all;
    for (int i = 0; i < metaEnum.keyCount(); ++i) {
        all.append(static_cast<DockerContainer>(i));
    }

    return all;
}

QMap<DockerContainer, QString> ContainerProps::containerHumanNames()
{
    return { { DockerContainer::None, "Not installed" },
             { DockerContainer::WireGuard, "WireGuard" },
             { DockerContainer::Awg, "AmneziaWG" },
             { DockerContainer::Awg2, "AmneziaWG" },
             { DockerContainer::Xray, "XRay" },
             { DockerContainer::SSXray, "Shadowsocks"},

             { DockerContainer::TorWebSite, QObject::tr("Website in Tor network") },
             { DockerContainer::Dns, QObject::tr("DopamineDNS") },
             { DockerContainer::Sftp, QObject::tr("SFTP file sharing service") },
             { DockerContainer::Socks5Proxy, QObject::tr("SOCKS5 proxy server") } };
}

QMap<DockerContainer, QString> ContainerProps::containerDescriptions()
{
    return { { DockerContainer::WireGuard,
               QObject::tr("WireGuard - popular VPN protocol with high performance, high speed and low power "
                           "consumption.") },
             { DockerContainer::Awg,
               QObject::tr("AmneziaWG is a special protocol based on WireGuard. "
                           "It provides high connection speed and ensures stable operation even in the most challenging network conditions.") },
             { DockerContainer::Awg2,
               QObject::tr("AmneziaWG is a special protocol based on WireGuard. "
                           "It provides high connection speed and ensures stable operation even in the most challenging network conditions.") },
             { DockerContainer::Xray,
               QObject::tr("XRay with REALITY masks VPN traffic as web traffic and protects against active probing. "
                           "It is highly resistant to detection and offers high speed.") },

             { DockerContainer::TorWebSite, QObject::tr("Deploy a WordPress site on the Tor network in two clicks.") },
             { DockerContainer::Dns,
               QObject::tr("Replace the current DNS server with your own. This will increase your privacy level.") },
             { DockerContainer::Sftp,
               QObject::tr("Create a file vault on your server to securely store and transfer files.") },
             { DockerContainer::Socks5Proxy,
               QObject::tr("") } };
}

QMap<DockerContainer, QString> ContainerProps::containerDetailedDescriptions()
{
    return {
        { DockerContainer::WireGuard,
          QObject::tr("WireGuard is a modern, streamlined VPN protocol offering stable connectivity and excellent performance across all devices. "
                      "It uses fixed encryption settings, delivering lower latency and higher data transfer speeds compared to older VPN protocols. "
                      "However, WireGuard is easily identifiable by DPI systems due to its distinctive packet signatures, making it susceptible to blocking.\n"
                      "\nFeatures:\n"
                      "* Available on all Dopamine platforms\n"
                      "* Low power consumption on mobile devices\n"
                      "* Minimal configuration required\n"
                      "* Easily detected by DPI systems (susceptible to blocking)\n"
                      "* Operates over UDP protocol") },
        { DockerContainer::Awg2,
          QObject::tr("AmneziaWG is a modern VPN protocol based on WireGuard, "
                      "combining simplified architecture with high performance across all devices. "
                      "It addresses WireGuard's main vulnerability (easy detection by DPI systems) through advanced obfuscation techniques, "
                      "making VPN traffic indistinguishable from regular internet traffic.\n"
                      "\nAmneziaWG is an excellent choice for those seeking a fast, stealthy VPN connection.\n"
                      "\nFeatures:\n"
                      "* Available on all Dopamine platforms\n"
                      "* Low battery consumption on mobile devices\n"
                      "* Minimal settings required\n"
                      "* Undetectable by traffic analysis systems (DPI)\n"
                      "* Operates over UDP protocol") },
        { DockerContainer::Xray,
          QObject::tr("REALITY is an innovative protocol developed by the creators of XRay, designed specifically to combat high levels of internet censorship. "
                      "REALITY identifies censorship systems during the TLS handshake, "
                      "redirecting suspicious traffic seamlessly to legitimate websites like google.com while providing genuine TLS certificates. "
                      "This allows VPN traffic to blend indistinguishably with regular web traffic without special configuration."
                      "\nUnlike older protocols such as VMess, VLESS, and XTLS-Vision, REALITY incorporates an advanced built-in \"friend-or-foe\" detection mechanism, "
                      "effectively protecting against DPI and other traffic analysis methods.\n"
                      "\nFeatures:\n"
                      "* Resistant to active probing and DPI detection\n"
                      "* No special configuration required to disguise traffic\n"
                      "* Highly effective in heavily censored regions\n"
                      "* Minimal battery consumption on devices\n"
                      "* Operates over TCP protocol") },

        { DockerContainer::TorWebSite, QObject::tr("Website in Tor network") },
        { DockerContainer::Dns, QObject::tr("DNS Service") },
        { DockerContainer::Sftp,
          QObject::tr("After installation, Dopamine will create a\n\n file storage on your server. "
                      "You will be able to access it using\n FileZilla or other SFTP clients, "
                      "as well as mount the disk on your device to access\n it directly from your device.\n\n"
                      "For more detailed information, you can\n find it in the support section under \"Create SFTP file storage.\" ") },
        { DockerContainer::Socks5Proxy, QObject::tr("SOCKS5 proxy server") }
    };
}

amnezia::ServiceType ContainerProps::containerService(DockerContainer c)
{
    return ProtocolProps::protocolService(defaultProtocol(c));
}

Proto ContainerProps::defaultProtocol(DockerContainer c)
{
    switch (c) {
    case DockerContainer::None: return Proto::Any;
    case DockerContainer::WireGuard: return Proto::WireGuard;
    case DockerContainer::Awg2: return Proto::Awg;
    case DockerContainer::Awg: return Proto::Awg;
    case DockerContainer::Xray: return Proto::Xray;
    case DockerContainer::SSXray: return Proto::SSXray;

    case DockerContainer::TorWebSite: return Proto::TorWebSite;
    case DockerContainer::Dns: return Proto::Dns;
    case DockerContainer::Sftp: return Proto::Sftp;
    case DockerContainer::Socks5Proxy: return Proto::Socks5Proxy;
    default: return Proto::Any;
    }
}

QString ContainerProps::containerTypeToProtocolString(DockerContainer c)
{
    if (c == DockerContainer::None)
        return "none";

    Proto p = defaultProtocol(c);
    return ProtocolProps::protoToString(p);
}

bool ContainerProps::isSupportedByCurrentPlatform(DockerContainer c)
{
#ifdef Q_OS_WINDOWS
    return true;

#elif defined(Q_OS_IOS)
    // Standard iOS build (without Network Extension limitations)
    switch (c) {
    case DockerContainer::WireGuard: return true;
    case DockerContainer::Awg2: return true;
    case DockerContainer::Awg: return true;
    case DockerContainer::Xray: return true;
    case DockerContainer::SSXray: return true;
    default:
        return false;
    }

#elif defined(MACOS_NE)
    // macOS build using Network Extension
    switch (c) {
    case DockerContainer::WireGuard: return true;
    case DockerContainer::Awg2: return true;
    case DockerContainer::Awg: return true;
    case DockerContainer::Xray: return true;
    case DockerContainer::SSXray: return true;
    default:
        return false;
    }
#elif defined(Q_OS_MAC)
    switch (c) {
    case DockerContainer::WireGuard: return true;
    default: return true;
    }

#elif defined(Q_OS_ANDROID)
    switch (c) {
    case DockerContainer::WireGuard: return true;
    case DockerContainer::Awg2: return true;
    case DockerContainer::Awg: return true;
    case DockerContainer::Xray: return true;
    case DockerContainer::SSXray: return true;
    default: return false;
    }

#elif defined(Q_OS_LINUX)
    return true;

#else
    return false;
#endif
}

QStringList ContainerProps::fixedPortsForContainer(DockerContainer c)
{
    Q_UNUSED(c);
    return {};
}

bool ContainerProps::isEasySetupContainer(DockerContainer container)
{
    switch (container) {
    case DockerContainer::Awg2: return true;
    default: return false;
    }
}

QString ContainerProps::easySetupHeader(DockerContainer container)
{
    switch (container) {
    case DockerContainer::Awg2: return tr("Automatic");
    default: return "";
    }
}

QString ContainerProps::easySetupDescription(DockerContainer container)
{
    switch (container) {
    case DockerContainer::Awg2: return tr("AmneziaWG protocol will be installed. "
                                         "It provides high connection speed and ensures stable operation even in the most challenging network conditions.");
    default: return "";
    }
}

int ContainerProps::easySetupOrder(DockerContainer container)
{
    switch (container) {
    case DockerContainer::Awg2: return 1;
    default: return 0;
    }
}

bool ContainerProps::isShareable(DockerContainer container)
{
    switch (container) {
    case DockerContainer::TorWebSite: return false;
    case DockerContainer::Dns: return false;
    case DockerContainer::Sftp: return false;
    case DockerContainer::Socks5Proxy: return false;
    default: return true;
    }
}

bool ContainerProps::isAwgContainer(DockerContainer container)
{
    return container == DockerContainer::Awg || container == DockerContainer::Awg2;
}


QJsonObject ContainerProps::getProtocolConfigFromContainer(const Proto protocol, const QJsonObject &containerConfig)
{
    QString protocolConfigString = containerConfig.value(ProtocolProps::protoToString(protocol))
    .toObject()
            .value(config_key::last_config)
            .toString();

    return QJsonDocument::fromJson(protocolConfigString.toUtf8()).object();
}

int ContainerProps::installPageOrder(DockerContainer container)
{
    switch (container) {
    case DockerContainer::WireGuard: return 2;
    case DockerContainer::Awg2: return 1;
    case DockerContainer::Xray: return 3;
    case DockerContainer::SSXray: return 8;
    default: return 0;
    }
}
