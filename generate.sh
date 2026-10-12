#!/bin/bash

# Цвета для вывода сообщений
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Проверка наличия Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Homebrew не установлен. Устанавливаем Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Ошибка установки Homebrew. Установите его вручную: https://brew.sh${NC}"
        exit 1
    fi
    echo -e "${GREEN}Homebrew успешно установлен.${NC}"
fi

# Проверка наличия XcodeGen
if ! command -v xcodegen &> /dev/null; then
    echo -e "${RED}XcodeGen не установлен. Устанавливаем через Homebrew...${NC}"
    brew install xcodegen
    if [ $? -ne 0 ]; then
        echo -e "${RED}Ошибка установки XcodeGen. Проверьте Homebrew и попробуйте снова.${NC}"
        exit 1
    fi
    echo -e "${GREEN}XcodeGen успешно установлен.${NC}"
fi

# Удаление старого проекта
echo "Удаляем старый проект Multithreading-iOS-Case.xcodeproj..."
rm -rf Multithreading-iOS-Case.xcodeproj

# Генерация нового проекта
echo "Генерируем проект с помощью XcodeGen..."
xcodegen
if [ $? -ne 0 ]; then
    echo -e "${RED}Ошибка генерации проекта. Проверьте project.yml и зависимости.${NC}"
    exit 1
fi

# Открытие проекта
echo "Открываем проект Multithreading-iOS-Case.xcodeproj..."
open Multithreading-iOS-Case.xcodeproj

echo -e "${GREEN}Процесс завершён успешно!${NC}"