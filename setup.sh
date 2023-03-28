#!/bin/bash

set -e

RemoveContainer () {
    lastResult=$?
    if [ $lastResult -ne 0 ] && [ $lastResult -ne 130 ]
    then
        echo $lastResult
        echo "\033[0;101m安裝過程有錯誤，移除所有容器\e[0m"
        docker-compose down
    fi
}
trap RemoveContainer EXIT

# 取得資料夾名稱，因資料夾名稱是容器名稱的 prefix
dir=$(pwd)
fullPath="${dir%/}";
containerNamePrefix=${fullPath##*/}

echo "\033[46m現在位置 - ${containerNamePrefix}\e[0m \n"

# Copy config files
cp env-sample .env && cp docker-compose.yml.sample docker-compose.yml
cp .docker/nginx/default.conf.dist .docker/nginx/default.conf

# 讀取「.env」
. ${dir}/.env

# Copy php config files
# cp web/config/autoload/upgrade.local.php.dist web/config/autoload/upgrade.local.php
cp web/config/autoload/development.local.php.dist web/config/autoload/development.local.php
cp web/config/autoload/doctrine.local.php.dist web/config/autoload/doctrine.local.php
cp web/config/autoload/local.php.dist web/config/autoload/local.php
cp web/config/autoload/module.doctrine-mongo-odm.local.php.dist web/config/autoload/module.doctrine-mongo-odm.local.php
cp web/config/autoload/memcached.local.php.dist web/config/autoload/memcached.local.php
cp web/config/autoload/hybridauth.local.php.dist web/config/autoload/hybridauth.local.php
cp web/config/autoload/pay.local.php.dist web/config/autoload/pay.local.php
echo "\033[43m複製 Config 檔案...成功\e[0m \n"

# Start container
docker-compose up -d --build && echo "\e[1;42m啟動容器...成功\e[0m"

# 第一次安裝
InstallDB () {    
    if [ "$1" != '-nodb' ] && [ "$1" != '--nodb' ];
    then
        # Install php packages
        docker exec -it ${containerNamePrefix}_php_1 composer install && echo "\e[1;42m安裝 php 相關套件... 成功\e[0m"

        # Cache disabled
        docker exec -it ${containerNamePrefix}_php_1 composer development-enable && echo "\e[1;42m取消 Cache 功能... 成功\e[0m"

        # Change permission
        sudo chmod 777 -R ./web/data

        # Start container
        docker-compose down && echo "\e[1;42m停止容器...成功\e[0m"
        docker-compose up -d --build && echo "\e[1;42m啟動容器...成功\e[0m"
        docker exec -it ${containerNamePrefix}_php_1 bin/cli.sh base:install && echo "\e[1;42m安裝 DB... 成功\e[0m"
    fi
}

# Update php packages
docker exec -it ${containerNamePrefix}_php_1 composer update && echo "\e[1;42m安裝 php 相關套件... 成功\e[0m"

# 安裝 DB (如果沒有傳參數 -nodb，就執行安裝 DB)
InstallDB "$@"

# Start develop
echo "\033[43m啟動開發環境\e[0m \n"