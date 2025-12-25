Вот таблица для запроса **UpdateAcsObject** (эндпоинт `/updateacs`):

| Параметр | Тип | Обязательность | Описание |
|----------|-----|----------------|----------|
| id | string (maxLength: 12) | да | Уникальный идентификатор транзакции в системе-источнике |
| originator | string (maxLength: 30) example: "ACS" | да | Система - источник/генератор сообщения |
| msgType | string (maxLength: 20) enum: ["updateacs"] | да | Тип сообщения - updateacs |
| acsRenderingTypeAcsInterface | string (maxLength: 2) example: "02" | нет | ACS interface, который будет представлен держателю карты: 01 = Native UI, 02 = HTML UI |
| acsRenderingTypeAcsUiTemplate | string (maxLength: 2) example: "01" | нет | Идентифицирует UI Template формата, который ACS представляет пользователю: 01 = Text, 02 = Single Select, 03 = Multi Select, 04 = OOB, 05 = HTML Other |
| threeDSServerTransID | string (maxLength: 36) example: "207a370d-2132-372e-9fe6-93738f8e7483" | нет | Уникальный идентификатор транзакции, присвоенный 3DS Server |
| acsTransID | string (maxLength: 36) example: "207a370d-2132-372e-9fe6-93738f8e7483" | нет | Уникальный идентификатор транзакции, присвоенный ACS |
| dsTransID | string (maxLength: 36) example: "207a370d-2132-372e-9fe6-93738f8e7483" | нет | Уникальный идентификатор транзакции, присвоенный DS |
| eci | string (maxLength: 2) example: "02" | нет | Payment System-specific value, предоставленный ACS для указания результата аутентификации |
| transStatus | string (maxLength: 1) example: "U" | нет | Статус транзакции: Y = Успешно, N = Не аутентифицировано, U = Не удалось выполнить, A = Попытка выполнена, C = Требуется челлендж, R = Отклонено |
| transStatusReason | string (maxLength: 2) example: "02" | нет | Причина статуса транзакции (например, 01 = Card authentication failed, 02 = Unknown Device и т.д.) |
| messageType | string (maxLength: 4) enum: ["RReq"] | нет | Тип EMV сообщения |
| messageCategory | string (maxLength: 2) example: "02" | нет | Категория сообщения: 01 = PA, 02 = NPA, 03–99 = Reserved |
| messageVersion | string (maxLength: 8) example: "2.1.0" | нет | Версия протокола |
| authenticationMethod | string (maxLength: 2) example: "02" | нет | Метод аутентификации, использованный ACS (например, 01 = Static Passcode, 02 = SMS OTP и т.д.) |
| authenticationType | string (maxLength: 2) example: "02" | нет | Тип аутентификации: 01 = Static, 02 = Dynamic, 03 = OOB |
| challengeCancel | string (maxLength: 2) example: "01" | нет | Индикатор отмены аутентификации (например, 01 = Cardholder selected “Cancel”, 02 = 3DS Requestor cancelled и т.д.) |
| date | string (maxLength: 19) example: "2019.12.11 10:31:14" | нет | Дата и время транзакции в формате yyyy.MM.dd HH:mm:ss |
| acpt | string (maxLength: 37) pattern: "^[0-9]{1,32}=[0-9]{4}$" example: "17000000000038008227=21643" | нет | Лимит авторизации в ПЦ КС и последние 4 цифры номера карты, разделенные знаком "=" |
| ean | string (maxLength: 13) example: "2130003426112" | нет | EAN карты |
| panToken | string (maxLength: 40) pattern: "^[0-9,A-F,a-f]{1,40}$" example: "d418caea266bef3bfe8bc5a1b88e704b0fa7344e" | нет | Токен для PAN карты |
| refPan | string (minLength: 1, maxLength: 64) | нет | Ссылка на номер карты |