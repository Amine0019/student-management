#--------------------------------------
# STAGE 1: COMPILATION (Maven Build)
#--------------------------------------
FROM maven:3.9.5-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
# Cette étape crée le fichier .jar dans /app/target/
RUN mvn clean package -DskipTests

#--------------------------------------
# STAGE 2: EXÉCUTION (Image Légère)
#--------------------------------------
FROM eclipse-temurin:17-jre-alpine

# Définissez le nom exact de votre JAR ici
ARG JAR_FILE=student-management-0.0.1-SNAPSHOT.jar 
# Si le nom est différent, changez-le !

# Exposer le port de votre application (généralement 8080 pour Spring Boot)
EXPOSE 8080

# Copiez l'artefact (le JAR) depuis l'étape de 'build'
COPY --from=build /app/target/${JAR_FILE} /app.jar

# Démarrez l'application
ENTRYPOINT ["java", "-jar", "/app.jar"]
