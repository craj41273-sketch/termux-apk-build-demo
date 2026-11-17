#!/usr/bin/env bash
# Build a minimal Android APK entirely on-device (Termux).
set -euo pipefail

PROJ="$(cd "$(dirname "$0")" && pwd)"
BASE="$(cd "$PROJ/.." && pwd)"
TOOLS="${TOOLS_DIR:-$BASE/tools}"
cd "$PROJ"

for tool in android.jar r8.jar uber-apk-signer.jar aapt2; do
  if [ ! -e "$TOOLS/$tool" ]; then
    echo "Missing tool: $TOOLS/$tool (set TOOLS_DIR to the directory containing it)" >&2
    exit 1
  fi
done
chmod +x "$TOOLS/aapt2" 2>/dev/null || true

rm -rf classes gen out dexout compiled.zip classes.dex unsigned.apk
mkdir -p classes gen out dexout

echo "[1/5] javac -> .class"
javac -source 8 -target 8 -bootclasspath "$TOOLS/android.jar" \
      -d classes src/com/example/termuxrebuild/MainActivity.java 2>&1 | grep -v 'bootstrap class path' || true

echo "[2/5] D8 -> classes.dex"
find classes -name '*.class' -print0 | xargs -0 java -cp "$TOOLS/r8.jar" com.android.tools.r8.D8 \
      --lib "$TOOLS/android.jar" --min-api 21 --output dexout
cp dexout/classes.dex .

echo "[3/5] aapt2 compile + link -> unsigned.apk"
"$TOOLS/aapt2" compile res/values/strings.xml -o compiled.zip
"$TOOLS/aapt2" link -o unsigned.apk \
      -I "$TOOLS/android.jar" \
      --manifest AndroidManifest.xml \
      --min-sdk-version 21 --target-sdk-version 34 \
      --java gen compiled.zip

echo "[4/5] add classes.dex"
if command -v zip >/dev/null 2>&1; then
  zip -q unsigned.apk classes.dex
else
  jar uf unsigned.apk classes.dex
fi

echo "[5/5] sign (v1/v2/v3)"
java -jar "$TOOLS/uber-apk-signer.jar" -a unsigned.apk -o out --allowResign --skipZipAlign

mkdir -p dist
cp out/unsigned-debugSigned.apk dist/termux-rebuild-demo.apk
echo "=== result ==="
ls -lh dist/termux-rebuild-demo.apk
