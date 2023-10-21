#!/bin/bash
## Local and Remote repo creating script for github ##
# Скрипт создает локальный, а затем и его удаленный аналог на гитхабе в качестве имени использует имя текущей директории
# Данный скрипт принимает на вход название удаленного репозитория, который хотим создать на https://github
# При условии, что мы создали токен (PAT) и политика разрешает использование удаленного доступа по API
# если несколько пользователей зарегестрированно в git-credentials, 
# то на вход скрипта подаем два значениz: reponame, username 
# Алгоритм
# 1. Скрипт инизиализирует локальный репозиторий в текущей папке
# 2. Переназначает главную ветку локальной репы на main (по умолчанию для гитхаба)
# 3. Добавляет все файлы в локальный индекс
# 4. Коммитит
# 5. Создает удаленный
# 6. Пушит локальный на удаленный

REPONAME=$(basename "$PWD")

if [ "$1" == "-help" ] || [ "$1" == "help" ] || [ "$1" == "-h" ]|| [ "$1" == "h" ]; then
    echo "Формат ввода: create.sh [username]"
    exit 1;
fi

if [ $# -ge 1 ]; then
    USERNAME=$1
    PAT=$(cat ~/.git-credentials | grep "$USERNAME" | awk -F":" '{ print $3}' | sed 's/@github.com//')
else
    PAT=$(cat ~/.git-credentials | awk -F":" '{ print $3}' | sed 's/@github.com//')
    USERNAME=$(cat ~/.git-credentials | awk -F":" '{ print $2}' | sed  's/\///g')
fi

curl -L -H "Authorization: Bearer $PAT" \
-H "Accept: application/vnd.github+json" \
-H "X-GitHub-Api-Version: 2022-11-28" \
-d "{\"name\":\"$REPONAME\",\"private\":false}" \
https://api.github.com/user/repos 

git init
git branch -M main
git add .
git commit -m "First init"
git remote add origin https://github.com/$USERNAME/$REPONAME.git
git push -u origin main

