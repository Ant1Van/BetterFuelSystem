# Better Fuel System for Cyberpunk 2077

[**Русское описание ниже**](#russian-description)

The **Better Fuel System** is a comprehensive modification for Cyberpunk 2077 designed to enhance the driving experience by introducing realistic fuel management. This mod integrates dynamic fuel consumption, distinct fuel types, and interactive gas stations into the game world, ensuring that every journey through Night City requires careful planning and resource management.

## ⚠️ Project Status: Development Discontinued

I have officially decided to cease the development and maintenance of this project. This decision stems from a combination of limited personal time, shifting priorities, and my recent transition from Windows to macOS, which prevents me from further testing or updating the mod.

The source code is now fully released to the community under the MIT License. I encourage any interested developers or modders to take over the project, implement new features, or maintain compatibility with future game updates.

## Core Functionality

The mod implements a sophisticated fuel consumption model where fuel is not merely a static value but a dynamic resource. Consumption rates are calculated in real-time based on the vehicle's engine RPM and current speed, rewarding efficient driving and penalizing aggressive acceleration.

| Feature | Description |
| :--- | :--- |
| **Dynamic Consumption** | Fuel usage scales with engine load and vehicle performance. |
| **Fuel Types** | Vehicles are categorized into **Regular** and **Premium** fuel users, affecting costs and compatibility. |
| **Persistent State** | Fuel levels for player-owned vehicles are saved to a local database, persisting across game sessions. |
| **Engine Management** | Vehicles will automatically stall when fuel is depleted and require refueling to restart. |
| **Visual Indicators** | A custom HUD element provides real-time fuel telemetry while operating a vehicle. |

## Interactive Gas Stations

Night City is populated with interactive gas stations, clearly marked on the world map and minimap with custom icons. When positioned near a fuel pump, players can access a dedicated refueling interface.

| Component | Functionality |
| :--- | :--- |
| **Refuel Popup** | A custom UI allowing players to select fuel types and adjust the desired fuel volume. |
| **Map Integration** | Custom map pins and tooltips for Petrochem stations across the city and Badlands. |
| **Economic System** | Refueling costs are calculated based on fuel type and volume, integrated with the player's Eurodollars. |

## Technical Requirements

To ensure proper functionality, the following dependencies must be installed and updated to their latest versions:

| Dependency | Purpose |
| :--- | :--- |
| [**ArchiveXL**](https://www.nexusmods.com/cyberpunk2077/mods/4198) | Handles custom resources and entity injection. |
| [**Codeware**](https://www.nexusmods.com/cyberpunk2077/mods/7780) | Provides the underlying UI framework and localization support. |
| [**Cyber Engine Tweaks**](https://www.nexusmods.com/cyberpunk2077/mods/107) | Powers the core Lua logic and scripting engine. |
| [**Input Loader**](https://www.nexusmods.com/cyberpunk2077/mods/4575) | Manages custom keybindings and controller inputs. |
| [**redscript**](https://www.nexusmods.com/cyberpunk2077/mods/1511) | Enables deep integration with the game's native script systems. |

## Controls and Installation

The refueling interface can be accessed by holding the **[Z]** key on a keyboard or the **[Left Stick]** on a gamepad while the vehicle is stationary near a gas station.

To install the mod, extract the contents of the `BetterFuelSystem` folder directly into your Cyberpunk 2077 main installation directory. Ensure that the folder structure remains intact (e.g., `bin/` and `r6/` folders should merge with existing ones).

---

<a name="russian-description"></a>
# Better Fuel System для Cyberpunk 2077

**Better Fuel System** — это комплексная модификация для Cyberpunk 2077, разработанная для углубления игрового процесса через внедрение реалистичной системы управления топливом. Мод интегрирует динамический расход топлива, различные типы горючего и интерактивные заправочные станции в мир игры, превращая каждую поездку по Найт-Сити в задачу, требующую планирования ресурсов.

## ⚠️ Статус проекта: Разработка прекращена

Я официально объявляю о прекращении разработки и поддержки данного проекта. Это решение вызвано нехваткой личного времени, сменой приоритетов и моим переходом с Windows на macOS, что делает невозможным дальнейшее тестирование и обновление мода.

Исходный код полностью передается сообществу под лицензией MIT. Я призываю всех заинтересованных разработчиков и моддеров продолжать развитие проекта, внедрять новые функции или поддерживать совместимость с будущими обновлениями игры.

## Основные возможности

Мод реализует сложную модель потребления, где топливо является динамическим ресурсом. Скорость расхода рассчитывается в реальном времени на основе оборотов двигателя (RPM) и текущей скорости транспорта, поощряя аккуратное вождение и наказывая за агрессивную езду.

| Возможность | Описание |
| :--- | :--- |
| **Динамический расход** | Потребление топлива масштабируется в зависимости от нагрузки на двигатель и скорости. |
| **Типы топлива** | Транспорт разделен на категории, использующие **Обычный** или **Премиум** бензин. |
| **Сохранение данных** | Уровни топлива для личного транспорта сохраняются в локальной базе данных между сессиями. |
| **Управление двигателем** | Транспорт глохнет при пустом баке и требует заправки для повторного запуска. |
| **Визуальные индикаторы** | Кастомный элемент HUD предоставляет телеметрию топлива в реальном времени при вождении. |

## Интерактивные заправки

Найт-Сити наполнен интерактивными заправочными станциями, отмеченными на карте мира и миникарте специальными иконками. Находясь рядом с колонкой, игрок может вызвать выделенный интерфейс заправки.

| Компонент | Функциональность |
| :--- | :--- |
| **Меню заправки** | Пользовательский интерфейс для выбора типа топлива и регулировки объема заправки. |
| **Интеграция с картой** | Кастомные метки и подсказки для станций Petrochem по всему городу и в Пустошах. |
| **Экономика** | Стоимость заправки рассчитывается исходя из типа и объема топлива, списываясь с баланса игрока. |

## Технические требования

Для корректной работы модификации необходимо установить и обновить до последних версий следующие зависимости:

| Зависимость | Назначение |
| :--- | :--- |
| [**ArchiveXL**](https://www.nexusmods.com/cyberpunk2077/mods/4198) | Управление кастомными ресурсами и инъекция сущностей. |
| [**Codeware**](https://www.nexusmods.com/cyberpunk2077/mods/7780) | Обеспечивает работу интерфейса и поддержку локализации. |
| [**Cyber Engine Tweaks**](https://www.nexusmods.com/cyberpunk2077/mods/107) | Ядро для работы Lua-логики и скриптового движка. |
| [**Input Loader**](https://www.nexusmods.com/cyberpunk2077/mods/4575) | Управление кастомными привязками клавиш и геймпада. |
| [**redscript**](https://www.nexusmods.com/cyberpunk2077/mods/1511) | Глубокая интеграция с нативными скриптовыми системами игры. |

## Управление и установка

Меню заправки вызывается удержанием клавиши **[Z]** на клавиатуре или **[Левого стика]** на геймпаде, когда транспорт неподвижен и находится рядом с заправкой.

Для установки мода извлеките содержимое папки `BetterFuelSystem` непосредственно в корневой каталог установки Cyberpunk 2077. Убедитесь, что структура папок сохранена (например, папки `bin/` и `r6/` должны объединиться с существующими).
