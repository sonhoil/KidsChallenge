#!/bin/bash

# 앱 제거 스크립트
echo "=== 앱 제거 ==="

# adb 경로 확인
ADB_PATH="/Users/cooking/Library/Android/sdk/platform-tools/adb"

if [ ! -f "$ADB_PATH" ]; then
    echo "adb를 찾을 수 없습니다: $ADB_PATH"
    echo "Android SDK Platform Tools가 설치되어 있는지 확인하세요."
    exit 1
fi

# 연결된 기기 확인
DEVICES=$("$ADB_PATH" devices | grep -v "List" | grep "device" | wc -l | tr -d ' ')

if [ "$DEVICES" -eq 0 ]; then
    echo "연결된 Android 기기가 없습니다."
    echo "기기를 USB로 연결하거나 Wi-Fi 디버깅을 활성화하세요."
    exit 1
fi

echo "연결된 기기: $DEVICES 개"
echo ""

# 앱 제거
PACKAGE_NAME="com.kidspoint.kids_challenge"
echo "앱 제거 중: $PACKAGE_NAME"

"$ADB_PATH" uninstall "$PACKAGE_NAME"

if [ $? -eq 0 ]; then
    echo "✓ 앱이 성공적으로 제거되었습니다."
else
    echo "✗ 앱 제거 실패 (앱이 설치되어 있지 않을 수 있습니다)"
fi

echo ""
echo "이제 다음 명령어로 앱을 재설치하세요:"
echo "  flutter clean"
echo "  flutter pub get"
echo "  flutter run"
