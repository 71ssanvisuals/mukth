#!/usr/bin/env bash
# يجلب خطوط المصحف وبياناته من مصادرها ويبني data.js
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
W="$ROOT/assets/www"; T="$ROOT/.tmp"
mkdir -p "$W/fonts" "$T"; cd "$T"
QF=https://raw.githubusercontent.com/quran/quran.com-frontend-next/production/public/fonts/quran/hafs
seq 1 604 | xargs -P 8 -I{} curl -sS -f --retry 5 --retry-all-errors -o "$W/fonts/p{}.woff2" "$QF/v1/woff2/p{}.woff2"
curl -sS -f --retry 5 -o "$W/fonts/UthmanicHafs.woff2" "$QF/uthmanic_hafs/UthmanicHafs1Ver18.woff2"
test "$(ls "$W/fonts" | grep -c '^p[0-9]*\.woff2$')" = 604
npm pack --silent @kmaslesa/holy-quran-word-by-word-full-data@1.0.6 quran-meta@7.0.0 @fontsource/ibm-plex-sans-arabic@5.3.0 >/dev/null
for f in *.tgz; do d="${f%.tgz}"; mkdir -p "$d"; tar xzf "$f" -C "$d"; done
for w in 400 500 700; do cp fontsource-ibm-plex-sans-arabic-*/package/files/ibm-plex-sans-arabic-arabic-$w-normal.woff2 "$W/fonts/ui-$w.woff2"; done
HL="$(ls "$T"/quran-meta-*/package/dist/HafsLists-*.js)"
node --input-type=module -e "import('file://$HL').then(async m=>{const fs=await import('node:fs');fs.writeFileSync('$T/hafs.json',JSON.stringify(m.t))})"
python3 "$ROOT/scripts/mkdata.py" "$T"/kmaslesa-*/package/data.json "$T/hafs.json" "$W/data.js"
