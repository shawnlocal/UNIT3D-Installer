#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NOWARNINGS=yes

# Включваме цветовете (увери се, че пътя е правилен)
source tools/colors.sh

# Почистване на заключени файлове на apt, ако има такива
rm -f /var/lib/dpkg/lock*
rm -f /var/cache/apt/archives/lock
rm -f /var/lib/apt/lists/lock

echo -e "\n\n$Purple Preparing Environment For The Installer ... $Color_Off"
echo "============================================="

# Проверка и настройка на Locale
check_locale() {
    echo -e "\n$Cyan Setting UTF8 Locale ...$Color_Off"
    apt-get -qq update
    apt-get install -qq -y apt-utils language-pack-en-base > /dev/null
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
    echo -e "$IGreen OK $Color_Off"
}

# Добавяне на PPA хранилища
add_ppa() {
    echo -e "\n$Cyan Adding PPA Repositories ... $Color_Off"
    apt-get install -qq -y software-properties-common > /dev/null
    for ppa in "$@"; do
        add-apt-repository -y $ppa > /dev/null 2>&1
        check $? "Adding $ppa Failed!"
    done
    echo -e "$IGreen OK $Color_Off"
}

# Инсталиране на пакети и услуги
add_pkgs() {
    echo -e "\n$Cyan Updating Packages ... $Color_Off"
    apt-get -qq update > /dev/null
    check $? "Updating packages Failed!"
    echo -e "$IGreen OK $Color_Off"

    # PHP 8.4 и всички нужни разширения за UNIT3D v9+
    echo -e "\n$Cyan Installing PHP 8.4 & Extensions ... $Color_Off"
    apt-get -qq install -y curl php-pear php8.4-common php8.4-cli php8.4-fpm \
    php8.4-mysql php8.4-xml php8.4-curl php8.4-mbstring \
    php8.4-zip php8.4-bcmath php8.4-gd php8.4-intl \
    php8.4-readline php8.4-opcache php8.4-igbinary \
    php8.4-redis php8.4-imagick php8.4-sqlite3 php8.4-memcached > /dev/null

    check $? "Installing PHP Failed!"
    echo -e "$IGreen OK $Color_Off"

    # Redis Stack (Официално хранилище за по-нова версия)
    echo -e "\n$Cyan Installing Redis Server ... $Color_Off"
    curl -fsSL https://packages.redis.io/gpg | gpg --yes --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list > /dev/null
    apt-get -qq update > /dev/null
    apt-get -qq install -y redis > /dev/null
    
    systemctl enable --now redis-server > /dev/null
    echo -e "$IGreen OK $Color_Off"

    # Meilisearch (Задължително за търсачката на UNIT3D)
    echo -e "\n$Cyan Installing Meilisearch ... $Color_Off"
    curl -L https://install.meilisearch.com | sh > /dev/null 2>&1
    mv meilisearch /usr/local/bin/
    chmod +x /usr/local/bin/meilisearch

    # Автоматично създаване на Meilisearch Service
    cat <<EOF > /etc/systemd/system/meilisearch.service
[Unit]
Description=Meilisearch
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/meilisearch --master-key=masterKey123 --env=production
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable --now meilisearch > /dev/null
    echo -e "$IGreen OK $Color_Off"

    # Bun (За Vite и JS активите)
    echo -e "\n$Cyan Installing Bun Runtime ... $Color_Off"
    apt-get -qq install -y unzip > /dev/null
    curl -fsSL https://bun.sh/install | bash > /dev/null 2>&1
    # Линкваме го глобално, за да е достъпен за всички
    ln -sf /root/.bun/bin/bun /usr/local/bin/bun
    echo -e "$IGreen OK $Color_Off"

    # Обновяване на всички системни зависимости
    echo -e "\n$Cyan Final System Upgrade ... $Color_Off"
    apt-get -qq upgrade -y > /dev/null
    echo -e "$IGreen OK $Color_Off"
}

# Инсталиране на Composer
install_composer() {
    echo -e "\n$Cyan Installing Composer ... $Color_Off"
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer > /dev/null
    check $? "Installing Composer Failed!"
    echo -e "$IGreen OK $Color_Off"
}

# Инсталиране на библиотеките на самия инсталатор
installer_pkgs() {
    echo -e "\n$Cyan Pulling Installer Dependencies ... $Color_Off"
    # Пускаме го в основната папка на инсталатора
    composer install --no-dev --optimize-autoloader -q
    check $? "Composer Install Failed!"
    echo -e "$IGreen OK $Color_Off"
}

# Помощна функция за проверка на грешки
check() {
    if [ $1 -ne 0 ]; then
        echo -e "$Red Error: $2 \n Please check the logs and try again. $Color_Off"
        exit $1
    fi
}

# ИЗПЪЛНЕНИЕ
check_locale
add_ppa ppa:ondrej/php
add_pkgs
install_composer
installer_pkgs

echo -e "\n$Purple Launching The PHP Installer ... $Color_Off"
echo "============================================="
# Тук извикваме основния PHP файл на инсталатора
php artisan install
