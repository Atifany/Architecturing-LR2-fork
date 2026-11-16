## **Форк Бордаков Михаил** 

# Теория
Кэширование — это временное хранение часто используемых данных в быстром хранилище, чтобы не обращаться к более медленному источнику при каждом запросе. Обычно кэш размещается между приложением и основной базой данных.<br>
<br>
Типы кэширования могут быть направлены на запись и/или на чтение.<br>
Типы кэширования:<br>
Cache-aside		Приложение сначала проверяет кэш, затем БД; при промахе пишет результат в кэш<br>
Read-through	Приложение обращается только к кэшу, а кэш сам получает данные из БД<br>
Write-through	Данные одновременно пишутся в кэш и БД<br>
Write-behind	Сначала пишется в кэш, затем асинхронно в БД<br>
Write-around	Данные пишутся сразу в БД, минуя кэш<br>
<br>
Стратегии вытеснения кэша<br>
Когда память кэша заканчивается, часть данных нужно удалить. Для этого используются политики вытеснения.<br>
LRU	Наименее недавно использованные данные<br>
LFU	Наименее часто используемые данные<br>
FIFO	Самые старые данные по времени добавления<br>
TTL-based	Данные с истёкшим сроком жизни<br>
<br>
Redis — это быстрое in-memory хранилище типа «ключ–значение». Оно часто используется как кэш или хранилище сессий.<br>
<br>
KeyDB — совместимая с Redis реализация хранилища, которая поддерживает похожий протокол и команды. Поэтому работа с Redis и KeyDB в приложении обычно выглядит одинаково.<br>
<br>
Типы данных в Redis<br>
String	Строка, число, сериализованный объект<br>
List	Упорядоченный список строк<br>
Hash	Набор полей и значений<br>
Set		Неупорядоченное множество уникальных строк<br>
ZSet	Упорядоченное множество с весами<br>
<br>
Терминальная утилита для работы с Redis: redis-cli<br>
<br>
Cache-aside — стратегия, при которой приложение само управляет кэшем и БД.<br>
Алгоритм:<br>
1. Проверить Redis<br>
2. Если данные есть — вернуть из кэша<br>
3. Если данных нет — обратиться к БД<br>
4. Сохранить результат в Redis<br>
5. Вернуть данные пользователю<br>

# Инструкция Часть1
Для запуска в папке LR1_part1 запустить контейнер:<br>
```docker compose up -d```<br>
Зайти в контейнер командой:<br>
```docker exec -it keydb bash```<br>
Зайти в утилиту keydb-cli:<br>
```keydb-cli```<br>
Установить значение ипрочитать его:<br>
```set <key> <value>```<br>
```get <key>```<br>
Установить TTL, посмотреть его и снять:<br>
```expire <key> time_in_seconds```<br>
```ttl <key>```<br>
```persist <key>``` или ```ttl <key> -1```<br>
HashSet или hset - словарь пар ключ-значение.<br>
```hset atifany:1:info name "Mikhail" age "24"```<br>
```hgetall atifany:1:info```<br>
```hget atifany:1:info name```<br>
List - список значений или ключ-знач/знач/знач...<br>
Для записи rpush - справа, lpush - слева. Для удаления - rpop/lpop<br>
```rpush atifany:1:list param1 param2 param3```<br>
```lrange atifany:1:list 0 -1```<br>
```lpop atifany:1:list```<br>
Set - список уникальных значний, ключ-Uзнач/Uзнач/Uзнач<br>
команды: sadd, srem, smembers, sismember<br>
Zset - упорядоченный список значений. ключ-вес+знач/вес+знач/вес+знач...<br>
команды: zadd, zrem, zrange <key> from to <withscores>, smembers, sismember<br>
Значение с наибольшим весом:<br>
```zrange <key> -1 -1 withscores```<br>
Изменить вес значения:<br>
```zincrby <key> <weight> <value>```<br>
Удаление значений:<br>
DEL - синхронное удление<br>
UNLINK - асинхронное удаление (для больших объемов, что не морозить основной процесс)<br>
Показать все содержимое keydb (выполнять в контейнере):<br>
```
redis-cli --scan --pattern "*" | while read key; do
    type=$(redis-cli TYPE "$key")
    echo "=== $key [$type] ==="
    case "$type" in
        string) redis-cli GET "$key";;
        hash)   redis-cli HGETALL "$key";;
        list)   redis-cli LRANGE "$key" 0 -1;;
        set)    redis-cli SMEMBERS "$key";;
        zset)   redis-cli ZRANGE "$key" 0 -1 WITHSCORES;;
    esac
done
```
<br>

# Инструкция Часть2
Для запуска user-service необходимо собрать весь проект через maven (в корне проекта):<br>
```mvn clean install -DskipTests```<br>
В папке dockercompose запустить контейнеры базы данных и редиса:<br>
```docker compose up -d```<br>
Далее запустить собранную программу (в корне проекта):<br>
```java -jar user-service/target/user-service-0.0.1-SNAPSHOT.jar```<br>
Создам пользователя в базе с помощью GET /users/{id} и попытаюсь его прочитать несколько раз подряд:<br>
![alt text](img/image-1.png)<br>
Вижу, что при первом чтении cache miss, а при последующих cache hit. Также после 60с (установленный TTL для записей в кэше)<br>
Вижу снова cache miss, так как кэш сбросился.<br>
	



## **Описание проекта**

Этот проект представляет собой мульти-модульный монорепозиторий, в котором собраны сервисы, используемые в лабораторных работах.

Модуль `user-service` представляет собой **REST API** для управления пользователями. 
Реализованы **CRUD операции** (создание, чтение, обновление, удаление).

Модуль `notification-service` представляет собой сервис, управляющий нотификациями. 
В данный момент никак не связан с другими компонентами системы.

Модуль `shared-contracts` содержит в себе контракты, общие для компонентов системы.

---

## **Технологии**

| Технология      | Использование |
|----------------|--------------|
| **Spring Boot** | Разработка REST API |
| **Spring Data JPA** | Работа с БД |
| **PostgreSQL** | Хранение данных |
| **Flyway** | Миграции БД |
| **MapStruct** | Маппинг Entity ↔ DTO |
| **Spring Validation** | Валидация входных данных |
| **OpenAPI (Swagger UI)** | Документирование API |

---

## **Запуск через Docker Compose**

**Шаги:**

1. **Склонируйте репозиторий**
   ```bash
   git clone https://gitflic.ru/project/constromanov/arhitekturirovanie-lr.git
   cd arhitekturirovanie-lr
   ```

2. **Запустите контейнеры**
   ```bash
   cd dockercompose
   docker-compose up -d
   ```

3. **Запустите нужные сервисы**

Выполните `mvn spring-boot:run` для `user-service` через Intellij:

![img.png](img/springbootrunuapp.png)

Выполните `mvn spring-boot:run` для `notification-service` через Intellij:

![img.png](img/springbootrunnotifapp.png)

Или нажмите на кнопку запуска приложения:

![img.png](img/run.png)

**После запуска user-service API доступно по:** `http://localhost:8080`  
**Swagger UI:** `http://localhost:8080/swagger-ui.html`  
**Документация OpenAPI:** `http://localhost:8080/api-docs`  

---

## **Структура проекта**

```
📁 папка, в которой лежит проект
├── 📁 user-service/              # сервис для работы с пользователями
│   ├── 📁 src/main/java/com/misis/archapp/user/ # исходный код сервиса
│   ├── 📁 resources/             # ресурсы, конфиг. файлы
│   ├── Dockerfile
│   └── pom.xml                    # файл для менеджмента зависимостей сервиса
│
├── 📁 notification-service/       # сервис отправки уведомлений
│   ├── 📁 src/main/java/com/misis/archapp/notification/  # исходный код сервиса
│   ├── 📁 resources/              # ресурсы, конфиг. файлы
│   ├── Dockerfile
│   └── pom.xml                    # файл для менеджмента зависимостей сервиса
│
├── 📁 shared-contract/            # общие контракты (события, DTO)
│   ├── 📁 src/main/java/com/misis/archapp/contract/
│   ├── 📁 resources/
│   ├── pom.xml
│
└── pom.xml                        # родительский файл с зависимостями
```

### Структура модуля User Service

```
📁 user-service/src/main/java/com/misis/archapp/user
├── 📁 configuration
│   └── RedisConfiguration.java          # Конфигурация Redis-клиента
│
├── 📁 controller
│   └── UserRestApiController.java       # REST API для работы с пользователями
│
├── 📁 db
│   ├── User.java                        # JPA-сущность пользователя
│   └── UserRepository.java              # Репозиторий Spring Data JPA
│
├── 📁 dto
│   ├── UserCreateDTO.java               # DTO для создания пользователя
│   ├── UserUpdateDTO.java               # DTO для обновления пользователя
│   ├── UserDTO.java                     # DTO для возврата пользователю
│   └── 📁 mapper
│       └── UserMapper.java              # MapStruct-маппер User <-> DTO
│
├── 📁 service
│   ├── UserService.java                 # Бизнес-логика
│   ├── 📁 cache
│   │   └── UserCacheService.java        # Отдельный слой кэширования
│   └── package-info.java
│
├── UserServiceApplication.java          # Точка входа
├── 📁 resources
│   ├── application.properties           # Конфигурация приложения
│   └── 📁 db.migration                  # Flyway миграции
```

### Структура модуля Notification Service

```
📁 notification-service/src/main/java/com/misis/archapp/notification
├── 📁 service
│   ├── NotificationService.java            # Логика отправки уведомлений
│   └── package-info.java
└── NotificationServiceApplication.java     # Точка входа
```
---
