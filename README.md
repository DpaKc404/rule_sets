# Rule Sets

Автоматически генерируемые наборы правил `.srs` для sing-box из различных источников.

## Что это?

Этот репозиторий содержит автоматически обновляемые файлы правил в формате `.srs` (sing-box rule set), собранные из нескольких источников:

- **AntiFilter** - домены и IP для обхода блокировок
- **V2Fly** - гео-правила и категории доменов
- **Zkeen** - расширенные наборы правил для маршрутизации

## Использование

Все файлы доступны в [релизе с тегом `test`](https://github.com/DpaKc404/rule_sets/releases/tag/test).

### Пример использования в конфигурации sing-box:

```json
{
  "route": {
    "rules": [
      {
        "rule_set": [
          "https://github.com/DpaKc404/rule_sets/releases/download/test/v2fly_geoip-ru.srs",
          "https://github.com/DpaKc404/rule_sets/releases/download/test/zkeen_geoip-telegram.srs"
        ],
        "outbound": "direct"
      }
    ]
  }
}
```

## Доступные файлы

Полный список файлов находится в [`filelist.txt`](filelist.txt).

### Основные категории:

- **GeoIP** - правила на основе IP адресов
  - `v2fly_geoip-*` - IP диапазоны (cloudflare, google, ru и т.д.)
  - `zkeen_geoip-*` - расширенные IP правила (CDN, хостинги, сервисы)
  - `metacubex_geoip-*` - дополнительные IP правила таких как cloudflare, google, telegram, netflix, twitter и другие. (MetaCubeX источник)

- **GeoSite** - правила на основе доменов
  - `v2fly_geosite-*` - категории доменов (ads, social, gov-ru и т.д.)
  - `zkeen_geosite-*` - дополнительные домены (youtube, bypass и т.д.)
  - `geosite-antifilter*` - домены для обхода блокировок

## Автоматическое обновление

Файлы автоматически обновляются ежедневно через GitHub Actions:

1. Скачиваются последние `.dat` файлы из источников
2. Конвертируются в формат `.srs` с помощью `geodat2srs`
3. Публикуются в релизе с тегом `test`

Последнее обновление можно посмотреть в [релизах](https://github.com/DpaKc404/rule_sets/releases).

## Сборка локально

Требования:
- Go 1.23+
- curl

```bash
# Собрать geodat2srs
cd src
go build -o ../geodat2srs

# Запустить генерацию
./scripts/generate_rules.sh
```

## Источники

- [AntiFilter Domains](https://github.com/Skrill0/AntiFilter-Domains)
- [AntiFilter IP](https://github.com/Skrill0/AntiFilter-IP)
- [V2Fly Domain List](https://github.com/v2fly/domain-list-community)
- [V2Ray Rules Dat](https://github.com/loyalsoldier/v2ray-rules-dat)
- [Zkeen Domains](https://github.com/jameszeroX/zkeen-domains)
- [Zkeen IP](https://github.com/jameszeroX/zkeen-ip)
- [MetaCubeX Meta Rules Dat](https://github.com/MetaCubeX/meta-rules-dat)
