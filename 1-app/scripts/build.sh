#!/usr/bin/env bash
# يبني APK موقّعًا بأدوات Android SDK الرسمية (دون Gradle)
set -euo pipefail
cd "$(dirname "$0")/.."
SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:?Android SDK not found}}"
BT="$SDK/build-tools/$(ls "$SDK/build-tools" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1)"
if [ -f "$SDK/platforms/android-34/android.jar" ]; then PLAT="$SDK/platforms/android-34/android.jar"
else PLAT="$SDK/platforms/$(ls "$SDK/platforms" | grep -E '^android-[0-9]+$' | sort -V | tail -1)/android.jar"; fi
VC="${VC:-1}"; VN="${VN:-1.1}"
echo "build-tools: $BT"; echo "platform: $PLAT"; echo "version: $VN ($VC)"
[ -f assets/www/data.js ] || bash scripts/fetch_assets.sh
O=build; rm -rf "$O"; mkdir -p "$O/gen" "$O/cls" "$O/dex"
"$BT/aapt2" compile --dir res -o "$O/res.zip"
"$BT/aapt2" link -o "$O/base.apk" -I "$PLAT" --manifest AndroidManifest.xml --java "$O/gen" -A assets \
  --min-sdk-version 24 --target-sdk-version 34 --version-code "$VC" --version-name "$VN" -0 woff2 "$O/res.zip"
javac -nowarn -source 8 -target 8 -bootclasspath "$PLAT" -d "$O/cls" $(find src "$O/gen" -name '*.java')
"$BT/d8" --release --min-api 24 --lib "$PLAT" --output "$O/dex" $(find "$O/cls" -name '*.class')
(cd "$O/dex" && zip -q ../base.apk classes.dex)
"$BT/zipalign" -f -p 4 "$O/base.apk" "$O/aligned.apk"
base64 -d keystore/mukth.jks.b64 > "$O/mukth.jks"
"$BT/apksigner" sign --ks "$O/mukth.jks" --ks-pass pass:mukth-app --ks-key-alias mukth --out "$O/Mukth.apk" "$O/aligned.apk"
"$BT/apksigner" verify --verbose "$O/Mukth.apk" | head -6
ls -la "$O/Mukth.apk"
