FROM maven:3.9.9-eclipse-temurin-17 AS builder
WORKDIR /app

COPY pom.xml ./
COPY src ./src

RUN mvn -B -DskipTests clean package
RUN cp "$(ls target/*.war | grep -v '\.original$' | head -n 1)" /app/app.war

FROM eclipse-temurin:17-jre
WORKDIR /app

COPY --from=builder /app/app.war /app/app.war

ENV PORT=8080
EXPOSE 8080

CMD ["sh", "-c", "java -Dserver.port=${PORT} -jar /app/app.war"]

