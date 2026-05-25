---
chat_id: 421262f0-9bec-4509-8ed0-fa11dd31b742
title: Таблица и пример запроса C2BCredit
message_count: 2
exported_at: 2026-05-25T05:37:13.174Z
---

# Таблица и пример запроса C2BCredit

## 👤 **Kirill**

Сделай таблицу параметров по выполнению операции C2BCredit и пример запроса

---

## 🤖 **DeepSeek**

### Таблица параметров для выполнения операции C2BCredit

| Параметр                     | Тип данных | Обязательность | Описание                                                                 |
|------------------------------|------------|----------------|--------------------------------------------------------------------------|
| `operationType`              | string     | Обязательно    | Тип операции: `credit` (зачисление)                                      |
| `operationFlow`              | string     | Обязательно    | Поток операции: `C2B`                                                   |
| `scenarioType`               | string     | Обязательно    | Тип сценария: `C2BPL` (оплата по платежной ссылке СБП)                  |
| `qrcId`                      | string     | Обязательно    | Идентификатор платежной ссылки СБП (макс. 32 символа)                   |
| `amount`                     | object     | Обязательно    | Сумма операции: `amount` (в копейках), `currencyCode` (валюта, например, `RUB`) |
| `mainParticipant`            | object     | Обязательно    | Данные основного участника (получателя):<br>- `account` (номер и тип счета)<br>- `legal` (название юр. лица)<br>- `merchant` (идентификатор и название ТСП)<br>- `bankId` (идентификатор банка) |
| `secondParticipant`          | object     | Обязательно    | Данные второго участника (плательщика):<br>- `account` (номер и тип счета)<br>- `bankId` (идентификатор банка)<br>- `id` (идентификатор клиента, например, телефон)<br>- ФИО (`lastName`, `firstName`, `middleName`) |
| `externalOperationId`        | string     | Обязательно    | Идентификатор операции во внешней системе                                |
| `paymentPurpose`             | string     | Опционально    | Назначение платежа (макс. 210 символов)                                 |
| `clearingDate`               | string     | Опционально    | Дата расчетов операции (формат `YYYY-MM-DD`)                            |
| `ipsOperationDate`           | string     | Опционально    | Операционный день обработки операции (формат `YYYY-MM-DD`)              |
| `operationDate`              | string     | Обязательно    | Дата операции (формат `YYYY-MM-DDTHH:MM:SS.sssZ`)                       |
| `fees`                       | array      | Опционально    | Комиссии:<br>- `id` (`fee` или `payerFee`)<br>- `amount` (сумма комиссии) |
| `ipsSuspectIndicator`        | string     | Опционально    | Индикатор подозрительной операции СБП (16 символов)                     |
| `paymentParameters`          | object     | Опционально    | Дополнительные атрибуты операции (например, `ips_126_recipient_auth_type`) |
| `agentSourceIndicator`       | boolean    | Опционально    | Индикатор инициации операции сотрудником банка                          |

---

### Пример запроса для выполнения операции C2BCredit

```json
{
  "operationType": "credit",
  "operationFlow": "C2B",
  "scenarioType": "C2BPL",
  "qrcId": "AD03610425360300b4ubOp6511E4F998",
  "amount": {
    "amount": 100000,
    "currencyCode": "RUB"
  },
  "mainParticipant": {
    "legal": {
      "name": "OOO Ромашка"
    },
    "merchant": {
      "id": "MA0000000002",
      "name": "Магазин у дома"
    },
    "account": {
      "number": "40702810111111111111",
      "type": "LegalAcct"
    },
    "bankId": "100000000001"
  },
  "secondParticipant": {
    "account": {
      "number": "40817810099910000000",
      "type": "Bnk"
    },
    "bankId": "100000000002",
    "id": {
      "value": "79112903214",
      "type": "phone"
    },
    "lastName": "Иванов",
    "firstName": "Иван",
    "middleName": "Иванович"
  },
  "agentSourceIndicator": false,
  "externalOperationId": "AS767309075948D5A41D4351CFD739F1",
  "paymentPurpose": "Оплата товаров и услуг",
  "clearingDate": "2022-01-13",
  "ipsOperationDate": "2022-01-13",
  "operationDate": "2022-01-13T08:33:39.082Z",
  "fees": [
    {
      "id": "fee",
      "amount": {
        "amount": 100000,
        "currencyCode": "RUB"
      }
    }
  ],
  "ipsSuspectIndicator": "0000000000000000",
  "paymentParameters": {
    "ips_126_recipient_auth_type": "FulAth"
  }
}
```

### Примечания:
1. Обязательные поля должны быть заполнены, иначе запрос вернет ошибку `400` или `422`.
2. Для успешного выполнения операции необходимо корректно указать `qrcId` и реквизиты участников.
3. Даты (`clearingDate`, `ipsOperationDate`, `operationDate`) должны соответствовать формату.
4. Дополнительные параметры (`paymentParameters`) могут быть использованы для передачи специфичных атрибутов операции.

---

