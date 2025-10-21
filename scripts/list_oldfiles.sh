#!/bin/bash

# Скрипт для обновления списка требуемых .srs файлов
# Использовать если нужно обновить filelist.txt

OUTPUT_FILE="filelist.txt"

# Очистка файла или создание нового
> "$OUTPUT_FILE"

# Запись списка файлов (все .srs в текущей директории)
echo "Генерирую список .srs файлов в $OUTPUT_FILE..."
ls -1 *.srs 2>/dev/null > "$OUTPUT_FILE" || echo "Нет .srs файлов"

# Подсчет количества файлов
FILE_COUNT=$(wc -l < "$OUTPUT_FILE")

echo "Готово! Записано файлов: $FILE_COUNT"
echo "Результат сохранен в: $OUTPUT_FILE"