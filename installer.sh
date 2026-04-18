#!/bin/bash

# Ranglar uchun
CYAN='\e[36m'
GREEN='\e[32m'
YELLOW='\e[33m'
RESET='\e[0m'

clear

# Banner
echo -e "${CYAN}"
echo "██████╗  █████╗ ██╗  ██╗███╗   ███╗██╗██████╗ ██╗██╗███╗   ██╗"
echo "██╔══██╗██╔══██╗██║  ██║████╗ ████║██║██╔══██╗██║██║████╗  ██║"
echo "██████╔╝███████║███████║██╔████╔██║██║██║  ██║██║██║██╔██╗ ██║"
echo "██╔══██╗██╔══██║██╔══██║██║╚██╔╝██║██║██║  ██║██║██║██║╚██╗██║"
echo "██║  ██║██║  ██║██║  ██║██║ ╚═╝ ██║██║██████╔╝██║██║██║ ╚████║"
echo "╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═════╝ ╚═╝╚═╝╚═╝  ╚═══╝"
echo -e "${RESET}"

echo "RAHMIDDIN VPS"
echo ""
echo "========================"
echo "A : Pterodactyl panel o'rnatish"
echo "B : Wings o'rnatish (hozircha ishlamaydi)"
echo "C : Exit"
echo "========================"
echo ""

read -p "Tanlang (A/B/C): " choice

if [[ "$choice" == "A" || "$choice" == "a" ]]; then
    echo -e "${YELLOW}✅ Pterodactyl panel o'rnatilmoqda...${RESET}"
    
    # Root huquqini tekshirish
    if [ "$EUID" -ne 0 ]; then 
      echo "Iltimos, scriptni sudo bilan ishga tushiring!"
      exit 1
    fi

    # Docker o'rnatish
    apt update -y
    apt install -y docker.io docker-compose
    systemctl start docker
    systemctl enable docker

    # Papka yaratish
    mkdir -p /var/www/pterodactyl
    cd /var/www/pterodactyl

    # Codespaces URLni aniqlash
    AUTO_URL="https://${CODESPACE_NAME}-8030.app.github.dev"

    # Docker-compose faylini yaratish (Siz xohlagan kod)
    cat <<EOF > docker-compose.yml
version: '3.8'

services:
  database:
    image: mariadb:10.5
    restart: always
    command: --default-authentication-plugin=mysql_native_password
    volumes:
      - "./data/database:/var/lib/mysql"
    environment:
      MYSQL_DATABASE: "panel"
      MYSQL_USER: "pterodactyl"
      MYSQL_PASSWORD: "YourSecurePassword"
      MYSQL_ROOT_PASSWORD: "YourRootPassword"

  cache:
    image: redis:alpine
    restart: always

  panel:
    image: ghcr.io/pterodactyl/panel:latest
    restart: always
    ports:
      - "8030:80"
    links:
      - database
      - cache
    volumes:
      - "./data/var:/app/var"
      - "./data/nginx:/etc/nginx/http.d"
      - "./data/logs:/app/storage/logs"
    environment:
      APP_URL: "$AUTO_URL"
      APP_TIMEZONE: "UTC"
      APP_ENV: "production"
      APP_ENVIRONMENT_ONLY: "false"
      CACHE_DRIVER: "redis"
      SESSION_DRIVER: "redis"
      QUEUE_DRIVER: "redis"
      REDIS_HOST: "cache"
      DB_HOST: "database"
      DB_PORT: "3306"
      DB_DATABASE: "panel"
      DB_USERNAME: "pterodactyl"
      DB_PASSWORD: "YourSecurePassword"
      TRUSTED_PROXIES: "*"
EOF

    # Ishga tushirish
    docker-compose up -d

    echo -e "${YELLOW}⏳ Tizim sozlanmoqda (20 soniya kuting)...${RESET}"
    sleep 20

    # Login Error (Unexpected Error) ni tuzatish uchun muhim qism
    docker exec -i panel php artisan key:generate --force
    docker exec -i panel php artisan config:clear
    docker exec -i panel php artisan cache:clear

    echo "------------------------------------"
    echo -e "${GREEN}Admin panel yaratishni boshlaymiz:${RESET}"
    docker exec -it panel php artisan p:user:make

    echo -e "${GREEN}🎉 Tayyor! Link: $AUTO_URL${RESET}"
    
elif [[ "$choice" == "B" || "$choice" == "b" ]]; then
    echo "⏳ Wings hali qo'shilmagan"

elif [[ "$choice" == "C" || "$choice" == "c" ]]; then
    echo "Chiqildi."
    exit
else
    echo "❌ Noto'g'ri tanlov"
fi
