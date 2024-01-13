
pipeline {
    triggers {
  pollSCM('* * * * *')
    }
   agent any
    tools {
  maven 'M2_HOME'
  }

   environment {
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "ec2-54-167-81-5.compute-1.amazonaws.com:8081"
        NEXUS_REPOSITORY = "geo"
        NEXUS_CREDENTIAL_ID = "nexus-userID"
    }

    stages {

        stage("build & SonarQube analysis") {          
            steps {
                    withSonarQubeEnv('sonar') {
                        sh 'mvn verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar -Dsonar.projectKey=kserge2001_geo'
                    }
             
            }
        }

        stage('Check Quality Gate') {
            steps {
                echo 'Checking quality gate...'
                    script {
                    timeout(time: 20, unit: 'MINUTES') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline stopped because of quality gate status: ${qg.status}"
                            } 
                        }
                    }
               
            }
        }

         stage("Maven Build Back-End") {
            steps {
                echo 'Build Back-End Project...'
                    script {
                    sh "mvn package -DskipTests=true"
                    }
             
            }
        }

         stage("Publish to Nexus Repository Manager") {
            steps {
                echo 'Publish to Nexus Repository Manager...'
                    script {
                    pom = readMavenPom file: "pom.xml";
                    filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    artifactPath = filesByGlob[0].path;
                    artifactExists = fileExists artifactPath;
                    if(artifactExists) {
                        echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";
                        nexusArtifactUploader(
                            nexusVersion: NEXUS_VERSION,
                            protocol: NEXUS_PROTOCOL,
                            nexusUrl: NEXUS_URL,
                            groupId: pom.groupId,
                            version: pom.version,
                            repository: NEXUS_REPOSITORY,
                            credentialsId: NEXUS_CREDENTIAL_ID,
                            artifacts: [
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: artifactPath,
                                type: pom.packaging],
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: "pom.xml",
                                type: "pom"]
                            ]
                        );
                        } else {
                        error "*** File: ${artifactPath}, could not be found";
                        }
                    }
                
            }
        }
    }
}