pipeline {
  agent any
  options { timestamps(); ansiColor('xterm') }

  environment {
    IMAGE_NAME  = "webapp"
    REPORTS_DIR = "reports"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        script {
          sh "mkdir -p ${REPORTS_DIR}"
          env.GIT_SHA = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
          env.VERSION = "${env.BUILD_NUMBER}-${env.GIT_SHA}"
          echo "Version = ${env.VERSION}"
        }
      }
    }

    stage('Unit Tests') {
      steps {
        sh '''
          docker run --rm -v "$PWD":/workspace -w /workspace \
            mcr.microsoft.com/dotnet/sdk:8.0 \
            bash -lc "dotnet restore && dotnet test tests/UnitTests/UnitTests.csproj \
              --logger \\"trx;LogFileName=TestResults.trx\\" \
              --results-directory ${REPORTS_DIR}/unit || true"
        '''
      }
      post {
        always { archiveArtifacts artifacts: 'reports/unit/**/*.trx', allowEmptyArchive: true }
      }
    }

    stage('Integration Tests') {
      steps {
        sh '''
          docker run --rm -v "$PWD":/workspace -w /workspace \
            mcr.microsoft.com/dotnet/sdk:8.0 \
            bash -lc "dotnet test tests/IntegrationTests/IntegrationTests.csproj \
              --logger \\"trx;LogFileName=TestResults.trx\\" \
              --results-directory ${REPORTS_DIR}/integration || true"
        '''
      }
      post {
        always { archiveArtifacts artifacts: 'reports/integration/**/*.trx', allowEmptyArchive: true }
      }
    }

    stage('Build Image') {
      steps {
        sh 'docker build -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest .'
      }
    }

    stage('Deploy (local)') {
      when {
        anyOf { branch 'master'; branch 'main' }  // support either default branch
      }
      steps {
        sh '''
          export VERSION=${VERSION}
          docker compose -f docker-compose.prod.yml up -d --force-recreate
          docker image prune -f
        '''
      }
    }
  }

  post {
    always { cleanWs() }
  }
}
