pipeline {
    agent any
    tools{
        maven 'M2_HOME'
    }
    environment {
    registry = '076892551558.dkr.ecr.us-east-1.amazonaws.com/jenkins'
    registryCredential = 'awscredID'
    dockerimage = ''
  }
    stages {
        stage('Checkout'){
            steps{
                git branch: 'main', 
                url: 'https://github.com/kserge2001/geo.git'
            }
        }
        stage('sona scan'){
            steps{
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
        
        stage('Code Build') {
            steps {
                sh 'mvn clean install package'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        stage('Build Image') {
            steps {
                script{
                    dockerImage = docker.build registry + ":$BUILD_NUMBER"
                } 
            }
        }
        stage('Deploy image') {
            steps{
                script{ 
                    docker.withRegistry("https://"+registry,"ecr:us-east-1:"+registryCredential) {
                        dockerImage.push()
                    }
                }
            }
        }  
    }
}