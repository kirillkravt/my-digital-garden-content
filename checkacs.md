Вот таблица для запроса **checkacs** (CheckAcs2Object) из вашей спецификации:

| Параметр | Тип | Обязательность | Описание |
|----------|-----|----------------|----------|
| id | string (maxLength: 12) | да | Уникальный идентификатор транзакции в системе-источнике |
| originator | string (maxLength: 30) | да | Система - источник/генератор сообщения |
| issInstId | string (maxLength: 4, example: '0010') | да | Номер института-эмитента в ПЦ КС |
| acqInstId | string (maxLength: 4, example: '0010') | да | Номер института-эквайера в ПЦ КС |
| msgType | string (enum: ['checkacs']) | да | Тип сообщения - checkacs |
| transType | string (maxLength: 4, example: '777') | да | Тип транзакции |
| date | string (maxLength: 19, example: '2019.12.11 10:31:14') | да | Дата, время совершения транзакции в формате yyyy.MM.dd HH:mm:ss |
| paymentSystem | string (maxLength: 30, example: 'VISA') | нет | Платежная система - VISA, MC, MIR |
| bdasPageHref | string (maxLength: 2048, example: 'https://acs.cardstandard.ru/acs/v2/xFgshc') | нет | Полный адрес страницы, на которой был вызван bdas |
| bdasPageHostname | string (maxLength: 45, example: 'acs.cardstandard.ru') | нет | Имя хоста, на котором был вызван bdas |
| bdasDisplayHeight | string (maxLength: 6, example: '650') | нет | Свойство Screen.Height, возвращает высоту экрана посетителя в пикселях |
| bdasDisplayWidth | string (maxLength: 6, example: '480') | нет | Свойство Screen.Width, возвращает ширину экрана посетителя в пикселях |
| bdasDisplayColorDepth | string (maxLength: 2, example: '24') | нет | Свойство colorDepth, возвращает битовую глубину цветовой палитры |
| bdasDisplayAvailLeft | string (maxLength: 6, example: '0') | нет | Возвращает первый доступный пиксель от левой стороны экрана |
| bdasDisplayAvailWidth | string (maxLength: 6, example: '320') | нет | Ширина экрана пользователя служащая непосредственно для вывода информации (т.е. ширина без размера таких элементов браузера как панель задач, полоса прокрутки и т.д.) |
| bdasDisplayAvailTop | string (maxLength: 6, example: '0') | нет | Количество пикселей рабочего стола, доступных для работы (например, без высоты меню Пуск на windows) |
| bdasDisplayAvailHeight | string (maxLength: 6, example: '570') | нет | Высота экрана пользователя служащая непосредственно для вывода информации (т.е. высота без размера таких элементов браузера как панель задач, полоса прокрутки и т.д.) |
| bdasDeviceBrowser | string (maxLength: 1024, example: 'Netscape Mozilla') | нет | Название браузера |
| bdasDevicePlatform | string (maxLength: 1024, example: 'Linux armv7l') | нет | С помощью свойства platform можно узнать для какой платформы скомпилирован браузер пользователя (т.е. фактически позволяет узнать ОС, которую использует пользователь) |
| bdasLang | string (maxLength: 8, example: 'ru-RU') | нет | Код языка |
| bdasUserAgent | string (maxLength: 2048, example: 'Mozilla/5.0 (Linux; Android 6.0; CRO-L22 Build/HUAWEICRO-L22; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/77.0.3865.73 Mobile Safari/537.36') | нет | С помощью свойства userAgent можно вернуть целиком заголовок user-agent, который браузер посылает серверу при запросе страницы. Заголок user-agent содержит исчерпывающую информацию о браузере пользователя. |
| bdasJavaEnabled | string (maxLength: 10, example: 'true') | нет | С помощью метода javaEnabled() можно узнать включена ли поддержка Java в браузере пользователя. Если метод вернул true значит поддержка Java включена, если false выключена. |
| bdasTimezone | string (maxLength: 5, example: '-540') | нет | Cмещение часового пояса в минутах для текущей локали |
| bdasCanvasFingerprint | string (maxLength: 100, example: '7DD987F846400079F4B03C058365A4869047B4A0') | нет | Хэш от невидимой картинки, отрисованной на форме (хэш зависит от видеокарты, настроек графики устройства и т.д.) |
| bdasBotPhantomParamsCall | string (maxLength: 10, example: 'false') | нет | Один из параметров для выявления эмулятора js - phantomjs (true = выявлено) |
| bdasBotPhantomParamsPh | string (maxLength: 10, example: 'true') | нет | Один из параметров для выявления эмулятора js - phantomjs (true = выявлено) |
| bdasBotPhantomParamsPhantomas | string (maxLength: 10, example: 'false') | нет | Один из параметров для выявления эмулятора js - phantomjs (true = выявлено) |
| bdasBotPhantomParamsProfile | string (maxLength: 10, example: 'false') | нет | Один из параметров для выявления эмулятора js - phantomjs (true = выявлено) |
| bdasBotPhantomParamsUserAgent | string (maxLength: 10, example: 'false') | нет | Один из параметров для выявления эмулятора js - phantomjs (true = выявлено) |
| bdasBotPhantomParamsPlugins | string (maxLength: 10, example: 'false') | нет | Один из параметров для выявления эмулятора js - phantomjs (true = выявлено) |
| bdasBotUseSeleniumWebdriver | string (maxLength: 10, example: 'false') | нет | Один из параметров для выявления эмулятора js - webdriver (true = выявлено) |
| bdasBotUseSeleniumUse | string (maxLength: 10, example: 'false') | нет | Один из параметров для выявления эмулятора js - selenium (true = выявлено) |
| bdasBotRhino | string (maxLength: 10, example: 'false') | нет | Один из параметров для выявления эмулятора js - rhino (true = выявлено) |
| bdasBotCouchjs | string (maxLength: 10, example: 'false') | нет | Один из параметров для выявления эмулятора js - couchjs (true = выявлено) |
| bdasBotNodejs | string (maxLength: 10, example: 'true') | нет | Один из параметров для выявления эмулятора js - nodejs (true = выявлено) |
| bdasBotPhantomParamsOuterSize | string (maxLength: 10, example: 'true') | нет | Один из параметров для выявления эмулятора js - phantomjs (true = выявлено) |
| bdasClientIp | string (maxLength: 45, example: '127.0.0.1') | нет | ip-адрес клиента (браузера) |
| bdasLocalIP | string (maxLength: 45, example: '127.0.0.1') | нет | Локальный адрес хоста на сетевом интерфейсе. Если адрес определить не удалось, то значение "none". |
| bdasToken | string (maxLength: 2048) | нет | Идентификатор пользовательской сессии |
| threeDSServerRefNumber | string (maxLength: 32, example: '3DS_LOA_SER_MOMD_020100_00068') | нет | Unique identifier assigned by the EMVCo secretariat upon testing and approval |
| threeDSServerOperatorID | string (maxLength: 32, example: '2200570101') | нет | DS assigned 3DS Server identifier. Each DS can provide a unique ID to each 3DS Server on an individual basis. |
| threeDSRequestorID | string (maxLength: 35, example: '2201380100') | нет | DS assigned 3DS Requestor identifier. Each DS will provide a unique ID to each 3DS Requestor on an individual basis. |
| threeDSRequestorName | string (maxLength: 40, example: 'MIR DS 2.0') | нет | DS assigned 3DS Requestor name. Each DS will provide a unique name to each 3DS Requestor on an individual basis. |
| dsReferenceNumber | string (maxLength: 32, example: '3DS_LOA_DIS_MOMD_020100_00066') | нет | EMVCo-assigned unique identifier to track approved DS |
| sdkReferenceNumber | string (maxLength: 32, example: 'SDK_LOA_DIS_XXXX_777777_77777') | нет | Identifies the vendor and version for the 3DS SDK that is integrated in a 3DS Requestor App, assigned by EMVCo when the 3DS SDK is approved |
| threeDSServerTransID | string (maxLength: 36, example: '207a370d-2132-372e-9fe6-93738f8e7483') | нет | Universally unique transaction identifier assigned by the 3DS Server to identify a single transaction. Canonical format as defined in IETF RFC 4122. |
| dsTransID | string (maxLength: 36, example: '207a370d-2132-372e-9fe6-93738f8e7483') | нет | Universally unique transaction identifier assigned by the DS to identify a single transaction. Canonical format as defined in IETF RFC 4122. |
| dsURL | string (maxLength: 2048, example: 'https://www.otpbank.ru/') | нет | URL of the DS to which the ACS will send the RReq if a challenge occurs |
| sdkTransID | string (maxLength: 36, example: '207a370d-2132-372e-9fe6-93738f8e7483') | нет | Universally unique transaction identifier assigned by the 3DS SDK to identify a single transaction. Canonical format as defined in IETF RFC 4122. |
| threeDSServerURL | string (maxLength: 2048, example: 'https://ds1.mirconnect.ru:8443/miraccept/rreq') | нет | Fully qualified URL of the 3DS Server to which the DS will send the RReq message after the challenge has completed. Incorrect formatting will result in a failure to deliver the transaction results via the RReq message. |
| threeRIInd | string (maxLength: 2, example: '05') | нет | 3RI Indicator. Indicates the type of 3RI request. |
| notificationURL | string (maxLength: 256, example: 'https://ds2.mirconnect.ru/miraccept/pares?msgid=1391583723') | нет | Fully qualified URL of the system that receives the CRes message or Error Message. The CRes message is posted by the ACS through the Cardholder browser at the end of the challenge and receipt of the RRes message. |
| pan | string (maxLength: 19, example: '5370040000639697') | нет | Account number that will be used in the authorisation request for payment transactions. May be represented by PAN, token. |
| acpt | string (maxLength: 37, pattern: '^[0-9]{1,32}=[0-9]{4}$', example: '17000000000038008227=21643') | нет | Лимит авторизации в ПЦ КС и последние 4 цифры номера карты, разделенные знаком равно |
| ean | string (maxLength: 13, example: '2130003426112') | нет | EAN карты |
| panToken | string (maxLength: 40, pattern: '^[0-9,A-F,a-f]{1,40}$', example: 'd418caea266bef3bfe8bc5a1b88e704b0fa7344e') | нет | Токен для PAN карты |
| refPan | string (minLength: 1, maxLength: 64) | нет | Ссылка на номер карты |
| expDate | string (maxLength: 4, example: '2312') | нет | Expiry Date of the PAN or token supplied to the 3DS Requestor by the Cardholder (YYMM) |
| account | string (maxLength: 32, example: '17000000000038008227') | нет | Лимит авторизации в ПЦ КС |
| acctInfoChAccAgeInd | string (maxLength: 2, example: '01') | нет | Cardholder Account Age Indicator. Length of time that the cardholder has had the account with the 3DS Requestor. |
| acctInfoChAccChange | string (maxLength: 8, example: '20200214') | нет | Cardholder Account Change. Date that the cardholder’s account with the 3DS Requestor was last changed, including Billing or Shipping address, new payment account, or new user(s) added (YYYYMMDD). |
| acctInfoChAccChangeInd | string (maxLength: 2, example: '03') | нет | Cardholder Account Change Indicator. Length of time since the cardholder’s account information with the 3DS Requestor was last changed, including Billing or Shipping address, new payment account, or new user(s) added. |
| acctInfoChAccDate | string (maxLength: 8, example: '20200214') | нет | Cardholder Account Date. Date that the cardholder opened the account with the 3DS Requestor (YYYYMMDD) |
| acctInfoChAccPwChange | string (maxLength: 8, example: '20200214') | нет | Cardholder Account Password Change. Date that cardholder’s account with the 3DS Requestor had a password change or account reset (YYYYMMDD). |
| acctInfoChAccPwChangeInd | string (maxLength: 2, example: '02') | нет | Cardholder Account Password Change Indicator. Indicates the length of time since the cardholder’s account with the 3DS Requestor had a password change or account reset. |
| acctInfoNbPurchaseAccount | string (maxLength: 4, example: '5') | нет | Cardholder Account Purchase Count. Number of purchases with this cardholder account during the previous six months. |
| acctInfoProvisionAttemptsDay | string (maxLength: 3, example: '1') | нет | Number of Provisioning Attempts Day. Number of Add Card attempts in the last 24 hours. |
| acctInfoTxnActivityDay | string (maxLength: 3, example: '3') | нет | Number of Transactions Day. Number of transactions (successful and abandoned) for this cardholder account with the 3DS Requestor across all payment accounts in the previous 24 hours. |
| acctInfoTxnActivityYear | string (maxLength: 3, example: '0') | нет | Number of Transactions Year. Number of transactions (successful and abandoned) for this cardholder account with the 3DS Requestor across all payment accounts in the previous year. |
| acctInfoPaymentAccAge | string (maxLength: 8, example: '20190606') | нет | Payment Account Age. Date that the payment account was enrolled in the cardholder’s account with the 3DS Requestor (YYYYMMDD). |
| acctInfoPaymentAccInd | string (maxLength: 2, example: '05') | нет | Payment Account Age Indicator. Indicates the length of time that the payment account was enrolled in the cardholder’s account with the 3DS Requestor. |
| acctInfoShipAddressUsage | string (maxLength: 8, example: '20180512') | нет | Shipping Address Usage. Date when the shipping address used for this transaction was first used with the 3DS Requestor (YYYYMMDD). |
| acctInfoShipAddressUsageInd | string (maxLength: 2, example: '03') | нет | Shipping Address Usage Indicator. Indicates when the shipping address used for this transaction was first used with the 3DS Requestor. |
| acctInfoShipNameIndicator | string (maxLength: 2, example: '01') | нет | Shipping Name Indicator. Indicates if the Cardholder Name on the account is identical to the shipping Name used for this transaction. |
| acctInfoSuspiciousAccActivity | string (maxLength: 2, example: '01') | нет | Suspicious Account Activity. Indicates whether the 3DS Requestor has experienced suspicious activity (including previous fraud) on the cardholder account. |
| acctID | string (maxLength: 64, example: 'VasyaPupkin89') | нет | Cardholder Account Identifier. Additional information about the account optionally provided by the 3DS Requestor. |
| acctType | string (maxLength: 2, example: '02') | нет | Indicates the type of account. For example, for a multi-account card product. |
| threeDSRequestorPriorAuthenticationInfoThreeDSReqPriorAuthData | string (maxLength: 2048, example: '???') | нет | 3DS Requestor Prior Transaction Authentication Data. |
| threeDSRequestorPriorAuthenticationInfoThreeDSReqPriorAuthMethod | string (maxLength: 2, example: '02') | нет | 3DS Requestor Prior Transaction Authentication Method. Mechanism used by the Cardholder to previously authenticate to the 3DS Requestor. |
| threeDSRequestorPriorAuthenticationInfoThreeDSReqPriorAuthTimestamp | string (maxLength: 12, example: '20200217120900') | нет | 3DS Requestor Prior Transaction Authentication Timestamp. Date and time in UTC of the prior cardholder authentication (YYYYMMDDHHMM). |
| threeDSRequestorPriorAuthenticationInfoThreeDSReqPriorRef | string (maxLength: 36, example: '???') | нет | 3DS Requestor Prior Transaction Reference. This data element provides additional information to the ACS to determine the best approach for handing a request. |
| threeDSRequestorAuthenticationInfoThreeDSReqAuthData | string (maxLength: 2048, example: '???') | нет | 3DS Requestor Authentication Data. Data that documents and supports a specific authentication process. |
| threeDSRequestorAuthenticationInfoThreeDSReqAuthMethod | string (maxLength: 2, example: '02') | нет | 3DS Requestor Authentication Method. Mechanism used by the Cardholder to authenticate to the 3DS Requestor. |
| threeDSRequestorAuthenticationInfoThreeDSReqAuthTimestamp | string (maxLength: 12, example: '20200217120900') | нет | 3DS Requestor Authentication Timestamp. Date and time in UTC of the cardholder authentication (YYYYMMDDHHMM). |
| threeDSReqAuthMethodInd | string (maxLength: 2, example: '01') | нет | 3DS Requestor Authentication Method Verification Indicator. Value that represents the signature verification performed by the DS on the mechanism (e.g., FIDO) used by the cardholder to authenticate to the 3DS Requestor. |
| threeDSRequestorChallengeInd | string (maxLength: 2, example: '01') | нет | 3DS Requestor Challenge Indicator. Indicates whether a challenge is requested for this transaction. |
| threeDSRequestorDecMaxTime | string (maxLength: 5, example: '60') | нет | Indicates the maximum amount of time that the 3DS Requestor will wait for an ACS to provide the results of a Decoupled Authentication transaction (in minutes) |
| threeDSRequestorDecReqInd | string (maxLength: 1, example: 'N') | нет | Indicates whether the 3DS Requestor requests the ACS to utilise Decoupled Authentication and agrees to utilise Decoupled Authentication if the ACS confirms its use. (Y/N) |
| email | string (maxLength: 254, example: 'johndoe@gmail.com') | нет | The email address associated with the account that is either entered by the Cardholder, or is on file with the 3DS Requestor. |
| cardholderName | string (maxLength: 45, example: 'JOHN DOE') | нет | Name of the Cardholder. |
| homePhoneCc | string (maxLength: 3, example: '???') | нет | Country Code |
| homePhoneSubscribe | string (maxLength: 15, example: '???') | нет | Subscriber sections of the number |
| mobilePhoneCc | string (maxLength: 3, example: '???') | нет | Country Code |
| mobilePhoneSubscribe | string (maxLength: 15, example: '???') | нет | Subscriber sections of the number |
| workPhoneCc | string (maxLength: 3, example: '???') | нет | Country Code |
| workPhoneSubscribe | string (maxLength: 15, example: '???') | нет | Subscriber sections of the number |
| billAddrCity | string (maxLength: 50, example: 'Novosibirsk') | нет | The city of the Cardholder billing address associated with the card used for this purchase. |
| billAddrCountry | string (maxLength: 3, example: '643') | нет | The country of the Cardholder billing address associated with the card used for this purchase. Shall be the ISO 3166-1 numeric three-digit country code |
| billAddrLine1 | string (maxLength: 50, example: '???') | нет | First line of the street address or equivalent local portion of the Cardholder billing address associated with the card used for this purchase. |
| billAddrLine2 | string (maxLength: 50, example: '???') | нет | Second line of the street address or equivalent local portion of the Cardholder billing address associated with the card used for this purchase. |
| billAddrLine3 | string (maxLength: 50, example: '???') | нет | Third line of the street address or equivalent local portion of the Cardholder billing address associated with the card used for this purchase. |
| billAddrPostCode | string (maxLength: 16, example: '630055') | нет | ZIP or other postal code of the Cardholder billing address associated with the card used for this purchase. |
| billAddrState | string (maxLength: 3, example: '???') | нет | The state or province of the Cardholder billing address associated with the card used for this purchase. Should be the country subdivision code defined in ISO 3166-2 |
| shipAddrCity | string (maxLength: 50, example: 'Novosibirsk') | нет | City portion of the shipping address requested by the Cardholder. |
| shipAddrCountry | string (maxLength: 3, example: '643') | нет | Country of the shipping address requested by the Cardholder. ISO 3166-1 three-digit country code |
| shipAddrLine1 | string (maxLength: 50, example: '???') | нет | First line of the street address or equivalent local portion of the shipping address requested by the Cardholder. |
| shipAddrLine2 | string (maxLength: 50, example: '???') | нет | The second line of the street address or equivalent local portion of the shipping address requested by the Cardholder. |
| shipAddrLine3 | string (maxLength: 50, example: '???') | нет | The third line of the street address or equivalent local portion of the shipping address requested by the Cardholder. |
| shipAddrPostCode | string (maxLength: 16, example: '150010') | нет | The ZIP or other postal code of the shipping address requested by the Cardholder. |
| shipAddrState | string (maxLength: 3, example: '???') | нет | The state or province of the shipping address associated with the card being used for this purchase. Should be the country subdivision code defined in ISO 3166-2. |
| addrMatch | string (maxLength: 1, example: 'N') | нет | Indicates whether the Cardholder Shipping Address and Cardholder Billing Address are the same. Y/N |
| payTokenInd | string (maxLength: 10, example: 'true') | нет | EMV Payment Token Indicator. A value of True indicates that the transaction was de-tokenised prior to being received by the ACS. |
| payTokenSource | string (maxLength: 2, example: '02') | нет | EMV Payment Token Source. This data element will be populated by the system residing in the 3-D Secure domain where the de-tokenization occurs. |
| purchaseAmount | string (maxLength: 48, example: '150000') | нет | Purchase amount in minor units of currency with all punctuation removed. |
| purchaseCurrency | string (maxLength: 3, example: '810') | нет | Currency in which purchase amount is expressed. |
| purchaseExponent | string (maxLength: 1, example: '2') | нет | Minor units of currency as specified in the ISO 4217 currency exponent. |
| purchaseDate | string (maxLength: 14, example: '20200217131425') | нет | Date and time of the purchase, expressed in UTC (YYYYMMDDHHMMSS) |
| recurringExpiry | string (maxLength: 8, example: '20200314') | нет | Recurring Expiry. Date after which no further authorisations shall be performed (YYYYMMDD). |
| recurringFrequency | string (maxLength: 4, example: '15') | нет | Recurring Frequency. Indicates the minimum number of days between authorisations. |
| sdkAppID | string (maxLength: 36, example: '207a370d-2132-372e-9fe6-93738f8e7483') | нет | Universally unique ID created upon all installations and updates of the 3DS Requestor App on a Consumer Device. |
| sdkMaxTimeout | string (maxLength: 2, example: '10') | нет | Indicates maximum amount of time (in minutes) for all exchanges. Greater than or = 05 |
| whiteListStatus | string (maxLength: 1, example: 'Y') | нет | Whitelist Status. Enables the communication of trusted beneficiary/whitelist status between the ACS, the DS and the 3DS Requestor. |
| whiteListStatusSource | string (maxLength: 2, example: '02') | нет | Whitelist Status Source. This data element will be populated by the system setting Whitelist Status. |
| purchaseInstalData | string (maxLength: 3, example: '20') | нет | Instalment Payment Data. Indicates the maximum number of authorisations permitted for instalment payments. |
| threeDSRequestorAuthenticationInd | string (maxLength: 2, example: '01') | нет | Indicates the type of Authentication request. |
| threeDSRequestorURL | string (maxLength: 2048, example: 'https://www.otpbank.ru/') | нет | Fully qualified URL of 3DS Requestor website or customer care site. This data element provides additional information to the receiving 3-D Secure system if a problem arises and should provide contact information. |
| acquirerBIN | string (maxLength: 11, example: '522530') | нет | Acquiring institution identification code as assigned by the DS receiving the AReq message. |
| acquirerMerchantID | string (maxLength: 35, example: 'J003453') | нет | Acquirer-assigned Merchant identifier. This may be the same value that is used in authorisation requests sent on behalf of the 3DS Requestor and is represented in ISO 8583 formatting requirements. |
| deviceChannel | string (maxLength: 2, example: '01') | нет | Indicates the type of channel interface being used to initiate the transaction. |
| mcc | string (maxLength: 4, example: '6012') | нет | DS-specific code describing the Merchant’s type of business, product or service. |
| merchantCountryCode | string (maxLength: 3, example: '643') | нет | Country Code of the Merchant. This value correlates to the Merchant Country Code as defined by each Payment System or DS. |
| merchantName | string (maxLength: 40, example: 'Yandex Taxi') | нет | Merchant name assigned by the Acquirer or Payment System. |
| messageCategory | string (maxLength: 2, example: '01') | нет | Identifies the category of the message for a specific use case. |
| messageVersion | string (maxLength: 8, example: '2.1.0') | нет | Protocol version identifier. Actual is 2.1.0 |
| merchantRiskIndicatorDeliveryEmailAddress | string (maxLength: 254, example: 'xxx@noname.org') | нет | Delivery Email Address. For Electronic delivery, the email address to which the merchandise was delivered. |
| merchantRiskIndicatorDeliveryTimeframe | string (maxLength: 2, example: '01') | нет | Delivery Timeframe. |
| merchantRiskIndicatorGiftCardAmount | string (maxLength: 15, example: '123') | нет | Gift Card Amount. For prepaid or gift card purchase, the purchase amount total of prepaid or gift card(s) in major units |
| merchantRiskIndicatorGiftCardCount | string (maxLength: 2, example: '3') | нет | Gift Card Count. For prepaid or gift card purchase, total count of individual prepaid or gift cards/codes purchased. |
| merchantRiskIndicatorGiftCardCurr | string (maxLength: 3, example: '840') | нет | Gift Card Currency. For prepaid or gift card purchase, the currency code of the card as defined in ISO 4217 |
| merchantRiskIndicatorPreOrderDate | string (maxLength: 8, example: '20200114') | нет | Pre-Order Date. For a pre-ordered purchase, the expected date that the merchandise will be available (YYYYMMDD). |
| merchantRiskIndicatorPreOrderPurchaseInd | string (maxLength: 2, example: '01') | нет | Pre-Order Purchase Indicator. |
| merchantRiskIndicatorReorderItemsInd | string (maxLength: 2, example: '01') | нет | Reorder Items Indicator. |
| merchantRiskIndicatorShipIndicator | string (maxLength: 2, example: '05') | нет | Shipping Indicator. |
| threeDSCompInd | string (maxLength: 1, example: 'N') | нет | Indicates whether the 3DS Method successfully completed. |
| browserAcceptHeader | string (maxLength: 2048, example: 'text/html,application/xhtml xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8') | нет | Exact content of the HTTP accept headers as sent to the 3DS Requestor from the Cardholder’s browser. |
| browserIP | string (maxLength: 45, example: '127.0.0.1') | нет | IP address of the browser as returned by the HTTP headers to the 3DS Requestor. |
| browserJavaEnabled | string (maxLength: 10, example: 'true') | нет | Boolean that represents the ability of the cardholder browser to execute Java. true/false |
| browserJavascriptEnabled | string (maxLength: 10, example: 'true') | нет | Boolean that represents the ability of the cardholder browser to execute JavaScript. |
| browserLanguage | string (maxLength: 8, example: 'ru') | нет | Value representing the browser language as defined in IETF BCP47. Returned from navigator.language property. |
| browserColorDepth | string (maxLength: 2, example: '48') | нет | Value representing the bit depth of the colour palette for displaying images, in bits per pixel. Obtained from Cardholder browser using the screen.colorDepth property. |
| browserScreenHeight | string (maxLength: 6, example: '640') | нет | Total height of the Cardholder’s screen in pixels. Value is returned from the screen.height property. |
| browserScreenWidth | string (maxLength: 6, example: '480') | нет | Total width of the cardholder’s screen in pixels. Value is returned from the screen.width property |
| browserTZ | string (maxLength: 5, example: '0') | нет | Time difference between UTC time and the Cardholder browser local time, in minutes. |
| browserUserAgent | string (maxLength: 2048, example: 'Mozilla/5.0 (Linux; Android 9; SM-J730FM Build/PPR1.180610.011; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/73.0.3683.90 Mobile Safari/537.36') | нет | Exact content of the HTTP user-agent header. |
| deviceRenderOptionsSdkInterface | string (maxLength: 2, example: '02') | нет | Lists all of the SDK Interface types that the device supports for displaying specific challenge user interfaces within the SDK. |
| deviceRenderOptionsSdkUiType01 | string (enum: ['true']) | нет | Text. true/false |
| deviceRenderOptionsSdkUiType02 | string (enum: ['true']) | нет | Single Select. true/false |
| deviceRenderOptionsSdkUiType03 | string (enum: ['true']) | нет | Multi Select. true/false |
| deviceRenderOptionsSdkUiType04 | string (enum: ['true']) | нет | OOB. true/false |
| deviceRenderOptionsSdkUiType05 | string (enum: ['true']) | нет | HTML Other. true/false |
| nspkTotalScore | string (maxLength: 6, example: '50') | нет | Суммарный скоринговый бал по операции аутентификации |
| nspkUserDeviceScore | string (maxLength: 6, example: '10') | нет | Скоринговый бал по устройству пользователя |
| nspkMerchantAccountScore | string (maxLength: 6, example: '5') | нет | Скоринговый бал по учетной записи клиента в магазине |
| nspkMerchantScore | string (maxLength: 6, example: '10') | нет | Скоринговый бал торговой точки (магазина/торговца) |
| nspkClientScore | string (maxLength: 6, example: '7') | нет | Скоринговый бал по активности клиента |
| nspkTransactionScore | string (maxLength: 6, example: '6') | нет | Скоринговый бал по транзакции |
| nspkMerchantTransactionsScore | string (maxLength: 6, example: '10') | нет | Скоринговый бал по деталям транзакции |
| broadInfo | string (maxLength: 4096) | нет | Unstructured information sent between the 3DS Server, the DS and the ACS |
| messageType | string (maxLength: 4, enum: ['AReq']) | нет | Тип EMV сообщения |
| panRangeIds | array (items: PanRangeId) | нет | Список идентификаторов карточных диапазонов |

Хотите, чтобы я продолжил с остальными запросами (`check`, `update`, `advice` и др.) в той же табличной форме?