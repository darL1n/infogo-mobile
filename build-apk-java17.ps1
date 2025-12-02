# === НАСТРОЙКА ===
$java17Path = "C:\Program Files\Java\jdk-17" # 🔁 Укажи путь к своей установленной Java 17

if (-Not (Test-Path "$java17Path\bin\java.exe")) {
    Write-Host "❌ Java 17 не найдена по пути: $java17Path"
    exit 1
}

# === ПЕРЕКЛЮЧЕНИЕ JAVA ===
$env:JAVA_HOME = $java17Path
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

Write-Host "`n✅ JAVA_HOME установлен: $env:JAVA_HOME"
java -version

# === СБОРКА ПРОЕКТА ===
Write-Host "`n🧹 Очистка проекта..."
flutter clean

Write-Host "`n📦 Установка зависимостей..."
flutter pub get

Write-Host "`n🚀 Сборка APK (release)..."
flutter build apk --release --verbose

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ APK успешно собран! Файл будет в: build\app\outputs\flutter-apk\app-release.apk"
} else {
    Write-Host "`n❌ Ошибка при сборке APK"
}
