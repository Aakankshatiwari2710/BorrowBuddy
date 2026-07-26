# Production Tomcat Container for SpanV Studios
FROM tomcat:9.0-jdk17-temurin

# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy packaged ROOT.war to Tomcat webapps directory
COPY ROOT.war /usr/local/tomcat/webapps/ROOT.war

# Expose HTTP Port
EXPOSE 8080

# Run Tomcat Catalina Server
CMD ["catalina.sh", "run"]
