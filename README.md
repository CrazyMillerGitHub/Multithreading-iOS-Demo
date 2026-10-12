# Изучение многопоточности в iOS

![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg) ![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg) ![Xcode](https://img.shields.io/badge/Xcode-27.0-green.svg)

## О проекте

Учебное iOS-приложение (Swift/UIKit, **MVVM на макросе `@Observable`**) для изучения
основ многопоточности. Приложение показывает баланс, умеет «тратить» деньги и
запускать асинхронный «денежный поток». Внутри намеренно оставлены учебные
проблемы многопоточности, которые студентам предстоит найти, объяснить и
исправить (см. раздел [Учебные баги](#учебные-баги-не-исправлять)).

### Основные особенности:
- Архитектура **MVVM**: `MainViewModel` на макросе **`@Observable`** (Swift Observation, iOS 17+).
- Обновление UI через мост **`withObservationTracking`** (в UIKit нативный auto-tracking появляется только в iOS 18/26).
- Имитация асинхронного «денежного потока» с помощью `NetworkingService`.
- Примеры ошибок многопоточности для учебных целей.

## Структура проекта (MVVM)

- **`Sources/Main/ViewModel/MainViewModel.swift`** — `@Observable final class MainViewModel`:
  поля `balance` (Decimal) и `isCashFlowActive`, методы-инты `toggleCashFlow()` и `spendMoney()`.
  Логика денежного потока на отменяемом `DispatchWorkItem`.
- **`Sources/Main/View/MainViewController.swift`** — UIViewController, держит ViewModel
  напрямую (без протоколов). Подписывается на изменения через `withObservationTracking`.
- **`Sources/Main/Model/MainRepository.swift`** — хранит текущий баланс (`currentAmount`)
  **без синхронизации** (учебный баг №1).
- **`Sources/NetworkingService.swift`** — имитация сети: колбэк приходит на
  background-очереди (`DispatchQueue.global(qos: .utility)`).
- **`Sources/DesignSystem/BankButton.swift`** — кастомная кнопка с состояниями старт/стоп.
- **`Sources/SceneDelegate.swift`** — ручная композиция: `MainViewModel()` →
  `MainViewController(viewModel:)`.

### Как устроен мост @Observable → UIKit (iOS 17)

Макрос `@Observable` сам по себе не заставит `UILabel` перерисоваться: нативный
auto-tracking для UIKit появился только в iOS 18/26, а deployment target — iOS 17.
Поэтому во View есть мост:

```swift
private func bindViewModel() {
    withObservationTracking {
        render(viewModel)          // чтения свойств попадают в трекинг
    } onChange: {
        self.bindViewModel()       // перерегистрация после каждого срабатывания
    }
}
```

Ключевой момент: **`withObservationTracking` — однострочный трекинг**. Колбэк
`onChange` срабатывает один раз, после чего подписка умирает. Поэтому
`bindViewModel()` перерегистрирует себя рекурсивно изнутри колбэка — View снова
подписывается на те свойства, которые прочитал `render`.

Важно: `onChange` может прилететь **на background-потоке** (сеть пишет `balance`
из фона), и `render` выполнится там же. Хоп на main в мосте намеренно НЕ сделан —
это часть учебного кейса (Main Thread Checker в Xcode подсвечивает студентам
обновление UI не из главного потока).

## Учебные баги (НЕ исправлять!)

Это кейс по многопоточности: баги оставлены намеренно для разбора со студентами.

### 1. Race condition на `currentAmount`

Записи в `MainRepository.currentAmount` идут без синхронизации:
- из background-колбэка сети (`balance = repository.currentAmount` в замыкании `makeCashFlow`),
- из main-потока при нажатии «Время потратить» (`spendMoney()`).

Операция `+=`/`-=` не атомарна: чтение-модификация-запись двух потоков
перемешиваются, часть начислений теряется. Запуск `Tests/MainRepositoryTests.swift`
(100 000 конкурентных инкрементов) падает и наглядно это демонстрирует.

**Вопрос студентам:** почему `Decimal` не спасает? Какие способы синхронизации
подойдут (lock, serial queue, actor) и какие у каждого минусы?

### 2. Двойной запуск денежного потока

При выключении потока `cashFlowWorkItem?.cancel()` гасит только ещё **не
запущенный** тик. Если сетевой колбэк уже in-flight, он видит
`isCashFlowActive == true` (а она могла снова стать true после быстрого
off→on) и порождает **свою** цепочку начислений. Быстрый старт-стоп-старт легко
даёт две параллельные цепочки — баланс растёт вдвое быстрее.

**Вопрос студентам:** в какой момент возникает окно гонки? Достаточно ли
`DispatchWorkItem.cancel()`, чтобы её закрыть? Как сделать запуск/остановку
потока атомарной?

### 3. Обновление UI из background-потока

Баланс пишется в background-замыкании сети, `@Observable` уведомляет подписку
на том же потоке — `render` (запись в `UILabel`) выполняется не на main.
Хоп на main в мосте намеренно отсутствует: так студент видит срабатывание
Main Thread Checker и учится находить источник обновления UI.

**Вопрос студентам:** почему приложение «иногда работает», хотя UI обновляется
из фона? Чем опасны недетерминированные отрисовки? Где правильно ставить
`DispatchQueue.main.async` и почему не «на всякий случай» вокруг всего?

> Отличие платформы: на iOS 26+ строгость рантайма к UI-операциям не из main
> выше. Если на новых ОС приложение будет падать намертво, хоп на main в мосте
> — первое, что стоит обсудить, явно оговорив отличие платформы от состояния
> кейса.

## Сборка

Требуется macOS + Xcode (проект разрабатывается под Xcode 27). В CI собирается
только схема приложения — намеренно падающий тест в CI не запускается.

```bash
make generate   # сгенерировать .xcodeproj через XcodeGen
make build      # собрать приложение для iOS Simulator
make open       # открыть проект в Xcode
```

### 1. Склонируйте репозиторий:
```bash
git clone https://github.com/CrazyMillerGitHub/Multithreading-iOS-Demo.git
cd Multithreading-iOS-Demo
```

### 2. Установите XcodeGen (если ещё не установлен):
```bash
brew install xcodegen
xcodegen --version
```

`.xcodeproj` не коммитится — он всегда генерируется из `project.yml`
командой `make generate`.
