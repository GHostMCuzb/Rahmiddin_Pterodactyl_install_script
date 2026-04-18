#!/bin/bash

# Ranglar
CYAN='\e[36m'
GREEN='\e[32m'
RED='\e[31m'
YELLOW='\e[33m'
RESET='\e[0m'

clear

# Root huquqini tekshirish
if [ "$EUID" -ne 0 ]; then 
  echo -e "${RED}Xato: Iltimos, scriptni sudo bilan ishga tushiring!${RESET}"
  exit 1
fi

# Banner
echo -e "${CYAN}"
echo "██████╗  █████╗ ██╗  ██╗███╗   ███╗██╗██████╗ ██╗██╗███╗   ██╗"
echo "██╔══██╗██╔══██╗██║  ██║████╗ ████║██║██╔══██╗██║██║████╗  ██║"
echo "██████╔╝███████║███████║██╔████╔██║██║██║  ██║██║██║██╔██╗ ██║"
echo "██╔══██╗██╔══██║██╔══██║██║╚██╔╝██║██║██║  ██║██║██║██║╚██╗██║"
echo "██║  ██║██║  ██║██║  ██║██║ ╚═╝ ██║██║██████╔╝██║██║██║ ╚████║"
echo "╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═════╝ ╚═╝╚═╝╚═╝  ╚═══╝"
echo -e "${RESET}"

echo "RAHMIDDIN VPS - Avtomatik O'rnatuvchi"
echo "------------------------------------"
echo "A : Pterodactyl Panel O'rnatish"
echo "B : Wings O'rnatish (Yaqinda)"
echo "C : Chiqish"
echo "------------------------------------"

read -p "Tanlovni kiriting (A/B/C): " choice

case $choice in
    [Aa])
        echo -e "${YELLOW}🔄 Tizim yangilanmoqda...${RESET}"
        apt-get update -y && apt-get upgrade -y

        echo -e "${YELLOW}🐳 Docker o'rnatilmoqda...${RESET}"
        # Docker va kerakli paketlarni o'rnatish (Xatolarsiz usul)
        apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y
        apt-get update -y
        apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

        # Docker-ni ishga tushirish
        systemctl enable --now docker

        # Papka yaratish (Root yoki User papkasida)
        mkdir -p /var/www/pterodactyl
        cd /var/www/pterodactyl

        echo -e "${YELLOW}📥 Docker-compose fayli yuklanmoqda...${RESET}"
        curl -o docker-compose.yml https://raw.githubusercontent.com/GHostMCuzb/Panel/refs/heads/main/docker-compose.yml

        # Docker-compose up (v2 formatida: 'docker compose')
        echo -e "${YELLOW}🚀 Konteynerlar ishga tushmoqda...${RESET}"
        docker compose up -d

        echo -e "${GREEN}------------------------------------"
        echo "Konteynerlar tayyor!"
        echo "------------------------------------${RESET}"

        # Bir oz kutish (Baza tayyor bo'lishi uchun)
        echo "Baza yuklanishini 10 soniya kutamiz..."
        sleep 10

        echo -e "${CYAN}👤 Admin yaratish jarayoni boshlanmoqda...${RESET}"
        # Konteyner nomini avtomatik aniqlash va foydalanuvchi yaratish
        docker exec -it $(docker ps -qf "name=panel") php artisan p:user:make

        echo -e "${GREEN}🎉 Pterodactyl muvaffaqiyatli o'rnatildi!${RESET}"
        ;;
    [Bb])
        echo -e "${YELLOW}⏳ Wings funksiyasi ustida ish ketmoqda...${RESET}"
        ;;
    [Cc])
        echo "Xayr!"
        exit 0
        ;;
    *)
        echo -e "${RED}❌ Noto'g'ri tanlov!${RESET}"
        ;;
esac
