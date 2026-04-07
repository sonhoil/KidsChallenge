FROM maven:3.9.9-eclipse-temurin-17 AS builder
WORKDIR /app

COPY pom.xml ./
COPY src ./src

RUN mvn -B -DskipTests clean package
RUN cp "$(ls target/*.jar | grep -v '\.original$' | head -n 1)" /app/app.jar

FROM eclipse-temurin:17-jre
WORKDIR /app

COPY --from=builder /app/app.jar /app/app.jar

ENV PORT=8080
EXPOSE 8080

CMD ["sh", "-c", "java -Dserver.port=${PORT} -jar /app/app.jar"]

