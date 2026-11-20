# مُكْث

تطبيق أندرويد لحفظ القرآن الكريم آيةً آية: تظهر الآية وحدها في موضعها من صفحة مصحف المدينة ويُحجب ما سواها.

## التنزيل
من صفحة **Releases** نزِّل `Mukth.apk` وثبِّته (أندرويد 7.0 فما فوق).

## البناء
كل دفع إلى `main` يبني APK موقّعًا وينشره في Releases عبر GitHub Actions.
محليًّا: `bash scripts/build.sh` (يحتاج Android SDK و JDK 17 و Node و Python 3).

## المصادر
- رسم الكلمات: خطوط مجمع الملك فهد لطباعة المصحف الشريف (QCF) من مستودع quran.com-frontend-next.
- ترتيب الكلمات والأسطر: `@kmaslesa/holy-quran-word-by-word-full-data`، ويُطابَق عند البناء مع `quran-meta` (114 سورة، 6236 آية، 604 صفحات).
- التلاوات: EveryAyah.com. خط الواجهة: IBM Plex Sans Arabic.
