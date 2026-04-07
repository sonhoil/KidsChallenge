# BoxServer 프로젝트 구조

## 패키지 구조

```
com.boxsage.api/
├── controller/          # REST 컨트롤러
│   ├── base/           # 공통 베이스 컨트롤러
│   └── HealthController.java
├── service/            # 비즈니스 로직 서비스
│   └── UserService.java
├── mapper/             # MyBatis 매퍼 인터페이스
│   └── UserMapper.java
├── domain/             # 도메인 엔티티
│   └── User.java
├── dto/                # 데이터 전송 객체
│   ├── ApiResponse.java
│   ├── ErrorResponse.java
│   └── PageResponse.java
└── config/             # 설정 클래스
    ├── MyBatisConfig.java
    └── GlobalExceptionHandler.java
```

## 리소스 구조

```
src/main/resources/
├── mapper/             # MyBatis XML 매퍼 파일
│   └── UserMapper.xml
└── application.yml     # 애플리케이션 설정
```

## 주요 컴포넌트 설명

### Controller
- REST API 엔드포인트를 정의하는 레이어
- `ApiControllerBase`를 상속하여 공통 기능 사용 가능

### Service
- 비즈니스 로직을 처리하는 레이어
- `@Transactional` 어노테이션으로 트랜잭션 관리

### Mapper
- MyBatis 인터페이스로 데이터베이스 접근을 정의
- XML 매퍼 파일과 매핑됨

### Domain
- 도메인 엔티티 클래스
- 데이터베이스 테이블과 매핑되는 객체

### DTO
- API 요청/응답에 사용되는 데이터 전송 객체
- `ApiResponse<T>`: 성공 응답 래퍼
- `ErrorResponse`: 에러 응답 형식
- `PageResponse<T>`: 페이징 응답 형식

### Config
- MyBatis 설정 및 전역 예외 처리 등 설정 클래스

## 다음 단계

1. 데이터베이스 연결 설정 확인
2. 도메인 엔티티 추가 (Organization, Box, Item 등)
3. 각 도메인별 Mapper, Service, Controller 구현
4. Spring Security 연동
5. 세션 관리 구현
