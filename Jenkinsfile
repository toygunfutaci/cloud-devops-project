pipeline {
  agent any
  options { timestamps() }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Dotnet Test') {
      steps {
        sh '
          set -e
          dotnet --info
          dotnet restore
          dotnet test --configuration Release
        '
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '
          set -e
          docker build -t webapp:latest .
          docker images | grep webapp
        '
      }
    }

    stage('Deploy (docker-compose)' ) {
      steps {
        sh '
          set -e
          docker compose -f docker-compose.prod.yml down || true
          docker compose -f docker-compose.prod.yml up -d
          sleep 2
          curl -fsS http://localhost:8081/weatherforecast | head -c 400
        '
      }
    }
  }

  post {
    success { echo '✅ CI/CD tamam: testler OK, imaj build edildi, 8081’de çalışıyor.' }
    failure { echo '❌ Pipeline hata verdi. Console logdan hangi aşamada durduğunu kontrol et.' }
  }
}
