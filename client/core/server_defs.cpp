#include "server_defs.h"

QString amnezia::server::getDockerfileFolder(amnezia::DockerContainer container)
{
    return "/opt/amnezia/" + ContainerProps::containerToString(container);
}
