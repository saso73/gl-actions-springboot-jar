# ---------- Build stage ----------
FROM eclipse-temurin:21 as build
WORKDIR /workspace

# Copy only build descriptors first to cache deps
COPY pom.xml ./
COPY .mvn .mvn
COPY mvnw ./

# Pre-fetch dependencies (fast rebuilds)
RUN ./mvnw -q -DskipTests dependency:go-offline

# Now copy source (this invalidates cache when code changes)
COPY src ./src

# Build the jar
RUN ./mvnw -q -DskipTests package

# ---------- Runtime stage ----------
FROM eclipse-temurin:21-jre
WORKDIR /app

# Copy the Spring Boot runnable jar (exclude original-*.jar)
COPY --from=build /workspace/target/*.jar /app/
RUN rm -f /app/original-*.jar && mv /app/*.jar /app/app.jar

EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]

