FROM eclipse-temurin:17-jdk
COPY binaries/*.jar app.jar
ENV SERVER_PORT=8080
ENTRYPOINT ["java", "-jar", "app.jar"]