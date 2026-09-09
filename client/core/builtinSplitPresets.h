#ifndef BUILTINSPLITPRESETS_H
#define BUILTINSPLITPRESETS_H

#include <QJsonArray>

// Hardcoded split-tunnel presets (RU subnet lists), merged with the API
// catalog by SplitPresetsModel for the UI and consulted by vpnconnection
// when flattening enabled presets at connect time. Entries have the same
// shape as the API catalog: [{"id": ..., "name": ..., "domains": [...]}] —
// here "domains" are CIDR subnets, which pass through without DNS resolving.
namespace BuiltinSplitPresets
{
    QJsonArray presets();
}

#endif // BUILTINSPLITPRESETS_H
