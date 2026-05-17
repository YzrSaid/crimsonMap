#!/usr/bin/env bash
# Strips the 2 Mapbox permission classes from libcore-release.aar so they
# don't collide with mapbox_maps_flutter's common-ndk27 dependency.
#
# Why this is needed:
#   - Unity exports its Mapbox SDK as libcore-release.aar (bundled, older).
#   - mapbox_maps_flutter pulls in com.mapbox.common:common-ndk27 (newer).
#   - Both contain com.mapbox.android.core.permissions.PermissionsListener
#     and PermissionsManager -> Gradle "Duplicate class" error.
#   - common-ndk27 is a thin subset (only permissions). libcore-release has
#     ~28 other classes Unity's Mapbox SDK needs at runtime - keep those.
#
# Run after every Unity "Flutter > Export Android Release". Idempotent.
set -euo pipefail

AAR="$(cd "$(dirname "$0")/.." && pwd)/android/unityLibrary/libs/libcore-release.aar"

if [ ! -f "$AAR" ]; then
  echo "ERROR: $AAR not found. Has Unity been exported yet?"
  exit 1
fi

WORK="$(mktemp -d)"
trap "rm -rf '$WORK'" EXIT

echo "Stripping duplicate Mapbox permission classes from libcore-release.aar..."
cd "$WORK"

unzip -q "$AAR"
mkdir _classes && cd _classes
unzip -q ../classes.jar

# The two conflicting classes (also covers no-op when already stripped).
rm -f com/mapbox/android/core/permissions/PermissionsListener.class
rm -f com/mapbox/android/core/permissions/PermissionsManager.class
rmdir com/mapbox/android/core/permissions 2>/dev/null || true

# Repack classes.jar (no compression on .class is fine; zip default is OK).
rm ../classes.jar
zip -qr ../classes.jar .
cd ..
rm -rf _classes

# Repack AAR - same top-level files Unity produced.
ORIG_FILES=(AndroidManifest.xml classes.jar proguard.txt R.txt)
zip -q -FS "$AAR.new" "${ORIG_FILES[@]}"

mv "$AAR.new" "$AAR"
echo "Done. $AAR is now duplicate-free."
