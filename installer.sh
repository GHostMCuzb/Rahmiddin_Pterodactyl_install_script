#!/bin/bash

# Ranglar
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
echo "RAHMIDDIN VPS - AUTO INSTALLER"
echo "=============================="

# 1. Codespaces URLni aniqlash
# Codespaces portni avtomatik 'public' qilishi uchun linkni to'g'ri yasash kerak
if [[ "$CODESPACE_NAME" != "" ]]; then
    AUTO_URL="https://${CODESPACE_NAME}-8030.app.github.dev"
else
    AUTO_URL="http://localhost:8030"
fi

echo -e "${YELLOW}🔄 Tizim yangilanmoqda va Docker o'rnatilmoqda...${RESET}"
apt update -y && apt install -y docker.io docker-compose > /dev/null 2>&1

# 2. Papka va Konfiguratsiya
mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl

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

# 3. Portni avtomatik ochish buyrug'i (Codespaces uchun)
if [[ "$CODESPACE_NAME" != "" ]]; then
    gh browse -p 8030 > /dev/null 2>&1
fi

echo -e "${YELLOW}🚀 Konteynerlar ishga tushmoqda...${RESET}"
docker-compose up -d > /dev/null 2>&1

echo -e "${YELLOW}🛠 Login xatoliklari tuzatilmoqda (20 soniya kuting)...${RESET}"
sleep 20

# 4. Login xatosini (Unexpected Error) yo'qotish buyruqlari
docker exec -i panel php artisan key:generate --force > /dev/null 2>&1
docker exec -i panel php artisan config:clear > /dev/null 2>&1
docker exec -i panel php artisan cache:clear > /dev/null 2>&1

echo -e "${GREEN}✅ Panel o'rnatildi!${RESET}"
echo -e "${CYAN}👤 ENDI ADMIN USER MA'LUMOTLARINI KIRITING:${RESET}"
echo "------------------------------------"

# Srazu user yaratish bo'limiga o'tadi
docker exec -it panel php artisan p:user:make

echo "------------------------------------"
echo -e "${GREEN}🎉 TAYYOR!${RESET}"
echo -e "1. Pastdagi 'PORTS' bo'limiga o'ting."
echo -e "2. 8030 portini o'ng tugma bilan bosib 'Port Visibility -> Public' qiling."
echo -e "3. Mana bu linkka kiring: ${CYAN}$AUTO_URL${RESET}"
