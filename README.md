# Демо стенд для вебинара "Настройка отказоустойчивой архитектуры в Облаке"
[Ссылка на вебинар](https://youtu.be/40FZ27fUaKo?si=LztW4EYUkcF2lYFC)

Репозиторий содержит [исходный код демо-приложения](app), [terraform спецификацию окружения](terraform/app)
и [terraform спецификацию Яндекс Танка](terraform/tank).

* [Инструкции по сборке приложения](app/README.md)
* [Инструкции по развертыванию окружения](terraform/README.md)

## Схема кластера

![cluster](architecture_diagram.png)

## Сценарии использования демо-стенда
1. **Сбой ВМ** 
    * Вручную удалите ВМ из Instance Group
    * Load Balancer перестанет подавать трафик на удаленную ВМ, а Instance Group создаст новую ВМ взамен удаленной
    * В момент удаления ВМ до выведения ее из-под балансировки можно будет наблюдать несколько connection timeout.
2. **Сбой приложения**
    * Выполните скрипт [fail_random_host.sh](fail_random_host.sh), для того чтобы случайная копия приложения начала отвечать на все запросы кодом 503 (UNAVAILABLE)
    * Instance Group обнаружит сбой приложения, выведет его из-под балансировки и перезагрузит ВМ, после чего ВМ будет добавлена обратно под балансировщик и Instance Group полностью восстановится.
    * В момент сбоя приложения до выведения инстанса из-под балансировки можно будет наблюдать всплеск ошибок с кодом 503.
3. **Отключение зоны доступности**
    * В настройках Instance Group в разделе **Распределение** отключите одну из зон доступности.
    * Instance Group начнет удалять два инстанса, одновременно создавая два новых инстанса в оставшейся зоне доступности.
    * Во время обновления Instance Group возможны ошибки connection timeout при выведении инстансов из-под балансировки.
4. **Обновление приложения**
    * В настройках Instance Group в шаблоне ВМ измените настройки docker-контейнера: поменяйте тег образа с `v1` на `v2`.
    * Instance Group сразу начнет удалять два инстанса, а оставшиеся два перейдут в состояние `RUNNING_OUTDATED`, и продолжат работать
    пока не будет запущено достаточно ВМ для того, чтобы их удалить. Одновременно с этим начнут создаваться новые ВМ.
    * Во время обновления Instance Group возможны ошибки connection timeout при выведении инстансов из-под балансировки.
5. **Масштабирование конфигурации БД**
    * В настройках Managed PostgreSQL кластера измените *flavor* кластера с s2.small на s2.medium.
    * Кластер начнет обновлять хосты, начиная с read-only реплики.
    * В процессе обновления можно будет наблюдать два пика ошибок с кодом 500, которые происходят во время переключения мастера на другой хост.

## Полезные ссылки
* [Документация Managed PostgreSQL](https://cloud.yandex.ru/docs/managed-postgresql/)
* [Документация Load Balancer](https://cloud.yandex.ru/docs/load-balancer/)
* [Документация Container Registry](https://cloud.yandex.ru/docs/container-registry/)
* [Документация Container Optimized Image](https://cloud.yandex.ru/docs/container-registry/concepts/coi)
* [Типы масштабирования Instance Group](https://cloud.yandex.ru/docs/compute/concepts/instance-groups/scale)
* [Яндекс.Танк в Маркетплейсе](https://cloud.yandex.ru/marketplace/products/f2ec3euo68vni32pl7aj)
* [Документация terraform](https://www.terraform.io/docs/providers/yandex/index.html)
