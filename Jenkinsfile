pipeline {
  agent any
  options { timestamps() }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Dotnet Test') {
      steps {
        sh '''
          set -e
          dotnet --info
          dotnet restore
          dotnet test -c Release
        '''
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          set -e
          docker build -t webapp:latest .
          docker images | grep webapp || true
        '''
      }
    }

    stage('Deploy (docker-compose)') {
      steps {
        withEnv(['HOST_PORT=8081']) { // İstersen 18081 vb. ver
          sh '''
            set -e

            # 1) HOST_PORT'u kullanan başka container varsa durdur/temizle (farklı compose projelerinden olabilir)
            CONFLICT=$(docker ps --format '{{.ID}} {{.Ports}}' | grep -E "0\\.0\\.0\\.0:${HOST_PORT}|:::${HOST_PORT}" | awk '{print $1}' || true)
            if [ -n "$CONFLICT" ]; then
              echo "Stopping container(s) using :${HOST_PORT} -> $CONFLICT"
              docker stop $CONFLICT || true
              docker rm $CONFLICT || true
            fi

            # 2) Bu projenin compose kaynaklarını temizle ve yeniden ayağa kaldır
            docker compose -f docker-compose.prod.yml down --remove-orphans || true
            docker compose -f docker-compose.prod.yml up -d --force-recreate

            # 3) Health check
            sleep 3
            curl -fsS "http://localhost:${HOST_PORT}/weatherforecast" | head -c 400
          '''
        }
      }
    }
  }

  post {
    success { echo '✅ CI/CD tamam: testler OK, imaj build edildi, ${HOST_PORT}’te çalışıyor.' }
    failure { echo '❌ Pipeline hata verdi. Console logdan hangi aşamada durduğunu kontrol et.' }
  }
}
