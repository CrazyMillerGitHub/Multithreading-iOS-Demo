# Изучение многопоточности в iOS

![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg) ![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg) ![Xcode](https://img.shields.io/badge/Xcode-15.0+-green.svg)

## О проекте

Этот проект представляет собой учебное приложение для iOS, созданное с целью изучения основ многопоточности в Swift/UIKit. Приложение демонстрирует базовые операции с балансом (добавление и трата средств) с использованием асинхронных вызовов и потенциальными проблемами многопоточности, которые студентам предстоит проанализировать и исправить.

### Основные особенности:
- Управление балансом в реальном времени.
- Имитация асинхронного "денежного потока" с помощью `NetworkingService`.
- Пример ошибок многопоточности для учебных целей (например, отсутствие синхронизации доступа к `currentAmount`).

## Структура проекта

- **`MainViewController`**: Основной контроллер приложения.
  - Отображает текущий баланс (`currentBalanceLabel`).
  - Содержит кнопки для запуска/остановки "денежного потока" (`startCashFlowButton`) и траты средств (`spendingButton`).
- **`MainRepository`**: Хранит текущий баланс (`currentAmount`).
- **`NetworkingService`**: Имитирует асинхронные операции (заглушка для учебных целей).
- **`BankButton`**: Кастомная кнопка с состояниями (запуск/остановка).

## Установка

### 1. Склонируйте репозиторий:
```bash
git clone https://github.com/CrazyMillerGitHub/Multithreading-iOS-Case.git
cd Multithreading-iOS-Case
```

### 2. Убедитесь, что у вас установлен Homebrew (для macOS):
Если Homebrew не установлен, выполните:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. Установите XcodeGen (если ещё не установлен):
```bash
brew install xcodegen
```
Проверьте версию:
```bash
xcodegen --version
```

### 4. Сгенерируйте проект:
Выполните скрипт для генерации `.xcodeproj`:
```bash
sh generate.sh
```

### 5. Откройте проект в Xcode:
После выполнения скрипта проект откроется автоматически. Если этого не произошло:
```bash
open Multithreading-iOS-Case.xcodeproj
```
