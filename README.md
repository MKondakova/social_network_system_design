# System design для социальной сети

Этот репозиторий создается в рамках курса по System design.

## Формализация требований

Описание функциональности, предоставленное бизнесом:

> - публикация постов из путешествий с фотографиями, небольшим описанием и привязкой к конкретному месту путешествия;
> - оценка и комментарии постов других путешественников;
> - подписка на других путешественников, чтобы следить за их активностью;
> - поиск популярных мест для путешествий и просмотр постов с этих мест в виде ТОПа мест по странам и городам;
> - общение с другими путешественниками в личных сообщениях;
> - просмотр ленты других путешественников

К функциональным требованиям добавим:

- существует общая лента постов путешественников, на которых он подписан
- можно посмотреть историю своих лайков
- в сообщениях можно обмениваться только текстом и изображениями
- в ленте показывается 20 постов, потом она догружается

Нефункциональные требования:

- Аудитория:
  - пользователи по всему миру
  - DAO около 1_000_000
  - пользователи будут делать посты в путешествиях, то есть пачками, 4 поста в день во время путешествия. В остальное время в среднем будут открывать ленту раз в день и ставить около 15 лайков и 5 комментариев. Вести переписку в среднем час в день по сообщению в минуту c 5ю собеседниками
- Сезонность: в основном отпуска приходятся на май-сентябрь. Вне сезона каждые выходные (6 дней в месяц) в отпуск уходит 10% пользователей, в сезон каждый пользователь уйдет на неделю, то есть нарузка повысится в 3,8 раза.
- Хранить данные нужно всегда, потеря их критична
- Лимиты и ограничения:
  - у пользователя будет не больше 1000 подписок
  - для пользователя возможна публикация не более 100 постов в день
- Временные ограничения:
  - пост должен публиковаться за 1 секунд
  - сообщения должны доходить за 0.5 секунды
  - лента должна загружаться не дольше 5 секунд
- Доступность приложения: приложение может быть недоступно не более суток в год, то есть 99.5%

## Оценка нагрузки

### RPS

RPS_read_lenta = 1_000_000 * 3 (сколько загрузок ленты) / 86400 = 35

RPS_read_messages = 1_000_000 * 5 (сколько открывалось диалогов) * 50 (сообщений в них)  / 86400 = 2900

RPS_read_comments = 35 (rps ленты) * 20 (столько постов в ленте) = 700

RPS_write_post = 1_000_000 * 0.1 * 4 * (6/30.5) / 86400 = 1 - вне сезона, 4 в сезон

RPS_write_messages = 1_000_000 * 60 (сообщений в день) / 86400 =  695

RPS_write_like = 1_000_000 * 15 / 86400 = 174

RPS_write_comments = 1_000_000 * 5 / 86400 =  58

### Трафик

T_read_lenta = 35 * 20 постов в ленте * (500 kB картинка + (500B текст + 8B геолокация + идентификатор пользователя 8B + 4B лайки + 10 * 100B комментарии)) = 350mB картинок + 1mB

T_read_messages = 2900 * 100B = 290kB

T_read_comments = 700 * 10 комментариев к каждому посту * (100B текст + 4B идентификатор пользователя) = 728 kB

T_write_post = 1 * (500 kB картинка + (500B текст + 8B геолокация + идентификатор пользователя 8B)) = 0,5 mB картинок + 0,5 kB (вне сезона), в 4 раза больше в сезон

T_write_messages =  695 * 100B = 70kB

T_write_like = 174 * 4B идентификатор пользователя = 700B

T_write_comments =  58 * (100B текст + 4B идентификатор пользователя) = 6 kB

## Оценка дисков для хранения данных за год

### Посты, комменты и пр

Data_per_year = 86400 * 365 * ((5/12 (сезон)*8 kB + 7/12\*6.5 kB) + 728kB)= 23 TB

IOPS ~ 35 + 1 + 174 + 58 + 700 = 968 (в сезон увеличивается объем данных из-за большого количества картинок в постах, частота запросов увеличивается незначительно)

| Тип  | Объем   | IOPS | Пропускная способность |
| ---- | ------- | ---- | ---------------------- |
| HDD  | до 32ТБ | 100  | 100 МБ/с               |

Получается 12 HDD дисков по 2 TB

| Тип        | Объем    | IOPS  | Пропускная способность |
| ---------- | -------- | ----- | ---------------------- |
| SSD (SATA) | до 100ТБ | 1 000 | 500 МБ/с               |

Получается 1 SSD(SATA) диск на 32 TB
Проще поддерживать диск, их хватит больше,чем на год из-за округления.

### Информация о пользоватях

Допустим в системе регистрируется 1 тыс пользователей каждый день или 0.1 в секунду

Data_per_year = 86400 * 365 * (0.1 * (2b (один символ) *(256(email)+100(username)+100(avatar_url)) = 300 mB

IOPS ~ 35 + 0.1 + 700 = 736 (информация о пользователе будет запрашиваться при чтении каждого поста и коммента)

Можно объединить чаты и информацию о пользователе и хранить на одном диске

### Чаты 

Data_per_year = 86400 * 365 * 70kB = 2,5 TB

IOPS ~ 2900 + 695 = 3595

| Тип        | Объем    | IOPS  | Пропускная способность |
| ---------- | -------- | ----- | ---------------------- |
| SSD (SATA) | до 100ТБ | 1 000 | 500 МБ/с               |

Получается 2 SSD(SATA) диска на 1 TB и 2 на 512 GB

| Тип        | Объем   | IOPS   | Пропускная способность |
| ---------- | ------- | ------ | ---------------------- |
| SSD (nVME) | до 30ТБ | 10 000 | 3 ГБ/с                 |

Получается 1 SSD(nVME) диска на 4 TB

Дешевле взять 3 sata диска

### Медиа

Data_per_year = 86400 * 365 * 500kb * ((5/12 (сезон)*4 + 7/12\*1) + 695 (сообщений) * 0.1 + 0.1 (аватарки)) = 1123 TB

IOPS ~ (35*20 (посты) + 0.1 * 695 (сообщения)) * 2 (за аватарки) = 1539

| Тип        | Объем    | IOPS  | Пропускная способность |
| ---------- | -------- | ----- | ---------------------- |
| SSD (SATA) | до 100ТБ | 1 000 | 500 МБ/с               |

Нужно 12 таких дисков

