# --- Этап 1: Сборка ---
# Официальный мультиплатформенный образ Maven с JDK 17
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Копируем pom.xml для кэширования зависимостей
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Копируем исходный код проекта
COPY src ./src
RUN mvn clean package -DskipTests

# --- Этап 2: Запуск ---
# Официальный мультиплатформенный образ JRE 17 (поддерживает и Intel, и Apple Silicon)
FROM eclipse-temurin:17-jre
WORKDIR /app

# Настраиваем безопасность: создаем системного пользователя и группу
RUN groupadd -r spring && useradd -r -g spring spring
USER spring:spring

VOLUME /tmp

# Копируем скомпилированный JAR-файл
COPY --from=build --chown=spring:spring /app/target/*.jar user-service.jar

ENTRYPOINT ["java", "-jar", "user-service.jar"]
