#!/bin/bash

set -e

APPIMAGE_URL="https://github.com/hiddify/hiddify-app/releases/download/v2.5.7/Hiddify-Linux-x64.AppImage"
BASE_URL="https://raw.githubusercontent.com/your-repo/hiddify/main"
TEMP_DIR="/tmp/hiddify_install"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Установка Hiddify..."

# Создаем временную директорию
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Проверяем наличие wget или curl для скачивания
if command -v wget >/dev/null 2>&1; then
  DOWNLOAD_CMD="wget -q -O"
elif command -v curl >/dev/null 2>&1; then
  DOWNLOAD_CMD="curl -s -L -o"
else
  echo "Ошибка: не найден wget или curl для скачивания файлов"
  echo "Пожалуйста, установите один из них:"
  echo "  Ubuntu/Debian: sudo apt-get install wget"
  echo "  CentOS/RHEL:   sudo yum install wget"
  echo "  Fedora:        sudo dnf install wget"
  exit 1
fi

# Скачиваем AppImage
echo "Скачивание Hiddify AppImage..."
$DOWNLOAD_CMD "Hiddify-Linux-x64.AppImage" "$APPIMAGE_URL"

# Скачиваем дополнительные файлы если запускаем не из локального репозитория
if [ ! -f "$SCRIPT_DIR/hiddify-run" ]; then
  echo "Скачивание дополнительных файлов..."
  $DOWNLOAD_CMD "hiddify-run" "$BASE_URL/hiddify-run"
  $DOWNLOAD_CMD "hiddify.desktop" "$BASE_URL/hiddify.desktop"
  $DOWNLOAD_CMD "hiddify.png" "$BASE_URL/hiddify.png"
  chmod +x "hiddify-run"
  SCRIPT_DIR="$TEMP_DIR"
fi

# Делаем файл исполняемым
chmod +x "Hiddify-Linux-x64.AppImage"

# Копируем в /usr/bin как hiddify (требуются права sudo)
echo "Установка в систему (требуются права администратора)..."
sudo cp "Hiddify-Linux-x64.AppImage" "/usr/bin/hiddify"

# Копируем hiddify-run в /usr/bin
if [ -f "$SCRIPT_DIR/hiddify-run" ]; then
  sudo cp "$SCRIPT_DIR/hiddify-run" "/usr/bin/"
  sudo chmod +x "/usr/bin/hiddify-run"
  echo "hiddify-run установлен в /usr/bin/"
else
  echo "Внимание: файл hiddify-run не найден в $SCRIPT_DIR"
fi

# Создаем директорию для applications если не существует
mkdir -p "$HOME/.local/share/applications"

# Копируем .desktop файл
if [ -f "$SCRIPT_DIR/hiddify.desktop" ]; then
  cp "$SCRIPT_DIR/hiddify.desktop" "$HOME/.local/share/applications/"
  echo "Файл .desktop установлен"
else
  echo "Внимание: файл hiddify.desktop не найден в $SCRIPT_DIR"
fi

# Создаем директорию для иконок если не существует
sudo mkdir -p "/usr/share/icons/hicolor/128x128/apps"

# Копируем иконку
if [ -f "$SCRIPT_DIR/hiddify.png" ]; then
  sudo cp "$SCRIPT_DIR/hiddify.png" "/usr/share/icons/hicolor/128x128/apps/"
  echo "Иконка установлена"
else
  echo "Внимание: иконка hiddify.png не найдена в $SCRIPT_DIR"
fi

# Обновляем кэш иконок
sudo gtk-update-icon-cache /usr/share/icons/hicolor/ 2>/dev/null || true

# Обновляем базу данных desktop файлов
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

# Очищаем временные файлы
rm -rf "$TEMP_DIR"

echo "Установка Hiddify завершена успешно!"
echo "Приложение можно запустить из меню приложений или командой 'hiddify-run'"
