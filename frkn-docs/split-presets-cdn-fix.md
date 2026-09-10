# Split-presets: починка мёртвых CDN-доменов

Аудит каталога `/v1/split_presets` (version 2026-07-31T10:31:43Z, 19 пресетов, 72 записи).

## Проблема

12 записей каталога — голые CDN-домены **без A-записи**. Клиент резолвит домены пресетов в IP на коннекте и маршрутизирует по IP — такие записи резолвятся в ноль и CDN-трафик сервиса пресетом не покрывается (например превью youtube с i.ytimg.com идёт мимо).

## Замены (все проверены `dig @1.1.1.1` — резолвятся)

| Пресет | Удалить | Добавить |
|---|---|---|
| youtube | `ytimg.com` | `i.ytimg.com`, `img.youtube.com` |
| x | `twimg.com` | `pbs.twimg.com`, `abs.twimg.com`, `video.twimg.com` |
| spotify | `scdn.co` | `i.scdn.co`, `audio-fa.scdn.co` |
| spotify | `spotifycdn.net` | — (резолвящегося хоста нет, покрыто scdn.co) |
| netflix | `nflximg.net` | `dnm.nflximg.net`, `art-s.nflximg.net` |
| instagram | `cdninstagram.com` | `static.cdninstagram.com`, `scontent.cdninstagram.com` |
| tiktok | `tiktokcdn.com` | `sf16.tiktokcdn.com`, `p16.tiktokcdn.com` |
| vk | `vk-cdn.net` | `sun9-1.userapi.com` |
| telegram | `cdn-telegram.org` | `telesco.pe`, `cdn4.telegram.org` |
| chatgpt | `oaiusercontent.com` | `files.oaiusercontent.com` |
| ozon | `ozonusercontent.com` | `cdn1.ozonusercontent.com`, `ir.ozone.ru` |
| wildberries | `wbbasket.ru` | `basket-01.wbbasket.ru` |

После правок бампнуть `version` — клиенты подтянут автоматически (cache-hit по версии).

## Оговорки

- Best-effort: у CDN сотни PoP'ов, один хост даёт несколько anycast-IP — покрытие лучше нуля, но не полное. Идеальное решение — маршрутизация по доменному суффиксу/SNI, отдельная фича.
- `spotifycdn.net` и `vk-cdn.net` не резолвятся никак (ни apex, ни типовые сабдомены) — vk заменён на userapi-хост, spotifycdn выкинут.
- `yastatic.net` дублируется в kinopoisk и yandex — безвредно, оставить.

## Методика проверки (повторить при обновлении каталога)

Резолв каждой записи: `dig +short <domain> A @1.1.1.1` — пустой ответ = мёртвая запись.
