# Java 11 설치 가이드

Flutter의 최신 Gradle 플러그인은 Java 11 이상을 요구합니다. 현재 시스템에는 Java 8만 설치되어 있어 빌드가 실패합니다.

## 해결 방법

### 옵션 1: Homebrew를 사용한 Java 11 설치 (권장)

```bash
# Java 11 설치
brew install openjdk@11

# Java 11을 기본값으로 설정
sudo ln -sfn /opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk

# 현재 세션에서 Java 11 사용
export JAVA_HOME=/opt/homebrew/opt/openjdk@11
export PATH="$JAVA_HOME/bin:$PATH"

# 확인
java -version
```

### 옵션 2: Java 17 설치 (더 권장)

Java 17은 LTS 버전이며 더 많은 기능을 지원합니다:

```bash
# Java 17 설치
brew install openjdk@17

# Java 17을 기본값으로 설정
sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk

# 현재 세션에서 Java 17 사용
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
export PATH="$JAVA_HOME/bin:$PATH"

# 확인
java -version
```

### 옵션 3: gradle.properties에 Java 경로 명시

Java 11 이상이 이미 설치되어 있다면, `android/gradle.properties`에 다음을 추가:

```properties
org.gradle.java.home=/path/to/java11
```

## 설치 확인

설치 후 다음 명령어로 확인:

```bash
java -version
# 출력 예시: openjdk version "11.0.x" 또는 "17.0.x"
```

## 영구 설정

`~/.zshrc` 또는 `~/.bash_profile`에 다음을 추가하여 영구적으로 설정:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@11  # 또는 openjdk@17
export PATH="$JAVA_HOME/bin:$PATH"
```

그 다음:
```bash
source ~/.zshrc  # 또는 source ~/.bash_profile
```

## 참고

- Java 11 이상이 설치되면 Flutter Android 빌드가 정상적으로 작동합니다
- Java 8은 더 이상 Flutter의 최신 버전에서 지원되지 않습니다
