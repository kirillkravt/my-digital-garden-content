---
chat_id: c3177145-9ca2-47b6-bdda-d1e53ebecbe4
title: Процесс подключения API через Keycloak
message_count: 4
exported_at: 2026-05-24T19:36:51.081Z
---

# Процесс подключения API через Keycloak

## 👤 **Kirill**

объясни процесс как подключается api 
Архитектура:
ТСП->Keycloack->Clinkr
SBP Processing->Keycloack->Clinkr 

Дальше запросы проходят через Clinkr

---

## 🤖 **DeepSeek**

Процесс подключения API в указанной архитектуре можно описать следующим образом:

### Общая схема взаимодействия:
1. **ТСП (Торгово-Сервисный Провайдер)** или **SBP Processing** инициируют запрос
2. Запрос проходит аутентификацию/авторизацию через **Keycloak**
3. После успешной аутентификации запрос направляется в **Clinkr**
4. **Clinkr** выполняет дальнейшую маршрутизацию и обработку запроса

### Подробный процесс подключения API:

1. **Регистрация клиента в Keycloak**:
   - ТСП/SBP Processing регистрируются как клиенты в Keycloak
   - Настраиваются:
     - Client ID и Client Secret
     - Grant Types (обычно client_credentials для M2M)
     - Доступные scopes/роли
     - Redirect URIs (если требуется)
     - Access Token Lifespan

2. **Получение токена доступа**:
   - ТСП/SBP Processing отправляют запрос в Keycloak:
     ```
     POST /auth/realms/{realm}/protocol/openid-connect/token
     Content-Type: application/x-www-form-urlencoded
     
     client_id=YOUR_CLIENT_ID
     &client_secret=YOUR_CLIENT_SECRET
     &grant_type=client_credentials
     ```
   - В ответ получают access_token (JWT)

3. **Вызов API через Clinkr**:
   - Клиент включает полученный токен в заголовок Authorization:
     ```
     GET /api/v1/resource
     Authorization: Bearer <access_token>
     ```
   - Запрос сначала попадает в Clinkr

4. **Валидация токена в Clinkr**:
   - Clinkr может:
     a) Проверить подпись токена самостоятельно (используя JWKS из Keycloak)
     b) Или отправить запрос introspection в Keycloak:
        ```
        POST /auth/realms/{realm}/protocol/openid-connect/token/introspect
        token=<access_token>
        ```

5. **Маршрутизация и обработка**:
   - После успешной валидации Clinkr:
     - Проверяет scopes/роли в токене
     - Маршрутизирует запрос к соответствующему сервису
     - Может добавлять/модифицировать заголовки
     - Логирует запрос

6. **Ответ**:
   - Ответ от целевого сервиса проходит обратно через Clinkr
   - Clinkr может добавлять свои заголовки/логировать
   - Ответ возвращается инициатору запроса

### Особенности архитектуры:
- **Keycloak** выступает центральным IDP (Identity Provider)
- **Clinkr** работает как API Gateway с функциями:
  - Аутентификация/авторизация
  - Маршрутизация
  - Возможно: кеширование, rate limiting, трансформация запросов
- ТСП и SBP Processing имеют разные права доступа (настроенные в Keycloak)

### Настройки для подключения нового клиента:
1. Создать нового клиента в Keycloak
2. Настроить необходимые роли/scopes
3. Выдать credentials (client_id + secret)
4. Настроить в Clinkr правила маршрутизации для нового клиента
5. Предоставить документацию по API (эндпоинты, требуемые scopes)

---

## 👤 **Kirill**

Как проходит взаимодействие через Clinkr, что нужно для обеих сторон?
Например POST запрос от ТСП на проведение платежа и ответ от SBP Processing с результатом

---

## 🤖 **DeepSeek**

Рассмотрим процесс взаимодействия через **Clinkr** на примере **POST-запроса от ТСП на проведение платежа** и **ответа от SBP Processing**.  

---

### **1. Что нужно для обеих сторон?**  

#### **Для ТСП (инициатора запроса):**  
- **Доступ к Keycloak**:  
  - `client_id` и `client_secret` для аутентификации в Keycloak.  
  - Разрешенный `grant_type` (обычно `client_credentials` для M2M-взаимодействия).  
- **Данные для платежа**:  
  - Реквизиты платежа (ID транзакции, сумма, получатель и т. д.) в формате, ожидаемом SBP Processing.  
- **Endpoint Clinkr**:  
  - URL API-шлюза (например, `https://clinkr-gateway/api/v1/payments`).  

#### **Для SBP Processing (обработчика платежа):**  
- **Интеграция с Clinkr**:  
  - Настроенные маршруты в Clinkr (какие запросы куда перенаправлять).  
  - Возможность валидации входящих токенов (JWT из Keycloak).  
- **Обработка платежа**:  
  - Логика проверки и исполнения платежа.  
  - Формирование ответа в согласованном формате (JSON/XML).  

---

### **2. Процесс взаимодействия (POST → Clinkr → SBP Processing → Ответ)**  

#### **Шаг 1: ТСП запрашивает токен в Keycloak**  
Перед вызовом API ТСП получает `access_token`:  
```http
POST /auth/realms/{realm}/protocol/openid-connect/token
Content-Type: application/x-www-form-urlencoded

client_id=tsp-client
&client_secret=******
&grant_type=client_credentials
```
**Ответ Keycloak**:  
```json
{
  "access_token": "eyJhbGciOiJ...",
  "expires_in": 300,
  "token_type": "Bearer"
}
```

#### **Шаг 2: ТСП отправляет запрос в Clinkr**  
Запрос на проведение платежа с токеном в заголовке:  
```http
POST /api/v1/payments
Authorization: Bearer eyJhbGciOiJ...
Content-Type: application/json

{
  "transaction_id": "12345",
  "amount": 1000,
  "currency": "RUB",
  "recipient": "merchant123",
  "description": "Оплата заказа #42"
}
```

#### **Шаг 3: Clinkr обрабатывает запрос**  
- **Проверяет токен** (через JWKS или запрос к Keycloak).  
- **Определяет маршрут** (на основе пути `/payments` запрос идет в SBP Processing).  
- **Добавляет служебные заголовки** (например, `X-Request-ID`, `X-Source: TSP`).  
- **Перенаправляет запрос** в SBP Processing.  

#### **Шаг 4: SBP Processing выполняет платеж**  
- Проверяет данные платежа.  
- Резервирует средства.  
- Формирует ответ (успех/ошибка):  
```json
{
  "status": "SUCCESS",
  "payment_id": "pay_789",
  "timestamp": "2024-03-20T12:00:00Z"
}
```

#### **Шаг 5: Ответ проходит через Clinkr обратно к ТСП**  
- Clinkr может:  
  - Логировать ответ.  
  - Добавлять метаданные (`X-Processing-Time: 120ms`).  
  - Фильтровать чувствительные данные (если настроено).  
- **Финальный ответ ТСП**:  
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "status": "SUCCESS",
  "payment_id": "pay_789",
  "timestamp": "2024-03-20T12:00:00Z"
}
```

---

### **3. Что важно учесть?**  
1. **Формат запроса/ответа**:  
   - Должен быть согласован между ТСП и SBP Processing (Swagger/OpenAPI-спецификация).  
2. **Ошибки**:  
   - Если токен невалиден → Clinkr вернет `401 Unauthorized`.  
   - Если платеж отклонен → SBP Processing возвращает `4xx/5xx` с описанием ошибки.  
3. **Idempotency (идемпотентность)**:  
   - Чтобы избежать дублей, ТСП должен передавать `X-Idempotency-Key` (или `transaction_id`).  
4. **Таймауты**:  
   - Clinkr/SBP Processing должны укладываться в ожидаемые временные рамки (иначе ТСП получит `504 Gateway Timeout`).  

---

### **Итог**  
- **ТСП** только отправляет запрос в Clinkr и получает ответ — не знает о внутренней маршрутизации.  
- **SBP Processing** получает уже аутентифицированный запрос и фокусируется на бизнес-логике.  
- **Clinkr** обеспечивает безопасность, маршрутизацию и контроль потока данных.  

Если нужны детали по конкретным настройкам Keycloak или Clinkr — уточните, какие аспекты интересуют!

---

