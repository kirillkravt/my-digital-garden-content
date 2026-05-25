---
chat_id: 36b961e6-2795-4ba4-80d2-c8008a2a4ef2
title: Настройка Kafka для разных типов сообщений
message_count: 14
exported_at: 2026-05-25T10:17:49.681Z
---

# Настройка Kafka для разных типов сообщений

## 👤 **Kirill**

как настроить прием и отправку сообщений в один топик kafka через kafka consumer group триггер значение параметра type

---

## 🤖 **DeepSeek**

Для настройки приема и отправки сообщений в один топик Kafka через Kafka Consumer Group с использованием параметра `type`, вот подробное руководство:

## 1. Конфигурация Consumer с Consumer Group

```yaml
spring:
  kafka:
    consumer:
      bootstrap-servers: localhost:9092
      group-id: my-consumer-group
      auto-offset-reset: earliest
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.apache.kafka.common.serialization.StringDeserializer
    producer:
      bootstrap-servers: localhost:9092
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.apache.kafka.common.serialization.StringSerializer
```

## 2. Настройка с использованием параметра `type`

### Вариант 1: Использование `@KafkaListener` с фильтрацией по типу

```java
@Component
public class KafkaMessageProcessor {

    @KafkaListener(topics = "my-topic", groupId = "my-consumer-group")
    public void consumeMessage(@Payload String message,
                             @Header("type") String messageType) {
        
        // Обработка сообщений по типу
        switch(messageType) {
            case "ORDER_CREATED":
                processOrderCreated(message);
                break;
            case "USER_REGISTERED":
                processUserRegistered(message);
                break;
            case "PAYMENT_PROCESSED":
                processPayment(message);
                break;
            default:
                System.out.println("Unknown message type: " + messageType);
        }
    }
    
    private void processOrderCreated(String message) {
        // Логика обработки заказа
        System.out.println("Processing order: " + message);
        
        // Отправка ответа в тот же топик
        sendResponse("ORDER_PROCESSED", "Order processed successfully");
    }
    
    private void processUserRegistered(String message) {
        // Логика обработки регистрации пользователя
        System.out.println("Processing user registration: " + message);
        
        sendResponse("WELCOME_EMAIL_SENT", "Welcome email sent");
    }
    
    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;
    
    private void sendResponse(String type, String responseMessage) {
        Message<String> message = MessageBuilder
            .withPayload(responseMessage)
            .setHeader("type", type)
            .setHeader(KafkaHeaders.TOPIC, "my-topic")
            .build();
            
        kafkaTemplate.send(message);
    }
}
```

### Вариант 2: Использование Conditional Listeners

```java
@Component
public class TypedKafkaListeners {

    @KafkaListener(topics = "my-topic", 
                  groupId = "my-consumer-group",
                  condition = "headers['type'] == 'ORDER'")
    public void handleOrderMessages(String message) {
        System.out.println("Processing ORDER message: " + message);
        // Отправка ответа
        sendMessage("ORDER_RESPONSE", "Order response");
    }
    
    @KafkaListener(topics = "my-topic", 
                  groupId = "my-consumer-group",
                  condition = "headers['type'] == 'NOTIFICATION'")
    public void handleNotificationMessages(String message) {
        System.out.println("Processing NOTIFICATION message: " + message);
        sendMessage("NOTIFICATION_RESPONSE", "Notification processed");
    }
    
    @Autowired
    private KafkaTemplate<String, Object> kafkaTemplate;
    
    public void sendMessage(String type, Object payload) {
        kafkaTemplate.send("my-topic", createMessage(type, payload));
    }
    
    private Message<?> createMessage(String type, Object payload) {
        return MessageBuilder
            .withPayload(payload)
            .setHeader("type", type)
            .build();
    }
}
```

## 3. Конфигурация с использованием Spring Boot

```java
@Configuration
@EnableKafka
public class KafkaConfig {

    @Value("${spring.kafka.bootstrap-servers}")
    private String bootstrapServers;

    @Bean
    public ConsumerFactory<String, String> consumerFactory() {
        Map<String, Object> props = new HashMap<>();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(ConsumerConfig.GROUP_ID_CONFIG, "my-consumer-group");
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);
        
        return new DefaultKafkaConsumerFactory<>(props);
    }

    @Bean
    public ProducerFactory<String, String> producerFactory() {
        Map<String, Object> props = new HashMap<>();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        
        return new DefaultKafkaProducerFactory<>(props);
    }

    @Bean
    public KafkaTemplate<String, String> kafkaTemplate() {
        return new KafkaTemplate<>(producerFactory());
    }

    @Bean
    public ConcurrentKafkaListenerContainerFactory<String, String> kafkaListenerContainerFactory() {
        ConcurrentKafkaListenerContainerFactory<String, String> factory =
            new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(consumerFactory());
        factory.setReplyTemplate(kafkaTemplate());
        return factory;
    }
}
```

## 4. Пример с JSON и типами сообщений

```java
@Component
public class JsonMessageProcessor {

    @KafkaListener(topics = "my-topic", groupId = "my-consumer-group")
    public void processMessage(@Payload MessageDTO message,
                             @Header("type") String messageType) {
        
        // Обработка на основе типа сообщения
        switch(messageType) {
            case "CREATE":
                handleCreate(message);
                break;
            case "UPDATE":
                handleUpdate(message);
                break;
            case "DELETE":
                handleDelete(message);
                break;
        }
    }
    
    private void handleCreate(MessageDTO message) {
        // Логика создания
        MessageDTO response = new MessageDTO("CREATED", "Resource created");
        sendMessage("RESPONSE", response);
    }
    
    private void handleUpdate(MessageDTO message) {
        // Логика обновления
        MessageDTO response = new MessageDTO("UPDATED", "Resource updated");
        sendMessage("RESPONSE", response);
    }
    
    @Autowired
    private KafkaTemplate<String, Object> kafkaTemplate;
    
    private void sendMessage(String type, MessageDTO message) {
        kafkaTemplate.send(MessageBuilder
            .withPayload(message)
            .setHeader("type", type)
            .setHeader(KafkaHeaders.TOPIC, "my-topic")
            .build());
    }
    
    public static class MessageDTO {
        private String status;
        private String message;
        
        // конструкторы, геттеры, сеттеры
    }
}
```

## 5. Конфигурация для работы с разными типами

```yaml
spring:
  kafka:
    consumer:
      bootstrap-servers: localhost:9092
      group-id: my-consumer-group
      properties:
        spring.json.trusted.packages: "*"
        spring.json.value.default.type: com.example.MessageDTO
    listener:
      type: batch
    producer:
      bootstrap-servers: localhost:9092
```

## Ключевые моменты:

1. **Consumer Group** обеспечивает распределенную обработку сообщений
2. **Параметр type** в заголовках позволяет маршрутизировать сообщения
3. **Один топик** может содержать разные типы сообщений
4. **Фильтрация** происходит на уровне приложения
5. **Отправка ответов** в тот же топик с указанием типа

Этот подход позволяет эффективно использовать один топик для разных типов сообщений, сохраняя при этом преимущества Consumer Groups для масштабирования обработки.

---

## 👤 **Kirill**

Сформируй описание обработки исключения по отправке запроса на контроль доступного остатка в АБС

Реализуется механизм повторной отправки неуспешно доставленных уведомлений. При восстановлении работоспособности системы Core повторяет отправку уведомлений об успешно 
выполненной операции.
1. Делаем ретраи
 
 
2. Если в течение таймаута (30 секунд) не получаем ответ, то отказываем в операции и снимаем hold (формируем сообщение в Kafka ABS со признаком reject)

---

## 🤖 **DeepSeek**

## Описание обработки исключений при отправке запроса на контроль остатка в АБС

### 1. Архитектура механизма повторной отправки

```java
@Component
@Slf4j
public class AbsBalanceCheckService {

    private final KafkaTemplate<String, Object> kafkaTemplate;
    private final RetryTemplate retryTemplate;
    private final NotificationRetryRepository retryRepository;

    private static final long OPERATION_TIMEOUT_MS = 30000; // 30 секунд
    private static final String ABS_TOPIC = "abs-balance-check";
    private static final String ABS_RESPONSE_TOPIC = "abs-balance-response";
}
```

### 2. Конфигурация retry механизма

```java
@Configuration
public class RetryConfig {

    @Bean
    public RetryTemplate retryTemplate() {
        RetryTemplate retryTemplate = new RetryTemplate();
        
        // Экспоненциальная backoff политика
        ExponentialBackOffPolicy backOffPolicy = new ExponentialBackOffPolicy();
        backOffPolicy.setInitialInterval(1000);
        backOffPolicy.setMultiplier(2);
        backOffPolicy.setMaxInterval(10000);
        
        // Политика повторных попыток
        SimpleRetryPolicy retryPolicy = new SimpleRetryPolicy();
        retryPolicy.setMaxAttempts(3);
        
        retryTemplate.setBackOffPolicy(backOffPolicy);
        retryTemplate.setRetryPolicy(retryPolicy);
        
        return retryTemplate;
    }
}
```

### 3. Основной сервис обработки с retry логикой

```java
@Service
@Slf4j
public class BalanceCheckProcessor {

    @Autowired
    private KafkaTemplate<String, Object> kafkaTemplate;
    
    @Autowired
    private RetryTemplate retryTemplate;
    
    @Autowired
    private PendingOperationsCache pendingOperationsCache;

    public CompletableFuture<Boolean> checkBalanceWithRetry(String operationId, 
                                                           BalanceCheckRequest request) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                // Сохраняем операцию в кэш ожидания ответа
                pendingOperationsCache.savePendingOperation(operationId, request);
                
                // Выполняем отправку с retry механизмом
                return retryTemplate.execute(context -> {
                    int attempt = context.getRetryCount() + 1;
                    log.info("Attempt {} to send balance check for operation: {}", 
                            attempt, operationId);
                    
                    return sendBalanceCheckAndWait(operationId, request);
                    
                }, recoveryContext -> {
                    // Recovery callback - вызывается при исчерпании попыток
                    log.error("All retry attempts failed for operation: {}", operationId);
                    handleOperationFailure(operationId, request);
                    return false;
                });
                
            } catch (Exception e) {
                log.error("Unexpected error during balance check for operation: {}", 
                         operationId, e);
                handleOperationFailure(operationId, request);
                return false;
            }
        });
    }

    private Boolean sendBalanceCheckAndWait(String operationId, BalanceCheckRequest request) {
        try {
            // Отправка запроса в АБС
            Message<BalanceCheckRequest> message = MessageBuilder
                .withPayload(request)
                .setHeader(KafkaHeaders.TOPIC, ABS_TOPIC)
                .setHeader("operationId", operationId)
                .setHeader("timestamp", System.currentTimeMillis())
                .build();
                
            kafkaTemplate.send(message);
            log.info("Balance check request sent for operation: {}", operationId);
            
            // Ожидание ответа с таймаутом
            return waitForResponse(operationId);
            
        } catch (Exception e) {
            log.error("Failed to send balance check for operation: {}", operationId, e);
            throw new RuntimeException("Send failed", e);
        }
    }

    private Boolean waitForResponse(String operationId) {
        long startTime = System.currentTimeMillis();
        
        while (System.currentTimeMillis() - startTime < OPERATION_TIMEOUT_MS) {
            // Проверяем наличие ответа в кэше
            BalanceCheckResponse response = pendingOperationsCache.getResponse(operationId);
            
            if (response != null) {
                return processResponse(response);
            }
            
            try {
                Thread.sleep(100); // Небольшая пауза между проверками
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                throw new RuntimeException("Operation interrupted", e);
            }
        }
        
        // Таймаут превышен
        log.warn("Timeout exceeded for operation: {}", operationId);
        throw new RuntimeException("ABS response timeout");
    }
}
```

### 4. Обработчик ответов от АБС

```java
@Component
@Slf4j
public class AbsResponseListener {

    @Autowired
    private PendingOperationsCache pendingOperationsCache;

    @KafkaListener(topics = ABS_RESPONSE_TOPIC, groupId = "core-balance-group")
    public void handleBalanceResponse(@Payload BalanceCheckResponse response,
                                     @Header("operationId") String operationId) {
        log.info("Received balance response for operation: {}", operationId);
        
        try {
            // Сохраняем ответ в кэш для ожидающей операции
            pendingOperationsCache.saveResponse(operationId, response);
            
            // Если опера

---

## 👤 **Kirill**

сделай текстовое описание для Документа требований

---

## 🤖 **DeepSeek**

# Документ требований: Обработка исключений при взаимодействии с АБС

## 1. Введение

### 1.1. Назначение
Документ описывает требования к механизму обработки исключений и повторной отправки запросов при взаимодействии с системой АБС для контроля доступного остатка.

### 1.2. Цель
Реализация отказоустойчивого механизма обработки запросов к АБС с обеспечением гарантированной доставки и обработки временных сбоев.

## 2. Общее описание

### 2.1. Контекст
Система Core взаимодействует с АБС для проверки доступного остатка перед выполнением финансовых операций. При временной недоступности АБС требуется обеспечить повторную отправку запросов с последующей обработкой таймаутов.

### 2.2. Бизнес-требования
- Обеспечение бесперебойной обработки операций при временной недоступности А

---

## 👤 **Kirill**

только опиши процесс и функциональные требования

---

## 🤖 **DeepSeek**

# Документ требований: Обработка исключений при взаимодействии с АБС

## 1. Процесс обработки запросов к АБС

### 1.1. Основной процесс успешной обработки
1. **Инициация операции** в Core
2. **Формирование запроса** на проверку остатка в АБС
3. **Отправка запроса** в топик Kafka `abs-balance-check`
4. **Ожидание ответа** от АБС в топике `abs-balance-response`
5. **Получение ответа** в течение 30 секунд
6. **Обработка результата** и продолжение операции

### 1.2. Процесс при временных сбоях
1. **Обнаружение недоставки** запроса к АБС
2. **Автоматический повтор отправки** с экспоненциальной задержкой
3. **Максимум 3 попытки** отправки
4. **Интервалы повторов**: 1с, 2с, 4с
5. **Мониторинг восстановления** connectivity с АБС

### 1.3. Процесс при критическом таймауте
1. **Фиксация превышения** таймаута 30 секунд
2. **Прекращение повторных попыток**
3. **Снятие холда** по операции
4. **Формирование reject-сообщения** в топик ABS
5. **Отказ в выполнении** операции

## 2. Функциональные требования

### 2.1. Требования к механизму повторной отправки
- **FR-001**: Система должна выполнять автоматические повторные отправки при недоступности АБС
- **FR-002**: Максимальное количество попыток отправки - 3
- **FR-003**: Использование экспоненциального backoff между попытками
- **FR-004**: Логирование каждой попытки отправки с указанием номера попытки

### 2.2. Требования к обработке таймаутов
- **FR-005**: Таймаут ожидания ответа от АБС - 30 секунд
- **FR-006**: Автоматическое снятие холда при превышении таймаута
- **FR-007**: Формирование сообщения с признаком `reject` в топик ABS
- **FR-008**: Прекращение обработки операции при таймауте

### 2.3. Требования к кэшированию операций
- **FR-009**: Сохранение состояния ожидающих операций
- **FR-010**: Временное хранение запросов до получения ответа или таймаута
- **FR-011**: Быстрое восстановление состояния операций при перезапуске Core

### 2.4. Требования к обработке ответов
- **FR-012**: Асинхронная обработка ответов от АБС
- **FR-013**: Сопоставление ответов с исходными запросами по operationId
- **FR-014**: Продолжение обработки операции при успешном ответе от АБС

### 2.5. Требования к мониторингу
- **FR-015**: Логирование всех этапов обработки запроса
- **FR-016**: Мониторинг количества неудачных попыток отправки
- **FR-017**: Трекинг времени ответа от АБС
- **FR-018**: Алертинг при превышении порога ошибок

### 2.6. Требования к отказоустойчивости
- **FR-019**: Обработка сетевых сбоев при подключении к Kafka
- **FR-020**: Устойчивость к временной недоступности АБС
- **FR-021**: Гарантированная доставка сообщений при восстановлении connectivity
- **FR-022**: Идемпотентность обработки повторных сообщений

### 2.7. Требования к форматам сообщений
- **FR-023**: Использование заголовка `operationId` для корреляции запросов-ответов
- **FR-024**: Стандартный формат сообщения reject с указанием причины
- **FR-025**: Временные метки для отслеживания времени обработки

## 3. Критерии успешного выполнения

### 3.1. Критерии приемки
- Система выполняет 3 попытки отправки при сбоях
- Таймаут 30 секунд строго соблюдается
- Reject-сообщения формируются корректно
- Холды снимаются при таймаутах
- Нет потерь операций при перезапуске Core

### 3.2. Критерии производительности
- Время восстановления после сбоя АБС < 1 минуты
- Задержка между повторными попытками соответствует backoff политике
- Обработка reject-сообщений в реальном времени

---

## 👤 **Kirill**

сделай описание таймаута

---

## 🤖 **DeepSeek**

# Описание механизма таймаута при взаимодействии с АБС

## 1. Концепция таймаута

### 1.1. Определение
**Таймаут ожидания ответа от АБС** - это максимальный промежуток времени, в течение которого система Core ожидает ответ от АБС на запрос проверки остатка перед принятием решения об отказе в операции.

### 1.2. Назначение
- Предотвращение бесконечного ожидания ответа
- Обеспечение отзывчивости системы
- Автоматическое восстановление при сбоях АБС
- Гарантированное завершение операции (успех или отказ)

## 2. Параметры таймаута

### 2.1. Основные значения
```
Общий таймаут операции: 30 секунд
Таймаут между попытками: динамический (exponential backoff)
Максимальное время восстановления: 45 секунд (включая retry)
```

### 2.2. Временные границы
- **Старт**: момент отправки первого запроса в АБС
- **Окончание**: получение ответа или достижение 30-секундного лимита
- **Контрольные точки**: постоянный мониторинг времени выполнения

## 3. Процесс обработки таймаута

### 3.1. Нормальный сценарий
```
0 сек: Отправка запроса в АБС
1-29 сек: Ожидание ответа
<30 сек: Получение ответа → продолжение операции
```

### 3.2. Сценарий таймаута
```
0 сек: Отправка запроса в АБС
1-29 сек: Ожидание ответа (ответ не получен)
30 сек: Фиксация таймаута
30+ сек: Инициация процедуры отказа
```

### 3.3. Детальный процесс при таймауте

#### Фаза 1: Мониторинг (0-30 секунд)
- **Постоянная проверка** времени выполнения операции
- **Периодический опрос** наличия ответа в кэше
- **Параллельная обработка** входящих ответов от АБС

#### Фаза 2: Обнаружение таймаута (30 секунд)
```java
if (currentTime - startTime >= 30000) {
    triggerTimeoutProcedure();
}
```

#### Фаза 3: Обработка таймаута (30+ секунд)
1. **Прерывание ожидания** ответа от АБС
2. **Снятие холда** по текущей операции
3. **Формирование reject-сообщения**
4. **Уведомление** инициатора операции об отказе

## 4. Сообщение об отказе (reject)

### 4.1. Структура сообщения
```json
{
  "operationId": "uuid",
  "status": "rejected",
  "reason": "ABS_TIMEOUT",
  "timestamp": "2024-01-15T10:30:00Z",
  "message": "Превышено время ожидания ответа от АБС",
  "originalRequest": {...}
}
```

### 4.2. Признаки reject-сообщения
- **topic**: `abs-balance-check`
- **header**: `"type": "REJECT"`
- **header**: `"timeout": "true"`
- **header**: `"originalOperationId": "uuid"`

## 5. Взаимодействие с retry механизмом

### 5.1. Совместная работа
- **Retry механизм** работает ВНУТРИ общего таймаута 30 секунд
- **Общее время** всех попыток не превышает 30 секунд
- **Формула расчета**: `время_попыток + время_ожидания ≤ 30 сек`

### 5.2. Пример временной шкалы
```
Попытка 1: 0 сек (отправка) → ошибка через 2 сек
Попытка 2: 3 сек (отправка) → ошибка через 1 сек  
Попытка 3: 5 сек (отправка) → таймаут в 30 сек
Результат: OPERATION_TIMEOUT в 30 сек
```

## 6. Обработка пограничных ситуаций

### 6.1. Поздний ответ от АБС
- **Ситуация**: ответ приходит после фиксации таймаута
- **Действие**: игнорирование ответа, операция уже завершена как rejected
- **Логирование**: запись в лог о "позднем ответе"

### 6.2. Частичная доступность АБС
- **Ситуация**: АБС отвечает, но с большой задержкой (>30 сек)
- **Действие**: таймаут применяется строго, гарантируя SLAs

### 6.3. Восстановление связи во время таймаута
- **Ситуация**: АБС восстанавливается на 25-й секунде
- **Действие**: отправка запроса (если есть попытки), но общий лимит 30 сек сохраняется

## 7. Мониторинг и метрики

### 7.1. Ключевые метрики
- `abs_timeout_count` - количество срабатываний таймаута
- `abs_response_time` - время ответа АБС (успешные запросы)
- `abs_operation_duration` - общее время операции
- `abs_timeout_rate` - процент операций с таймаутом

### 7.2. Алертинг
- **Предупреждение**: >5% таймаутов за 5 минут
- **Критично**: >20% таймаутов за 5 минут
- **Действие**: уведомление команды поддержки АБС

## 8. Обоснование значения 30 секунд

### 8.1. Бизнес-требования
- **Баланс** между надежностью и отзывчивостью
- **Опыт пользователя**: операции не должны "зависать"
- **Системные требования**: освобождение ресурсов

### 8.2. Технические ограничения
- **Сетевые задержки**: учет времени передачи данных
- **Время обработки АБС**: типичное время ответа 1-5 секунд
- **Запас надежности**: 6x от нормального времени ответа

Таймаут 30 секунд обеспечивает оптимальный баланс между предоставлением достаточного времени для восстановления АБС и поддержанием отзывчивости системы для конечных пользователей.

---

## 👤 **Kirill**

где хранятся query параметр запроса

---

## 🤖 **DeepSeek**

# Хранение query параметров запроса при взаимодействии с АБС

## 1. Места хранения query параметров

### 1.1. Временное хранение (во время обработки)

#### **In-Memory кэш операций**
```java
// ConcurrentHashMap для thread-safe доступа
Map<String, PendingOperation> pendingOperations = new ConcurrentHashMap<>();

class PendingOperation {
    String operationId;
    BalanceCheckRequest originalRequest; // содержит query параметры
    long startTime;
    int attemptCount;
    String status; // PENDING, COMPLETED, TIMEOUT
}
```

#### **Локальное хранилище состояния**
- **Время жизни**: только на период обработки запроса
- **Доступ**: в рамках одного экземпляра Core
- **Очистка**: при получении ответа или таймауте

### 1.2. Постоянное хранение (для восстановления)

#### **База данных Core**
```sql
CREATE TABLE pending_abs_operations (
    operation_id VARCHAR(50) PRIMARY KEY,
    request_body JSON, -- query параметры запроса
    request_headers JSON,
    created_at TIMESTAMP,
    expires_at TIMESTAMP, -- TTL 30 секунд + запас
    status VARCHAR(20),
    attempt_count INT
);
```

#### **Key-Value хранилище (Redis)**
```redis
# Ключ: abs_operation:{operationId}
HSET abs_operation:12345 
    "request" '{"account":"...","amount":1000,"currency":"USD"}'
    "headers" '{"type":"BALANCE_CHECK","timestamp":"..."}'
    "start_time" "1672531200"
    "attempts" "1"
    "expire_at" "1672531230"
```

## 2. Ст

---

## 👤 **Kirill**

в хэдере или body?

---

## 🤖 **DeepSeek**

# Хранение параметров запроса: Header vs Body

## 1. Рекомендуемый подход: **BODY**

### 1.1. Основные параметры в Body
```json
{
  "operationId": "123e4567-e89b-12d3-a456-426614174000",
  "accountNumber": "40817810099910004321",
  "amount": 15000.50,
  "currency": "RUB",
  "operationType": "PAYMENT",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### 1.2. Headers для служебной информации
```java
Message<BalanceCheckRequest> message =

---

