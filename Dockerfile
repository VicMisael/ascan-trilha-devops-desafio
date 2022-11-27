FROM maven:3.8-jdk-11 AS build
WORKDIR /usr/src/app/
COPY pom.xml ./pom.xml
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn package
EXPOSE 8080
ENTRYPOINT ["java","-jar","/usr/src/app/target/helloworld-0.0.1-SNAPSHOT.jar"]
