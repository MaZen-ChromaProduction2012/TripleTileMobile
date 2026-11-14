# 🚀 دليل استخراج APK لعبة Triple Tile Match ونشرها على المتاجر المجانية + تفعيل AdMob

## 1️⃣ استخراج ملف الـ `APK` على اللاب (أوفلاين في خطوة واحدة)
افتح فولدر `triple_tile_flutter` في برنامج **VS Code**، واضغط مرتين على ملف:
`BUILD_APK_OFFLINE.bat`
أو اكتب في الـ Terminal:
```bash
flutter create . --offline
flutter build apk --release --offline
```
هتلاقي ملف الـ APK النهائي جاهز في المسار:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 2️⃣ مكان وضع شفرات إعلانات Google AdMob الـ 3
في أول ملف `lib/main.dart` داخل كلاس `AdMobConfig` هتلاقي الـ 3 شفرات جاهزين:
- `bannerAdUnitId`: شفرة الإعلان الشريطي السفلي.
- `interstitialAdUnitId`: شفرة إعلان الشاشة الكاملة بين المراحل (مضبوط يظهر مرة كل دورين لحماية الحساب).
- `rewardedAdUnitId`: شفرة إعلان الفيديو الكامل بمكافأة (+100 عملة ذهبية أو استكمال الدور عند الخسارة، ومضبوط بحد أقصى آمن 10 مرات يومياً لكل لاعب).

---

## 3️⃣ خطوات النشر على الـ 5 متاجر المجانية (بتكلفة 0 جنيه)
1. **Amazon Appstore** (`https://developer.amazon.com/apps-and-games`): سجل حساب مجاني وارفع `app-release.apk`، ثم اربطه بـ AdMob لتفعيل الإعلانات رسمياً.
2. **Samsung Galaxy Store** (`https://seller.samsungapps.com/`): سجل بحساب سامسونج مجاناً وارفع اللعبة لتظهر لمستخدمي هواتف سامسونج وتربطها بـ AdMob.
3. **Huawei AppGallery** (`https://developer.huawei.com/consumer/en/appgallery/`): حساب مطور مجاني لنشر اللعبة على هواتف هواوي وأونر.
4. **Uptodown Developers Console** (`https://en.uptodown.com/developers-console`): نشر مجاني وسريع للظهور في نتائج بحث جوجل.
5. **APKPure Developer** (`https://developer.apkpure.com/`): نشر مجاني مع إحصائيات تحميل وتحديثات مباشرة.
