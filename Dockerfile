FROM openjdk:11
ADD target/bioMedical*.jar app.jar
EXPOSE 8082 8000
ENTRYPOINT ["java","-jar","app.jar"]
