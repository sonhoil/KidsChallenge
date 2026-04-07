#!/bin/bash

echo "=== 카카오 로그인용 키 해시 생성 ==="
echo ""

# 디버그 키 해시
echo "1. 디버그 키 해시 (개발용):"
DEBUG_HASH=$(keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep "SHA1:" | sed 's/.*SHA1: //' | tr -d ' ')

if [ -z "$DEBUG_HASH" ]; then
    echo "   디버그 키스토어를 찾을 수 없습니다."
    echo "   경로: ~/.android/debug.keystore"
else
    echo "   SHA1: $DEBUG_HASH"
    # 콜론 제거 후 Base64 인코딩
    KEY_HASH=$(echo "$DEBUG_HASH" | tr -d ':' | xxd -r -p | openssl base64)
    echo "   키 해시 (카카오 등록용): $KEY_HASH"
fi

echo ""
echo "2. 릴리즈 키 해시 (배포용):"
read -p "   릴리즈 키스토어를 사용하시겠습니까? (y/n): " use_release

if [ "$use_release" = "y" ] || [ "$use_release" = "Y" ]; then
    read -p "   키스토어 경로: " keystore_path
    read -p "   키스토어 비밀번호: " -s keystore_pass
    echo ""
    read -p "   키 별칭: " key_alias
    
    RELEASE_HASH=$(keytool -list -v -keystore "$keystore_path" -alias "$key_alias" -storepass "$keystore_pass" 2>/dev/null | grep -A 1 "SHA1:" | tail -1 | sed 's/.*SHA1: //')
    
    if [ -z "$RELEASE_HASH" ]; then
        echo "   릴리즈 키 해시를 생성할 수 없습니다."
    else
        echo "   SHA1: $RELEASE_HASH"
        RELEASE_KEY_HASH=$(echo "$RELEASE_HASH" | xxd -r -p | openssl base64)
        echo "   키 해시 (카카오 등록용): $RELEASE_KEY_HASH"
    fi
else
    echo "   건너뜀"
fi

echo ""
echo "=== 완료 ==="
echo "위의 키 해시를 카카오 개발자 콘솔 > Android 앱 정보 > 키 해시에 등록하세요."
