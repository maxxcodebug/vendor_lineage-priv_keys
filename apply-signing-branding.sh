#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANDROID_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

XML="$ANDROID_ROOT/packages/apps/Settings/res/xml/my_device_info.xml"
STRINGS="$ANDROID_ROOT/packages/apps/Settings/res/values/strings.xml"

if [[ ! -f "$XML" || ! -f "$STRINGS" ]]; then
    echo "ERROR: Android Settings source files were not found."
    echo "Expected Android source root: $ANDROID_ROOT"
    exit 1
fi

python3 - "$XML" "$STRINGS" <<'PY'
import pathlib
import re
import sys
import xml.etree.ElementTree as ET

xml_path = pathlib.Path(sys.argv[1])
strings_path = pathlib.Path(sys.argv[2])

xml = xml_path.read_text()
strings = strings_path.read_text()

key = "anshuman_signing_key"

if key not in xml:
    pattern = (
        r'(<Preference\b(?=[^>]*android:key="build_number")[^>]*/>)'
    )
    preference = '''
        <!-- ROM signing information -->
        <Preference
            android:key="anshuman_signing_key"
            android:order="54"
            android:title="@string/anshuman_signing_key_title"
            android:summary="@string/anshuman_signing_key_summary"
            android:selectable="false"/>'''

    updated, count = re.subn(
        pattern, lambda match: match.group(1) + preference, xml, count=1
    )
    if count != 1:
        raise SystemExit(
            "ERROR: Could not find the build_number preference. No XML change made."
        )
    ET.fromstring(updated)
    xml_path.write_text(updated)
    print("Added signing information to About phone.")
else:
    print("About phone signing entry already exists.")

resources = [
    (
        "anshuman_signing_key_title",
        "Signed with Anshuman's key",
    ),
    (
        "anshuman_signing_key_summary",
        "ROM signing key information",
    ),
]

for name, value in resources:
    if re.search(r'<string\s+name="' + re.escape(name) + r'"', strings):
        continue
    escaped = (
        value.replace("&", "&amp;")
             .replace("<", "&lt;")
             .replace(">", "&gt;")
             .replace("'", "\\'")
    )
    entry = f'    <string name="{name}">{escaped}</string>\n'
    if "</resources>" not in strings:
        raise SystemExit("ERROR: Could not find </resources> in strings.xml.")
    strings = strings.replace("</resources>", entry + "</resources>", 1)
    print(f"Added string resource: {name}")

ET.fromstring(strings)
strings_path.write_text(strings)
print("Signing branding integration applied.")
PY
