#!/bin/bash

clear

# Banner
echo -e "\e[36m"
echo "██████╗  █████╗ ██╗  ██╗███╗   ███╗██╗██████╗ ██╗██╗███╗   ██╗"
echo "██╔══██╗██╔══██╗██║  ██║████╗ ████║██║██╔══██╗██║██║████╗  ██║"
echo "██████╔╝███████║███████║██╔████╔██║██║██║  ██║██║██║██╔██╗ ██║"
echo "██╔══██╗██╔══██║██╔══██║██║╚██╔╝██║██║██║  ██║██║██║██║╚██╗██║"
echo "██║  ██║██║  ██║██║  ██║██║ ╚═╝ ██║██║██████╔╝██║██║██║ ╚████║"
echo "╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═════╝ ╚═╝╚═╝╚═╝  ╚═══╝"
echo -e "\e[0m"

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
    echo "✅ Pterodactyl panel o'rnatilmoqda..."
    
    # Docker o‘rnatish
    apt update
    apt install -y docker.io docker-compose

    systemctl start docker
    systemctl enable docker

    # Papka yaratish
    mkdir -p /root/pterodactyl
    cd /root/pterodactyl

    # Sening docker-compose yuklash
    curl -o docker-compose.yml https://raw.githubusercontent.com/GHostMCuzb/Panel/refs/heads/main/docker-compose.yml

    # Run
    docker-compose up -d

    echo "------------------------------------"
    echo "Admin panel yaratmoqchimisiz? (ha | yoq)"
    read create_admin

    if [[ "$create_admin" == "ha" ]]; then
        docker exec -it $(docker ps -qf "name=panel") php artisan p:user:make
    else
        echo "⏭ Oddiy user yaratilmoqda..."
        docker exec -it $(docker ps -qf "name=panel") php artisan p:user:make
    fi

    echo "🎉 Tayyor!"
    
elif [[ "$choice" == "B" || "$choice" == "b" ]]; then
    echo "⏳ Wings hali qo‘shilmagan"

elif [[ "$choice" == "C" || "$choice" == "c" ]]; then
    echo "Chiqildi."
    exit

else
    echo "❌ Noto‘g‘ri tanlov"
fi
