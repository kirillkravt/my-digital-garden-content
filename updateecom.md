Вот таблица для `UpdateEcomObject` в точном порядке, как в спецификации:

## UpdateEcomObject — Уведомление о результате ecom-операции

| Параметр | Тип | Обязательность | Описание |
|----------|-----|---------------|----------|
| id | string (maxLength: 12) | **Да** | Уникальный идентификатор транзакции в системе-источнике |
| originator | string (maxLength: 30) | **Да** | Система - источник/генератор сообщения |
| msgType | string (enum: 'updateecom') | **Да** | Тип сообщения - update |
| actionCode | string (maxLength: 6) | **Да** | Код ответа авторизационной системы |
| approvalCode | string (maxLength: 6) | Нет | Код авторизации транзакции (только в случае успеха) |
| date | string (maxLength: 19, example: '2019.12.11 10:31:14') | **Да** | Дата, время совершения транзакции в формате yyyy.MM.dd HH:mm:ss |
| acpt | string (maxLength: 37, pattern: '^[0-9]{1,32}=[0-9]{4}$', example: '17000000000038008227=21643') | Нет | Лимит авторизации в ПЦ КС и последние 4 цифры номера карты, разделенные знаком равно |
| ean | string (maxLength: 13, example: '2130003426112') | Нет | EAN карты |
| panToken | string (maxLength: 40, pattern: '^[0-9,A-F,a-f]{1,40}$', example: 'd418caea266bef3bfe8bc5a1b88e704b0fa7344e') | Нет | Токен для PAN карты |
| refPan | string (minLength: 1, maxLength: 64) | Нет | Ссылка на номер карты |
| rAcpt | string (maxLength: 37, pattern: '^[0-9]{1,32}=[0-9]{4}$', example: '17000000000038008227=21643') | Нет | Лимит авторизации в ПЦ КС и последние 4 цифры номера карты получателя, разделенные знаком равно |
| rEan | string (maxLength: 13, example: '2130003426112') | Нет | EAN карты получателя |
| rPanToken | string (maxLength: 40, pattern: '^[0-9,A-F,a-f]{1,40}$', example: 'd418caea266bef3bfe8bc5a1b88e704b0fa7344e') | Нет | Токен для PAN карты получателя |
| rRefPan | string (minLength: 1, maxLength: 64) | Нет | Ссылка на номер карты получателя |