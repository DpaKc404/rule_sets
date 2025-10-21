#!/bin/bash

# Скрипт для записи списка файлов из oldFiles в текстовый файл

# Директории
OLD_FILES_DIR="oldFiles"
OUTPUT_FILE="oldfiles_list.txt"

# Проверка существования директории
if [ ! -d "$OLD_FILES_DIR" ]; then
    echo "Ошибка: Директория $OLD_FILES_DIR не найдена"
    exit 1
fi

# Очистка файла или создание нового
> "$OUTPUT_FILE"

# Запись списка файлов
echo "Записываю список файлов из $OLD_FILES_DIR в $OUTPUT_FILE..."
ls -1 "$OLD_FILES_DIR" > "$OUTPUT_FILE"

# Подсчет количества файлов
FILE_COUNT=$(wc -l < "$OUTPUT_FILE")

echo "Готово! Записано файлов: $FILE_COUNT"
echo "Результат сохранен в: $OUTPUT_FILE"