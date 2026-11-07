#!/bin/sh
set -eu

###########################################################
# ValheimRcon Override
###########################################################

RCON_SOURCE="/overrides/rcon/ValheimRcon.dll"

CONFIG_DEST="/config/bepinex/plugins/ValheimRcon.dll"

RUNTIME_DEST="/opt/valheim/bepinex/BepInEx/plugins/ValheimRcon.dll"

echo "Applying pinned ValheimRcon override..."

# Fail startup rather than silently launching the known-broken
# Vikinger RCON version if our override disappears.
if [ ! -f "${RCON_SOURCE}" ]; then
    echo "ERROR: ${RCON_SOURCE} does not exist." >&2
    exit 1
fi

# Make sure both plugin directories exist.
mkdir -p \
    "$(dirname "${CONFIG_DEST}")" \
    "$(dirname "${RUNTIME_DEST}")"

# Vikinger/bootstrap may have installed its bundled RCON DLL.
# Replace both copies immediately before Valheim starts.
cp -f "${RCON_SOURCE}" "${CONFIG_DEST}"
cp -f "${RCON_SOURCE}" "${RUNTIME_DEST}"

chmod 0644 \
    "${CONFIG_DEST}" \
    "${RUNTIME_DEST}"

echo "ValheimRcon override applied."