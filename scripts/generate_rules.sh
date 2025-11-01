#!/bin/bash
set -e -o pipefail

# Скрипт для генерации .srs файлов из .dat источников
# Аналог h.cmd для Linux

echo "=== Starting rule generation ==="

# Определяем путь к корню проекта
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
WORK_DIR="$PROJECT_ROOT/temp_build"
GEODAT2SRS="$PROJECT_ROOT/geodat2srs"

# Проверяем наличие geodat2srs
if [ ! -f "$GEODAT2SRS" ]; then
    echo "Error: geodat2srs not found at $GEODAT2SRS"
    echo "Please build it first: cd src && go build -o ../geodat2srs"
    exit 1
fi

# Создаем рабочую директорию
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo ""
echo "=== Downloading .dat files ==="
echo ""

# --- Download files ---

# AntiFilter
echo "Downloading AntiFilter..."
mkdir -p AntiFilter
curl -L -o AntiFilter/geosite.dat https://github.com/Skrill0/AntiFilter-Domains/releases/latest/download/geosite.dat
curl -L -o AntiFilter/geoip.dat https://github.com/Skrill0/AntiFilter-IP/releases/latest/download/geoip.dat

# V2Fly
echo "Downloading V2Fly..."
mkdir -p V2Fly
curl -L -o V2Fly/dlc.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat
curl -L -o V2Fly/geoip.dat https://github.com/loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat

# Zkeen
echo "Downloading Zkeen..."
mkdir -p Zkeen
curl -L -o Zkeen/zkeen.dat https://github.com/jameszeroX/zkeen-domains/releases/latest/download/zkeen.dat
curl -L -o Zkeen/zkeenip.dat https://github.com/jameszeroX/zkeen-ip/releases/latest/download/zkeenip.dat

# MetaCubeX
echo "Downloading MetaCubeX..."
mkdir -p MetaCubeX
curl -L -o MetaCubeX/geoip.dat https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat

echo ""
echo "=== Converting .dat to .srs ==="
echo ""

# --- Unpack files ---

# AntiFilter
echo "Processing AntiFilter..."
$GEODAT2SRS geosite -i AntiFilter/geosite.dat -o "GeoSite AntiFilter" --prefix "geosite-"
$GEODAT2SRS geoip -i AntiFilter/geoip.dat -o "GeoIP AntiFilter" --prefix "geoip-"

# V2Fly
echo "Processing V2Fly..."
$GEODAT2SRS geosite -i V2Fly/dlc.dat -o "GeoSite V2Fly" --prefix "geosite-"
$GEODAT2SRS geoip -i V2Fly/geoip.dat -o "GeoIP V2Fly" --prefix "geoip-"

# Zkeen
echo "Processing Zkeen..."
$GEODAT2SRS geosite -i Zkeen/zkeen.dat -o "GeoSite Zkeen" --prefix "geosite-"
$GEODAT2SRS geoip -i Zkeen/zkeenip.dat -o "GeoIP ZkeenIP" --prefix "geoip-"

# MetaCubeX
echo "Processing MetaCubeX..."
$GEODAT2SRS geoip -i MetaCubeX/geoip.dat -o "GeoIP MetaCubeX" --prefix "geoip-"

echo ""
echo "=== Cleaning up temp files ==="
echo ""

# --- Remove temp folders and files ---
rm -rf AntiFilter V2Fly Zkeen

echo ""
echo "=== Renaming files with prefixes ==="
echo ""

# --- Rename files in V2Fly and Zkeen unpacked folders ---

# GeoIP V2Fly
cd "GeoIP V2Fly"
for file in geoip-*.srs; do
    [ -f "$file" ] && mv "$file" "v2fly_$file"
done
cd ..

# GeoIP ZkeenIP
cd "GeoIP ZkeenIP"
for file in geoip-*.srs; do
    [ -f "$file" ] && mv "$file" "zkeen_$file"
done
cd ..

# GeoSite V2Fly
cd "GeoSite V2Fly"
for file in geosite-*.srs; do
    [ -f "$file" ] && mv "$file" "v2fly_$file"
done
cd ..

# GeoSite Zkeen
cd "GeoSite Zkeen"
for file in geosite-*.srs; do
    [ -f "$file" ] && mv "$file" "zkeen_$file"
done
cd ..

# GeoIP MetaCubeX
cd "GeoIP MetaCubeX"
for file in geoip-*.srs; do
    [ -f "$file" ] && mv "$file" "metacx_$file"
done
cd ..

echo ""
echo "=== Copying selected files to root ==="
echo ""

# --- Copy selected files to project root ---

# Проверяем наличие файла со списком
FILES_LIST="$PROJECT_ROOT/filelist.txt"
if [ ! -f "$FILES_LIST" ]; then
    echo "Error: $FILES_LIST not found"
    exit 1
fi

# Читаем список файлов из filelist.txt
readarray -t FILES < "$FILES_LIST"

# Копируем файлы из соответствующих папок
COPIED=0
MISSING=0

# Временно отключаем set -e для этой секции
set +e

for file in "${FILES[@]}"; do
    # Пропускаем пустые строки
    [ -z "$file" ] && continue

    # Пропускаем zkeen_geoip-ru_second.srs и zkeen_geoip-ru_torrent.srs
    # (они будут созданы копированием)
    if [[ "$file" == "zkeen_geoip-ru_second.srs" ]] || [[ "$file" == "zkeen_geoip-ru_torrent.srs" ]]; then
        continue
    fi

    FOUND=false

    # Ищем файл в соответствующей директории
    if [[ $file == v2fly_geoip-* ]] && [ -f "GeoIP V2Fly/$file" ]; then
        cp "GeoIP V2Fly/$file" "$PROJECT_ROOT/" && FOUND=true
    elif [[ $file == zkeen_geoip-* ]] && [ -f "GeoIP ZkeenIP/$file" ]; then
        cp "GeoIP ZkeenIP/$file" "$PROJECT_ROOT/" && FOUND=true
    elif [[ $file == geosite-antifilter* ]] && [ -f "GeoSite AntiFilter/$file" ]; then
        cp "GeoSite AntiFilter/$file" "$PROJECT_ROOT/" && FOUND=true
    elif [[ $file == v2fly_geosite-* ]] && [ -f "GeoSite V2Fly/$file" ]; then
        cp "GeoSite V2Fly/$file" "$PROJECT_ROOT/" && FOUND=true
    elif [[ $file == zkeen_geosite-* ]] && [ -f "GeoSite Zkeen/$file" ]; then
        cp "GeoSite Zkeen/$file" "$PROJECT_ROOT/" && FOUND=true
    elif [[ $file == metacx_geoip-* ]] && [ -f "GeoIP MetaCubeX/$file" ]; then
        cp "GeoIP MetaCubeX/$file" "$PROJECT_ROOT/" && FOUND=true
    fi

    if [ "$FOUND" = true ]; then
        echo "✓ $file"
        COPIED=$((COPIED + 1))
    else
        echo "✗ $file (not found)"
        MISSING=$((MISSING + 1))
    fi
done

# Включаем обратно set -e
set -e

# Удаляем рабочую директорию
cd "$PROJECT_ROOT"
rm -rf "$WORK_DIR"

echo ""
echo "=== Summary ==="
echo "Copied: $COPIED files"
echo "Missing: $MISSING files"
echo ""
echo "All done! Files are in: $PROJECT_ROOT"
