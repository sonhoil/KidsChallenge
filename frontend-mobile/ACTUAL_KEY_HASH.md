# 실제 앱이 사용하는 키 해시

## 확인된 키 해시

앱 실행 로그에서 확인한 실제 키 해시:

```
SHA1 Digest (hex): EC:16:E3:70:C3:F9:E9:6C:B7:0B:06:2A:E0:31:33:B5:A4:8F:8D:5B
Key Hash (Base64): 7BbjcMP56Wy3CwYq4DEztaSPjVs=
```

## 카카오 개발자 콘솔에 등록

1. [카카오 개발자 콘솔](https://developers.kakao.com/) 접속
2. 앱 선택
3. **플랫폼 > Android** 선택
4. **키 해시** 항목에 다음 값을 추가:
   ```
   7BbjcMP56Wy3CwYq4DEztaSPjVs=
   ```
5. **저장** 버튼 클릭

## 기존 키 해시와 비교

이전에 등록한 키 해시와 다릅니다:
- 이전: `kVCtyr7A/x+9NTSklToq/yU2Ms0+2+kWjubom1/ICW8=`
- 실제: `7BbjcMP56Wy3CwYq4DEztaSPjVs=`

## 변경사항 반영 대기

카카오 개발자 콘솔에서 변경사항이 반영되는 데 **5-10분** 정도 소요될 수 있습니다.

## 재테스트

1. 키 해시 등록 후 5-10분 대기
2. 앱에서 카카오 로그인 재시도
3. 성공 확인
