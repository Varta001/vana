#!/bin/bash

# Обновление и апгрейд системы
sudo apt update -y && sudo apt upgrade -y

# Удаление существующих пакетов Docker
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do 
    sudo apt-get remove $pkg; 
done

# Установка необходимых пакетов
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# Настройка официального GPG ключа и репозитория Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Обновление индекса пакетов и установка Docker
sudo apt update -y && sudo apt upgrade -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Убедитесь, что docker-compose исполняемый
sudo chmod +x /usr/local/bin/docker-compose

# Проверка версии Docker
docker --version 

# Создание директории для проекта
mkdir sixgpt && cd sixgpt

# Запрос у пользователя приватного ключа и установка переменных окружения
read -p "Введите ваш VANA_PRIVATE_KEY: " VANA_PRIVATE_KEY
export VANA_PRIVATE_KEY=$VANA_PRIVATE_KEY
export VANA_NETWORK=mokhsa

# Создание файла docker-compose.yml с необходимой конфигурацией
cat <<EOF > docker-compose.yml
version: '3.8'

services:
  ollama:
    image: ollama/ollama:0.3.12
    ports:
      - "11435:11434"
    volumes:
      - ollama:/root/.ollama
    restart: unless-stopped
 
  sixgpt3:
    image: sixgpt/miner:latest
    ports:
      - "3015:3000"
    depends_on:
      - ollama
    environment:
      - VANA_PRIVATE_KEY=\${VANA_PRIVATE_KEY}
      - VANA_NETWORK=\${VANA_NETWORK}
    restart: always

volumes:
  ollama:
EOF

# Запуск контейнеров Docker в фоновом режиме
docker compose up -d

echo "Настройка завершена! Майнер теперь запущен."
