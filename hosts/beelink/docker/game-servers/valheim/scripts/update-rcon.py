import io
import json
import os
import tempfile
import time
import urllib.request
import zipfile
from pathlib import Path


###########################################################
# Configuration
###########################################################

API_URL = (
    "https://thunderstore.io/api/experimental/package/"
    "Tristan/ValheimRcon/"
)

ROOT = Path("/rcon-cache")

DLL_PATH = ROOT / "ValheimRcon.dll"
VERSION_FILE = ROOT / ".version"

# Check Thunderstore every 6 hours.
CHECK_INTERVAL = 6 * 60 * 60


###########################################################
# Thunderstore
###########################################################

def get_latest():
    request = urllib.request.Request(
        API_URL,
        headers={
            "Accept": "application/json",
            "User-Agent": "homelab-example-valheim-rcon-updater/1.0",
        },
    )

    with urllib.request.urlopen(request, timeout=30) as response:
        data = json.load(response)

    latest = data["latest"]

    return (
        latest["version_number"],
        latest["download_url"],
    )


###########################################################
# Current Version
###########################################################

def current_version():
    try:
        return VERSION_FILE.read_text().strip()
    except FileNotFoundError:
        return None


###########################################################
# Install Update
###########################################################

def install(version, download_url):
    print(
        f"Downloading ValheimRcon {version}...",
        flush=True,
    )

    request = urllib.request.Request(
        download_url,
        headers={
            "User-Agent": "homelab-example-valheim-rcon-updater/1.0",
        },
    )

    with urllib.request.urlopen(
        request,
        timeout=120,
    ) as response:
        archive_data = response.read()

    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)

        with zipfile.ZipFile(
            io.BytesIO(archive_data)
        ) as archive:
            archive.extractall(tmp_path)

        ###################################################
        # Locate DLL
        ###################################################

        candidates = list(
            tmp_path.rglob("ValheimRcon.dll")
        )

        if not candidates:
            raise RuntimeError(
                "Downloaded package does not contain "
                "ValheimRcon.dll"
            )

        source_dll = candidates[0]

        if source_dll.stat().st_size == 0:
            raise RuntimeError(
                "Downloaded ValheimRcon.dll is empty"
            )

        ###################################################
        # Atomic Replacement
        ###################################################

        ROOT.mkdir(
            parents=True,
            exist_ok=True,
        )

        temporary_dll = (
            ROOT / "ValheimRcon.dll.new"
        )

        temporary_dll.write_bytes(
            source_dll.read_bytes()
        )

        # Atomic rename means the pre-server hook will
        # always see either the old complete DLL or the
        # new complete DLL, never a partially written file.
        os.replace(
            temporary_dll,
            DLL_PATH,
        )

        VERSION_FILE.write_text(
            version + "\n"
        )

    print(
        f"ValheimRcon updated to {version}.",
        flush=True,
    )


###########################################################
# Update Check
###########################################################

def check():
    latest_version, download_url = get_latest()

    installed_version = current_version()

    print(
        "ValheimRcon "
        f"current={installed_version or 'none'} "
        f"latest={latest_version}",
        flush=True,
    )

    if installed_version == latest_version:
        return

    install(
        latest_version,
        download_url,
    )


###########################################################
# Main Loop
###########################################################

ROOT.mkdir(
    parents=True,
    exist_ok=True,
)

while True:
    try:
        check()

    except Exception as exc:
        # Never destroy the existing known-good DLL when an
        # update check or download fails.
        print(
            f"ValheimRcon update check failed: {exc}",
            flush=True,
        )

    time.sleep(CHECK_INTERVAL)
