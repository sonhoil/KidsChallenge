# 데이터베이스 설정

## DATABASE_URL 환경 변수 설정

DATABASE_URL 환경 변수를 설정하면 자동으로 파싱되어 Spring Boot DataSource 설정에 반영됩니다.

### 제공된 DATABASE_URL
```
postgresql://postgres:ggthegame2%40@localhost:5432/postgres?schema=boxsage
```

### 환경 변수 설정 방법

#### 1. IDE에서 실행 시 (IntelliJ IDEA / Eclipse)
- Run Configuration에서 Environment variables에 추가:
  ```
  DATABASE_URL=postgresql://postgres:ggthegame2%40@localhost:5432/postgres?schema=boxsage
  ```

#### 2. 터미널에서 실행 시
```bash
export DATABASE_URL="postgresql://postgres:ggthegame2%40@localhost:5432/postgres?schema=boxsage"
cd server/boxserver
mvn spring-boot:run
```

#### 3. Windows에서 실행 시
```cmd
set DATABASE_URL=postgresql://postgres:ggthegame2%40@localhost:5432/postgres?schema=boxsage
cd server\boxserver
mvn spring-boot:run
```

#### 4. .env 파일 사용 (권장)
프로젝트 루트에 `.env` 파일을 생성하고:
```
DATABASE_URL=postgresql://postgres:ggthegame2%40@localhost:5432/postgres?schema=boxsage
```

그리고 Spring Boot 실행 시 환경 변수를 로드하도록 설정합니다.

### 파싱되는 정보
- **호스트**: localhost
- **포트**: 5432
- **데이터베이스**: postgres
- **스키마**: boxsage
- **사용자명**: postgres
- **비밀번호**: ggthegame2@

### JDBC URL 변환
위 DATABASE_URL은 다음 JDBC URL로 변환됩니다:
```
jdbc:postgresql://localhost:5432/postgres?currentSchema=boxsage
```

### 주의사항
- DATABASE_URL 환경 변수가 설정되지 않으면 `application.yml`의 기본값이 사용됩니다.
- 비밀번호에 특수문자(@)가 포함되어 있으므로 URL 인코딩(%40)이 필요합니다.
