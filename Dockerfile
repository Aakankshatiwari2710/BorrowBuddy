# Stage 1: Build the Maven project
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app
# Copy the pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B
# Copy the source code and build the war
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Create the Tomcat runtime container
FROM tomcat:9.0-jdk17
# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*
# Copy the built WAR file to ROOT.war so it serves at the root level (/)
COPY --from=builder /app/target/ROOT.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
