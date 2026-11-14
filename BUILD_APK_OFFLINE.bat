@echo off
chcp 65001 >nul
echo ====================================================================
echo   Triple Tile Match - Offline Runner ^& APK Builder (Mazen ^& Saif)
echo ====================================================================
cd /d "%~dp0"
echo [1/3] تجهيز ملفات المنصة أوفلاين (flutter create . --offline)...
call flutter create . --offline
echo [2/3] هل تريد بناء ملف APK النهائي للنشر على المتاجر؟
echo جاري استخراج ملف APK النهائي (Release APK)...
call flutter build apk --release --offline
echo.
echo ✅ تم استخراج ملف الـ APK بنجاح في المسار:
echo build\app\outputs\flutter-apk\app-release.apk
pause
