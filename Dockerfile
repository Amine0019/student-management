# Backend Dockerfile
FROM eclipse-temurin:17-jdk

WORKDIR /app

# Copier le jar compilé
COPY target/student-management-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8089

ENTRYPOINT ["java","-jar","app.jar"]
