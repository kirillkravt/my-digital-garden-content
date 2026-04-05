---
chat_id: 3fe3b089-9bc9-4b8f-ac6d-77c58e5a3223
title: Telegram proxy VPS setup
message_count: 26
exported_at: 2026-04-05T19:25:18.843Z
---

# Telegram proxy VPS setup

## 👤 **Kirill**

Настроить proxy Telegram на VPS

---

## 🤖 **DeepSeek**

Setting up a Telegram proxy on your VPS is a straightforward process. The recommended approach is using an **MTProto proxy**, which is Telegram's official protocol. It's fast, secure, and supports features like Fake TLS to bypass censorship.

The easiest way to get started is with a simple one-line installation script or Docker, depending on your comfort level.

## 🚀 Recommended: One-Line Installation (Easiest)
This method is best for beginners, requiring no prior configuration. A script automates everything from setting up Docker to generating your connection link.

1.  **Connect to your VPS** via SSH as the `root` user.
2.  **Run the following command** in your terminal:
    ```bash
    curl -sSL https://raw.githubusercontent.com/trungpv1601/mtproxy-setup/main/install.sh | bash
    ```
3.  Wait for the script to finish. It will automatically install Docker, configure the firewall, and start the proxy.
4.  **Copy the connection link** displayed at the end (it starts with `https://t.me/proxy` or `tg://proxy`). Paste it into Telegram and tap "Enable Proxy" to connect instantly.

## 🐳 Docker Setup (Official Method)
If you prefer a manual setup or want to customize the configuration (like the port), Docker is a great choice.

### Step 1: Install Docker (if not installed)
Run this command to install Docker on your server:
```bash
curl -sSL https://get.docker.com/ | CHANNEL

---

## 👤 **Kirill**

На русском

---

## 🤖 **DeepSeek**

Настройка прокси для Telegram на VPS — это отличный способ обойти блокировки и обеспечить стабильное соединение. Самый простой и эффективный способ — использовать **MTProto-прокси**, так как это официальный протокол Telegram, который поддерживает обход DPI (глубокой фильтрации пакетов) с помощью Fake TLS.

Вот два самых простых способа настройки.

---

## Способ 1: Автоматическая установка (самый простой)

Этот метод подойдёт даже новичку. Скрипт сам установит всё необходимое и выдаст готовую ссылку для подключения.

1.  **Подключитесь к вашему VPS** по SSH от имени `root`:
    ```bash
    ssh root@ip_вашего_сервера
    ```

2.  **Скачайте и запустите скрипт** одной командой:
    ```bash
    curl -sSL https://raw.githubusercontent.com/trungpv1601/mtproxy-setup/main/install.sh | bash
    ```
    *Скрипт автоматически установит Docker, настроит фаервол и запустит прокси.*

3.  **Скопируйте ссылку**, которая появится в конце установки. Она будет выглядеть так:
    ```
    tg://proxy?server=ваш_ip&port=443&secret=ee...
    ```
    Или так (ссылка с секретом):
    ```
    https://t.me/proxy?server=ваш_ip&port=443&secret=...
    ```

4.  **Откройте Telegram** → перейдите по этой ссылке (или вставьте в браузер) → нажмите **«Включить прокси»**.

---

## Способ 2: Ручная настройка через Docker (более гибкий)

Этот метод подойдёт, если вы хотите сами задать порт или используете не Ubuntu/Debian.

### Шаг 1: Установите Docker (если ещё не установлен)
Выполните команду для автоматической установки Docker:
```bash
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
```

### Шаг 2: Запустите контейнер с MTProto
Выполните команду, заменив `SECRET` на случайный ключ. Самый надёжный вариант — **Fake TLS**, который маскирует трафик под обычный HTTPS. Для этого секрет должен начинаться с `ee`:

```bash
docker run -d \
  --name=mtproto-proxy \
  --restart=unless-stopped \
  -p 443:443 \
  -v proxy-config:/data \
  telegrammessenger/proxy:latest \
  -p 443 \
  -s ee$(openssl rand -hex 16)
```

*   **`-p 443:443`** — прокси будет работать на 443 порту (стандартный HTTPS, его редко блокируют).
*   **`ee...`** — создаёт секрет с префиксом `ee`, активируя режим Fake TLS.

### Шаг 3: Получите секрет и ссылку для подключения
Чтобы посмотреть сгенерированный секрет и собрать ссылку, выполните:
```bash
docker logs mtproto-proxy | grep "secret"
```

Вы увидите строку вида:
```
Generated secret: ee1234567890abcdef...
```

Теперь соберите ссылку для Telegram:
```
tg://proxy?server=IP_ВАШЕГО_СЕРВЕРА&port=443&secret=ee1234567890abcdef...
```
*(Замените `IP_ВАШЕГО_СЕРВЕРА` на реальный IP вашего VPS, а `ee123...` на ваш секрет из логов).*

---

## ⚠️ Важные замечания

1.  **Открытые порты:** Убедитесь, что в настройках файрвола вашего VPS (например, в панели управления хостингом, будь то iptables или облачный firewall) **открыт порт 443 (TCP)**. Если вы выбрали другой порт в команде запуска — откройте его.
2.  **Остановка и удаление:**
    *   Остановить прокси: `docker stop mtproto-proxy`
    *   Запустить снова: `docker start mtproto-proxy`
    *   Удалить полностью: `docker rm -f mtproto-proxy`
3.  **Безопасность:** Этот прокси не шифрует трафик сквозным шифрованием от вас до сервера (используется встроенное шифрование MTProto), но он скрывает сам факт использования Telegram от провайдера (благодаря Fake TLS).

Если скрипт не сработал из-за ошибок, убедитесь, что ваша ОС — Ubuntu 20.04/22.04 или Debian 10/11, и что на сервере есть доступ в интернет.

---

## 👤 **Kirill**

запустил по первому варианту. А как теперь сделать на других устройствах? android рабочий ноут?

---

## 🤖 **DeepSeek**

Отлично! Раз вы уже запустили прокси по первому варианту, у вас есть готовая ссылка для подключения. Вот как подключиться на разных устройствах:

## 📱 **Android**

### Способ 1: По ссылке (самый простой)
1. Откройте Telegram на телефоне
2. Нажмите на ссылку, которая была выведена при установке (например `tg://proxy?server=...`)
3. Нажмите **"Enable proxy"** или **"Включить прокси"**
4. Готово! Вверху появится значок зонтика ☂️

### Способ 2: Вручную (если ссылка не открывается)
1. Откройте Telegram → **Настройки** (иконка ☰ в левом верхнем углу)
2. **Данные и память** → **Прокси-сервер**
3. Нажмите **"Включить прокси"** → выберите **"MTProto"**
4. Введите данные:
   - **Сервер:** IP вашего VPS
   - **Порт:** 443 (или тот, который указан в ссылке)
   - **Секрет:** скопируйте из ссылки после `&secret=`

---

## 💻 **Ноутбук (Windows/Mac/Linux)**

### Через официальный Telegram Desktop:

1. Откройте Telegram Desktop
2. **Настройки** (три полоски вверху слева или иконка ☰)
3. **Дополнительно** → **Прокси-сервер**
4. Нажмите **"Включить прокси"** → выберите **"MTProto"**
5. Введите те же данные, что и для Android:
   - **Сервер:** IP вашего VPS
   - **Порт:** 443
   - **Секрет:** скопируйте из ссылки

Или проще: **нажмите на ссылку** в браузере на ноутбуке — Telegram Desktop автоматически предложит добавить прокси.

---

## 🔍 **Как найти данные для подключения, если потеряли ссылку?**

Подключитесь к серверу по SSH и выполните:

```bash
docker logs mtproto-proxy | grep "secret"
```

Вы увидите что-то вроде:
```
Generated secret: ee1234567890abcdef...
```

Теперь соберите ссылку вручную:
```
tg://proxy?server=IP_ВАШЕГО_СЕРВЕРА&port=443&secret=ee1234567890abcdef...
```
*(IP вашего сервера можно узнать командой `curl ifconfig.me`)*

---

## 📱 **iPhone (iOS)**

1. Откройте Telegram
2. **Настройки** (вкладка в правом нижнем углу)
3. **Данные и память** → **Прокси-сервер**
4. **Включить прокси** → **MTProto**
5. Введите те же данные (сервер, порт, секрет)

---

## 💡 **Советы**
- **Одна ссылка работает на всех устройствах** — просто отправьте её себе в Telegram или сохраните в заметках
- После подключения на любом устройстве вверху появится значок зонтика ☂️ — это значит, что прокси работает
- Если прокси перестал работать после перезагрузки сервера, он должен запуститься автоматически (благодаря флагу `--restart=unless-stopped`)

Если возникли проблемы, проверьте, что порт 443 открыт в фаерволе вашего VPS!

---

## 👤 **Kirill**

Бесконечное соединение

---

## 🤖 **DeepSeek**

Проблема "бесконечное соединение" (или "Connecting...") при подключении к прокси обычно означает, что клиент Telegram не может установить соединение с вашим VPS. Давайте диагностируем и решим проблему.

## 🔍 **Диагностика**

### 1. Проверьте, работает ли прокси на сервере

Подключитесь к VPS по SSH и выполните:

```bash
# Проверьте, запущен ли контейнер
docker ps | grep mtproto
```

Вы должны увидеть что-то вроде:
```
CONTAINER ID   IMAGE                           COMMAND                  CREATED        STATUS         PORTS                    NAMES
xxxxxx         telegrammessenger/proxy:latest  "sh -c 'exec /usr/bi…"   2 hours ago    Up 2 hours     0.0.0.0:443->443/tcp     mtproto-proxy
```

Если контейнера нет или он не запущен:
```bash
# Запустите заново
docker start mtproto-proxy

# Или пересоздайте контейнер
docker rm -f mtproto-proxy
docker run -d \
  --name=mtproto-proxy \
  --restart=unless-stopped \
  -p 443:443 \
  -v proxy-config:/data \
  telegrammessenger/proxy:latest \
  -p 443 \
  -s ee$(openssl rand -hex 16)
```

### 2. Проверьте логи прокси

```bash
docker logs mtproto-proxy --tail 50
```

Ищите ошибки. Если всё нормально, вы увидите строки с подключениями.

### 3. Проверьте, открыт ли порт на сервере

```bash
# Проверьте, слушает ли прокси порт
netstat -tlnp | grep 443
```

Должно быть что-то вроде:
```
tcp6       0      0 :::443                  :::*                    LISTEN      12345/docker-proxy
```

### 4. Проверьте файрвол (UFW/iptables)

```bash
# Если используете UFW
ufw status

# Откройте порт 443 если он закрыт
ufw allow 443/tcp
```

Если используете **iptables**:
```bash
iptables -L -n | grep 443
```

### 5. Проверьте доступность порта извне

На **локальном компьютере** (не на VPS) выполните:

**Windows (PowerShell):**
```powershell
Test-NetConnection -ComputerName IP_ВАШЕГО_СЕРВЕРА -Port 443
```

**Mac/Linux:**
```bash
nc -zv IP_ВАШЕГО_СЕРВЕРА 443
```

Если порт не доступен, проблема в файерволе вашего хостинг-провайдера (не на самом сервере, а в панели управления VPS).

---

## 🔧 **Наиболее частые причины и решения**

### ❌ **Причина 1: Порт 443 закрыт в облачном файерволе**
У многих хостингов (DigitalOcean, Vultr, Hetzner и др.) есть **внешний firewall** в панели управления.

**Решение:** Зайдите в панель управления вашего VPS → найдите раздел **Networking / Firewall** → добавьте правило **Inbound Rule**:
- **Protocol:** TCP
- **Port:** 443
- **Source:** 0.0.0.0/0 (или Anywhere)

### ❌ **Причина 2: Неправильный IP в ссылке**
Если вы используете IPv6, а у вас нет IPv6 на клиентском устройстве, подключения не будет.

**Решение:** Убедитесь, что в ссылке используется **IPv4 адрес**:
```bash
# Узнайте IPv4 адрес вашего сервера
curl -4 ifconfig.me
```

### ❌ **Причина 3: Контейнер не создал секрет**
Иногда скрипт не завершается корректно.

**Решение:** Создайте прокси вручную:

```bash
# Остановите и удалите старый контейнер
docker rm -f mtproto-proxy

# Создайте новый с явным указанием секрета
SECRET="ee$(openssl rand -hex 16)"
echo "Ваш секрет: $SECRET"

docker run -d \
  --name=mtproto-proxy \
  --restart=unless-stopped \
  -p 443:443 \
  -v proxy-config:/data \
  telegrammessenger/proxy:latest \
  -p 443 \
  -s $SECRET
```

После этого соберите ссылку:
```
tg://proxy?server=IP_ВАШЕГО_СЕРВЕРА&port=443&secret=ВАШ_СЕКРЕТ
```

### ❌ **Причина 4: Порт 443 уже занят другим сервисом**

```bash
# Проверьте, что использует порт 443
sudo lsof -i :443
```

Если порт занят (например, nginx или apache), либо остановите этот сервис, либо используйте другой порт:
```bash
# Запустите на порту 8443
docker run -d \
  --name=mtproto-proxy \
  --restart=unless-stopped \
  -p 8443:443 \
  -v proxy-config:/data \
  telegrammessenger/proxy:latest \
  -p 443 \
  -s ee$(openssl rand -hex 16)
```
Тогда порт будет **8443**, а ссылка: `tg://proxy?server=IP&port=8443&secret=...`

---

## 🆘 **Если ничего не помогло**

Выполните команду и покажите результат:

```bash
# Полная диагностика
echo "=== Контейнеры ==="
docker ps -a | grep mtproto
echo ""
echo "=== Логи ==="
docker logs mtproto-proxy --tail 20
echo ""
echo "=== Порты ==="
netstat -tlnp | grep -E ":(443|8443)"
echo ""
echo "=== Файрвол ==="
ufw status 2>/dev/null || iptables -L -n | grep 443
echo ""
echo "=== IP сервера ==="
curl -4 ifconfig.me
```

Скопируйте вывод (скрыв реальный IP, если хотите) — это поможет понять, в чём проблема.

---

## 👤 **Kirill**

root@6866843-py278858:~# # Проверьте, запущен ли контейнер
docker ps | grep mtproto
root@6866843-py278858:~# 

по одной команде давай пробовать решить, а не сразу кучу вариантов

---

## 🤖 **DeepSeek**

Хорошо, давайте по одному шагу. Контейнер не запущен. Давайте проверим, существует ли он вообще:

```bash
docker ps -a | grep mtproto
```

Выполните эту команду и покажите результат.

---

## 👤 **Kirill**

root@6866843-py278858:~# docker ps -a | grep mtproto
root@6866843-py278858:~# 

Ничего не отдает

---

## 🤖 **DeepSeek**

Контейнера нет. Значит скрипт не создал его. Давайте запустим прокси вручную одной командой:

```bash
docker run -d --name=mtproto-proxy --restart=unless-stopped -p 443:443 -v proxy-config:/data telegrammessenger/proxy:latest -p 443 -s ee$(openssl rand -hex 16)
```

Выполните эту команду и покажите результат.

---

## 👤 **Kirill**

Подожди, а как тогда на десктопе заработал?

---

## 🤖 **DeepSeek**

Вы правы, это странно. Если контейнера нет в списке, но прокси работает на десктопе — значит он запущен, но по-другому.

Давайте проверим все контейнеры без фильтра:

```bash
docker ps -a
```

Выполните и покажите результат. Возможно контейнер называется не "mtproto-proxy", а как-то иначе.

---

## 👤 **Kirill**

root@6866843-py278858:~# docker ps -a | grep mtproto
root@6866843-py278858:~# docker ps -a
CONTAINER ID   IMAGE                              COMMAND                  CREATED          STATUS                   PORTS                                       NAMES
5714c1198817   telegrammessenger/proxy:latest     "/bin/sh -c '/bin/ba…"   14 minutes ago   Up 14 minutes            0.0.0.0:8443->443/tcp, [::]:8443->443/tcp   mtproxy
2c15fdeb33e9   ghcr.io/openclaw/openclaw:latest   "docker-entrypoint.s…"   3 weeks ago      Exited (0) 10 days ago                                               openclaw-gateway
root@6866843-py278858:~#

---

## 🤖 **DeepSeek**

Вижу! Контейнер называется **mtproxy** (не mtproto-proxy) и работает на порту **8443**, а не 443.

Вот ваша ссылка для подключения:

```
tg://proxy?server=IP_ВАШЕГО_СЕРВЕРА&port=8443&secret=???
```

Чтобы получить секрет, выполните:

```bash
docker logs mtproxy | grep secret
```

Покажите результат — я помогу собрать правильную ссылку для Android и ноутбука.

---

## 👤 **Kirill**

ссылка сформировалась

---

## 🤖 **DeepSeek**

Отлично!

Теперь подключите другие устройства:

## **Android:**
1. Нажмите на ссылку (или скопируйте и вставьте в браузер)
2. Telegram откроется и спросит — нажмите **"Включить прокси"**

## **Ноутбук (Telegram Desktop):**
1. Скопируйте ссылку
2. Вставьте в адресную строку браузера и нажмите Enter
3. Telegram Desktop предложит добавить прокси — согласитесь

Или вручную:
- **Сервер:** IP вашего VPS
- **Порт:** 8443
- **Секрет:** тот который получили

---

Если ссылка не открывается на Android — просто введите данные вручную в настройках Telegram → Данные и память → Прокси-сервер → MTProto.

Готово! На всех устройствах теперь будет работать прокси.

---

## 👤 **Kirill**

а такое же можно сделать для instagram?

---

## 🤖 **DeepSeek**

Для Instagram, к сожалению, нет такого же простого готового решения, как MTProto для Telegram. Telegram сам разработал и поддерживает свой прокси-протокол, а у Instagram такого нет.

Но есть другие варианты. Я покажу самый простой и универсальный способ — **SOCKS5-прокси**, который подойдет для Instagram и любых других приложений.

---

## 🎯 **Самый простой способ: SOCKS5 через Gost**

Это похоже на то, что мы делали с Telegram, только другой протокол. SOCKS5 поддерживается большинством приложений, браузеров и антидетект-браузеров (которые часто используют для Instagram).

### Шаг 1: Запустите SOCKS5-прокси одной командой

```bash
docker run -d \
  --name=socks5-proxy \
  --restart=unless-stopped \
  -p 1080:1080 \
  ginuerzh/gost \
  -L=socks5://:@:1080
```

Это запустит прокси на порту **1080** без пароля. [citation:2]

### Шаг 2: Проверьте, что контейнер запустился

```bash
docker ps | grep socks5
```

### Шаг 3: Узнайте IP вашего сервера

```bash
curl -4 ifconfig.me
```

Теперь у вас есть прокси: **IP_ВАШЕГО_СЕРВЕРА:1080**

---

## 📱 **Как использовать этот прокси для Instagram**

### На Android (через приложение)

На чистом Android сложно настроить прокси только для Instagram — обычно это делается через:

1. **VPN-клиент с поддержкой SOCKS5** (например, **Postern** или **ProxyDroid**)
2. Или через **настройки Wi-Fi** (но это системный прокси для всего телефона)

### На ноутбуке / компьютере

#### Способ 1: Через браузер (Chrome/Firefox)
- **Chrome:** Запустите с параметром: `chrome --proxy-server="socks5://IP_СЕРВЕРА:1080"`
- **Firefox:** Настройки → Сеть → Настроить прокси вручную → SOCKS5

#### Способ 2: Через системные настройки
- **Windows:** Параметры → Сеть и интернет → Прокси → Настроить прокси вручную
- **Mac:** Системные настройки → Сеть → Дополнительно → Прокси

#### Способ 3: Для антидетект-браузеров (Multilogin, AdsPower и др.)
В настройках профиля укажите тип прокси **SOCKS5** и введите `IP:1080` [citation:4]

---

## 🔐 **Добавить пароль (рекомендуется)**

Чтобы прокси не могли использовать посторонние, добавьте логин и пароль:

```bash
# Остановить и удалить старый контейнер
docker stop socks5-proxy && docker rm socks5-proxy

# Запустить с авторизацией
docker run -d \
  --name=socks5-proxy \
  --restart=unless-stopped \
  -p 1080:1080 \
  ginuerzh/gost \
  -L=socks5://myuser:mypassword@:1080
```

Замените `myuser` и `mypassword` на свои логин и пароль.

Теперь строка подключения: `socks5://myuser:mypassword@IP_СЕРВЕРА:1080` [citation:2]

---

## 📊 **Сравнение: Telegram vs Instagram**

| Параметр | Telegram | Instagram |
|----------|----------|----------|
| Готовое решение | ✅ MTProto | ❌ Нет |
| Официальная поддержка | ✅ От Telegram | ❌ |
| Настройка | 1 команда | 1 команда (SOCKS5) |
| Как использовать | Встроено в Telegram | Через настройки системы/браузера |

---

## 📌 **Коротко**

**Для Instagram** — запускаете SOCKS5-прокси (команда выше), затем в приложении или браузере указываете тип прокси **SOCKS5**, адрес сервера и порт 1080.

Ссылки-одного-клика, как в Telegram, для Instagram не существует, потому что у Instagram нет встроенной поддержки прокси в самом приложении.

Хотите, можете сразу добавить пароль и я помогу проверить, что прокси работает?This response is AI-generated, for reference only.

---

## 👤 **Kirill**

Vps можно использовать как хостинг для сайта/блога?

---

## 🤖 **DeepSeek**

Да, VPS отлично подходит для хостинга сайта или блога. У вас уже есть сервер с Docker, что сильно упрощает задачу.

## 🚀 **Самые простые варианты**

### 1. **WordPress (самый популярный для блога)**

Одна команда — и всё работает:

```bash
docker run -d \
  --name=wordpress \
  --restart=unless-stopped \
  -p 80:80 \
  -e WORDPRESS_DB_HOST=db \
  -e WORDPRESS_DB_USER=wordpress \
  -e WORDPRESS_DB_PASSWORD=password \
  -e WORDPRESS_DB_NAME=wordpress \
  wordpress
```

Но WordPress нужна база данных. Проще использовать **Docker Compose**. Создайте файл `docker-compose.yml`:

```yaml
version: '3'
services:
  db:
    image: mysql:5.7
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: password
      MYSQL_ROOT_PASSWORD: rootpassword
    volumes:
      - db_data:/var/lib/mysql

  wordpress:
    image: wordpress:latest
    restart: unless-stopped
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: password
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wp_data:/var/www/html

volumes:
  db_data:
  wp_data:
```

Запустите:
```bash
docker-compose up -d
```

После этого сайт будет доступен по IP вашего сервера в браузере.

---

### 2. **Ghost (современная альтернатива WordPress)**

Легкий, быстрый блог на Node.js:

```bash
docker run -d \
  --name=ghost \
  --restart=unless-stopped \
  -p 2368:2368 \
  ghost
```

Открываете в браузере: `http://IP_ВАШЕГО_СЕРВЕРА:2368`

---

### 3. **Статический сайт (HTML/CSS)**

Если у вас есть папка с файлами сайта, например `my-site`:

```bash
# Создайте папку с сайтом
mkdir my-site
echo "<h1>Мой блог</h1>" > my-site/index.html

# Запустите веб-сервер
docker run -d \
  --name=my-site \
  --restart=unless-stopped \
  -p 80:80 \
  -v $(pwd)/my-site:/usr/share/nginx/html:ro \
  nginx
```

---

## 🔧 **Что важно учесть**

### 1. **Порты**
Сейчас порт 80 (HTTP) и 443 (HTTPS) могут быть заняты вашим Telegram прокси. Проверьте:
```bash
docker ps
```

Если Telegram использует порт 8443, то 80 и 443 свободны. Если нет — измените порт для сайта:
```bash
-p 8080:80  # вместо -p 80:80
```

### 2. **Домен и HTTPS**
Для нормального блога лучше купить домен и настроить SSL. Самый простой способ — **Nginx Proxy Manager**:

```bash
docker run -d \
  --name=nginx-proxy-manager \
  --restart=unless-stopped \
  -p 80:80 \
  -p 81:81 \
  -p 443:443 \
  -v npm_data:/data \
  jc21/nginx-proxy-manager
```

Потом заходите на `http://IP:81` (логин: admin@example.com, пароль: changeme) и настраиваете домены и бесплатные SSL-сертификаты.

### 3. **Ресурсы**
- WordPress: ~512 MB RAM, 10-20 GB диска
- Ghost: ~256 MB RAM, 5-10 GB диска
- Статический сайт: минимально

---

## 📊 **Какой вариант выбрать?**

| Вариант | Сложность | Для чего подходит |
|---------|-----------|-------------------|
| **WordPress** | Средняя | Классический блог, много плагинов, тем |
| **Ghost** | Низкая | Современный блог, Markdown, быстрый |
| **Статический сайт** | Низкая | Портфолио, лендинг, если не нужна админка |

---

## 💡 **Бонус: и прокси, и сайт одновременно**

У вас уже есть Telegram прокси на порту 8443. Вы можете спокойно запустить сайт на порту 80 — они не мешают друг другу.

```bash
# Проверьте, что порты не заняты
netstat -tlnp | grep -E ":(80|443)"
```

Если порты свободны — запускайте любой вариант выше.

---

Какой вариант больше подходит? WordPress, Ghost или статический сайт? Или хотите сразу настроить с доменом и HTTPS?

---

## 👤 **Kirill**

Хочу сразу настроить с доменом и https

---

## 🤖 **DeepSeek**

Отлично! Давайте настроим всё профессионально: **домен + HTTPS + сайт + Telegram прокси** на одном сервере.

## 📋 **План действий**

1. Настроим **Nginx Proxy Manager** — это панель для управления доменами и SSL
2. Запустим сайт (на примере WordPress)
3. Подключим домен и получим бесплатный SSL-сертификат
4. Убедимся, что Telegram прокси продолжает работать

---

## Шаг 1: Убедимся, что порты свободны

Прокси Telegram у вас работает на **8443** порту, значит порты **80** и **443** свободны для сайта:

```bash
netstat -tlnp | grep -E ":(80|443)"
```

Если ничего не выводит — порты свободны.

---

## Шаг 2: Запустим Nginx Proxy Manager

Это удобная веб-панель для управления доменами и SSL:

```bash
# Создадим сеть для контейнеров
docker network create web

# Запустим Nginx Proxy Manager
docker run -d \
  --name=npm \
  --restart=unless-stopped \
  --network=web \
  -p 80:80 \
  -p 443:443 \
  -p 81:81 \
  -v npm_data:/data \
  -v npm_letsencrypt:/etc/letsencrypt \
  jc21/nginx-proxy-manager
```

Проверьте, что запустился:
```bash
docker ps | grep npm
```

---

## Шаг 3: Запустим WordPress

```bash
# Создадим папку для WordPress
mkdir -p /opt/wordpress
cd /opt/wordpress

# Создадим файл docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3'
services:
  db:
    image: mysql:5.7
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wp_password_here
      MYSQL_ROOT_PASSWORD: root_password_here
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - web

  wordpress:
    image: wordpress:latest
    restart: unless-stopped
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wp_password_here
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wp_data:/var/www/html
    networks:
      - web
    expose:
      - "80"

volumes:
  db_data:
  wp_data:

networks:
  web:
    external: true
EOF

# Запустим WordPress
docker-compose up -d
```

Проверьте:
```bash
docker-compose ps
```

---

## Шаг 4: Вход в Nginx Proxy Manager

Откройте в браузере: `http://IP_ВАШЕГО_СЕРВЕРА:81`

**Логин:** `admin@example.com`  
**Пароль:** `changeme`

При первом входе попросят сменить email и пароль — сделайте это.

---

## Шаг 5: Добавьте домен в DNS

Перед настройкой SSL нужно, чтобы домен смотрел на ваш сервер.

У вашего домена (где покупали, например reg.ru, nic.ru, namecheap) в настройках DNS добавьте **A-запись**:

| Тип | Имя | Значение |
|-----|-----|---------|
| A | @ | IP_ВАШЕГО_СЕРВЕРА |
| A | www | IP_ВАШЕГО_СЕРВЕРА |

Подождите 5-15 минут, пока DNS распространится. Проверить можно командой:
```bash
ping ваш-домен.ru
```

---

## Шаг 6: Настройте прокси в Nginx Proxy Manager

Зайдите в панель NPM (`http://IP:81`) и сделайте:

### 6.1 Добавьте прокси для сайта

1. Нажмите **Proxy Hosts** → **Add Proxy Host**
2. **Domain Names:** введите ваш домен (например, `blog.mysite.ru` или `mysite.ru`)
3. **Forward Hostname / IP:** `wordpress` (имя контейнера)
4. **Forward Port:** `80`
5. Перейдите на вкладку **SSL**
6. Выберите **Request a new SSL Certificate**
7. **Force SSL** — включите
8. Нажмите **Save**

Через 10-30 секунд SSL-сертификат будет получен и сайт станет доступен по HTTPS.

---

## Шаг 7: Проверьте, что всё работает

1. Откройте браузер и перейдите на `https://ваш-домен.ru`
2. Должна открыться страница установки WordPress

---

## Шаг 8: Настройка WordPress

1. Выберите язык
2. Заполните:
   - **Название сайта:** ваш блог
   - **Логин:** придумайте
   - **Пароль:** запишите
   - **Email:** ваш email
3. Готово!

---

## 🔍 **Полезные команды**

```bash
# Посмотреть все запущенные контейнеры
docker ps

# Посмотреть логи WordPress
docker logs wordpress_wordpress_1

# Перезапустить всё
cd /opt/wordpress && docker-compose restart
```

---

## 📌 **Что у вас теперь есть**

| Сервис | Адрес | Порты |
|--------|-------|-------|
| **Сайт** | `https://ваш-домен.ru` | 80, 443 |
| **Telegram прокси** | `tg://proxy?server=IP&port=8443&secret=...` | 8443 |
| **Nginx Proxy Manager** | `http://IP:81` | 81 |

Всё работает на одном VPS, никаких конфликтов.

---

## 🆘 **Если что-то пошло не так**

**Не открывается сайт:**
```bash
# Проверьте, что контейнеры запущены
docker ps | grep -E "(wordpress|npm)"
```

**SSL не выдается:**
- Убедитесь, что домен точно смотрит на IP вашего сервера
- Проверьте, что порты 80 и 443 открыты в фаерволе хостинга

**WordPress не подключается к БД:**
```bash
docker logs wordpress_wordpress_1
```

---

Всё готово! У вас теперь полноценный блог на WordPress с HTTPS и работающий Telegram прокси на том же сервере. 

Какой домен будете использовать? Если нужна помощь с DNS или возникнут вопросы — спрашивайте

---

## 👤 **Kirill**

У меня vps на timetoweb и блог на django

---

## 🤖 **DeepSeek**

Отлично! С Django блогом всё будет даже проще и быстрее, чем с WordPress. У вас уже есть Telegram прокси, теперь добавим Django-сайт с доменом и HTTPS.

## 📋 **План для Django**

1. Подготовим Django проект
2. Запустим через Gunicorn (WSGI сервер)
3. Настроим Nginx Proxy Manager как обратный прокси
4. Подключим домен и SSL

---

## Шаг 1: Проверьте текущее состояние

```bash
# Посмотрим, что уже запущено
docker ps
```

У вас должен быть контейнер `mtproxy` на порту 8443. Порты 80 и 443 свободны для сайта.

---

## Шаг 2: Запустим Nginx Proxy Manager

Это универсальное решение для доменов и SSL:

```bash
# Создадим сеть для контейнеров
docker network create web

# Запустим Nginx Proxy Manager
docker run -d \
  --name=npm \
  --restart=unless-stopped \
  --network=web \
  -p 80:80 \
  -p 443:443 \
  -p 81:81 \
  -v npm_data:/data \
  -v npm_letsencrypt:/etc/letsencrypt \
  jc21/nginx-proxy-manager
```

---

## Шаг 3: Создайте Dockerfile для Django

Создайте папку для проекта и файл `Dockerfile`:

```bash
mkdir -p /opt/django-blog
cd /opt/django-blog
```

**Dockerfile:**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Установка зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копирование проекта
COPY . .

# Сбор статики
RUN python manage.py collectstatic --noinput

# Запуск Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "your_project.wsgi:application"]
```

---

## Шаг 4: Файл docker-compose.yml

Создайте `docker-compose.yml`:

```yaml
version: '3'

services:
  db:
    image: postgres:15
    restart: unless-stopped
    environment:
      POSTGRES_DB: your_db_name
      POSTGRES_USER: your_user
      POSTGRES_PASSWORD: your_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - web

  django:
    build: .
    restart: unless-stopped
    environment:
      DATABASE_URL: postgres://your_user:your_password@db:5432/your_db_name
      SECRET_KEY: ваш_секретный_ключ
      DEBUG: '0'
      ALLOWED_HOSTS: ваш-домен.ru,www.ваш-домен.ru
    volumes:
      - static_files:/app/static
      - media_files:/app/media
    depends_on:
      - db
    networks:
      - web
    expose:
      - "8000"

  nginx:
    image: nginx:alpine
    restart: unless-stopped
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - static_files:/static:ro
      - media_files:/media:ro
    depends_on:
      - django
    networks:
      - web
    expose:
      - "80"

volumes:
  postgres_data:
  static_files:
  media_files:

networks:
  web:
    external: true
```

---

## Шаг 5: Файл nginx.conf (для отдачи статики)

Создайте `nginx.conf`:

```nginx
server {
    listen 80;
    server_name _;
    
    location /static/ {
        alias /static/;
    }
    
    location /media/ {
        alias /media/;
    }
    
    location / {
        proxy_pass http://django:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## Шаг 6: Структура Django проекта

Ваш Django проект должен быть в `/opt/django-blog` с такой структурой:

```
/opt/django-blog/
├── Dockerfile
├── docker-compose.yml
├── nginx.conf
├── requirements.txt
├── manage.py
├── your_project/
│   ├── __init__.py
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
└── (ваши приложения)
```

**В `settings.py` обязательно добавьте:**

```python
import os

STATIC_URL = '/static/'
STATIC_ROOT = '/app/static'

MEDIA_URL = '/media/'
MEDIA_ROOT = '/app/media'

ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '').split(',')

# Для PostgreSQL
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'your_db_name',
        'USER': 'your_user',
        'PASSWORD': 'your_password',
        'HOST': 'db',
        'PORT': '5432',
    }
}
```

**requirements.txt:**
```
Django>=4.2
gunicorn
psycopg2-binary
```

---

## Шаг 7: Запустите Django проект

```bash
cd /opt/django-blog

# Соберите и запустите
docker-compose up -d

# Проверьте, что всё запустилось
docker-compose ps
```

---

## Шаг 8: Настройка домена в Nginx Proxy Manager

### 8.1 Настройте DNS
В панели управления доменом (TimeWeb или где покупали) добавьте A-запись:
- **@** → IP вашего VPS
- **www** → IP вашего VPS

### 8.2 Зайдите в панель NPM
`http://IP_ВАШЕГО_СЕРВЕРА:81`

Логин: `admin@example.com`  
Пароль: `changeme` (смените при первом входе)

### 8.3 Добавьте прокси
1. **Proxy Hosts** → **Add Proxy Host**
2. **Domain Names:** ваш домен (например, `blog.mysite.ru`)
3. **Forward Hostname / IP:** `django-nginx-1` или имя вашего nginx контейнера (узнайте через `docker ps`)
4. **Forward Port:** `80`
5. Перейдите на вкладку **SSL**
6. **Request a new SSL Certificate** → **Force SSL** → **Save**

---

## Шаг 9: Примените миграции и создайте суперпользователя

```bash
# Миграции
docker-compose exec django python manage.py migrate

# Создайте админа
docker-compose exec django python manage.py createsuperuser

# Соберите статику (если не собралась в Dockerfile)
docker-compose exec django python manage.py collectstatic
```

---

## 📊 **Итоговая структура**

| Сервис | Контейнер | Порт | Доступ |
|--------|-----------|------|--------|
| **Django** | django-blog_django_1 | 8000 (внутренний) | через NPM |
| **Nginx (статику)** | django-blog_nginx_1 | 80 (внутренний) | через NPM |
| **PostgreSQL** | django-blog_db_1 | 5432 (внутренний) | только для Django |
| **Nginx Proxy Manager** | npm | 80, 443, 81 | внешний: 80,443 для сайта, 81 для панели |
| **Telegram Proxy** | mtproxy | 8443 | внешний: прокси |

---

## 🔧 **Полезные команды**

```bash
# Посмотреть все контейнеры
docker ps

# Логи Django
docker-compose logs django

# Логи Nginx Proxy Manager
docker logs npm

# Перезапустить всё
docker-compose restart

# Остановить всё
docker-compose down

# Запустить снова
docker-compose up -d
```

---

## ⚠️ **Важно для TimeWeb VPS**

1. **Проверьте файрвол в панели TimeWeb:**
   - Зайдите в панель управления VPS
   - Откройте порты: **80 (TCP), 443 (TCP), 81 (TCP)** для NPM
   - Порт **8443 (TCP)** у вас уже открыт для Telegram

2. **Память:**
   - Django + PostgreSQL + NPM + Telegram ≈ 1-2 GB RAM
   - Если мало памяти, можно использовать SQLite вместо PostgreSQL

---

## 🆘 **Если что-то не работает**

**Сайт не открывается:**
```bash
# Проверьте, что NPM видит Django контейнеры
docker network inspect web
```

**502 Bad Gateway:**
```bash
# Проверьте, что Django работает внутри
docker exec -it django-blog_django_1 curl localhost:8000
```

**SSL не выдается:**
```bash
# Убедитесь, что домен смотрит на сервер
ping ваш-домен.ru
```

---

Всё готово! У вас будет:
- ✅ Django блог на вашем домене с HTTPS
- ✅ Telegram прокси на порту 8443
- ✅ Удобная панель управления доменами и SSL

Как называется ваш Django проект? Если поделитесь структурой, могу подправить конфиги под ваш проект.

---

