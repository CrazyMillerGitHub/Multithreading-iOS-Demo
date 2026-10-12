# Multithreading-iOS-Case
#
# Генерация проекта, сборка и тесты в одну команду.
# Требования: macOS + Xcode, xcodegen (`brew install xcodegen`).
#
#   make help     — список команд
#   make generate — сгенерировать .xcodeproj из project.yml
#   make build    — собрать приложение (iOS Simulator)
#   make test     — запустить юнит-тесты
#   make open     — открыть проект в Xcode
#   make clean    — удалить сгенерированные артефакты

PROJECT   := Multithreading-iOS-Case.xcodeproj
SCHEME    := MultithreadingiOSCase
DEST      := generic/platform=iOS Simulator
CONFIG    := Debug

.DEFAULT_GOAL := help
.PHONY: help generate build test open clean

help: ## Показать список команд
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

generate: ## Сгенерировать .xcodeproj через XcodeGen
	xcodegen generate

build: generate ## Собрать приложение для iOS Simulator
	xcodebuild build \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination '$(DEST)' \
		-configuration $(CONFIG) \
		CODE_SIGNING_ALLOWED=NO

test: generate ## Запустить юнит-тесты на симуляторе
	xcodebuild test \
		-project $(PROJECT) \
		-scheme MultithreadingiOSCaseTests \
		-destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
		CODE_SIGNING_ALLOWED=NO

open: generate ## Открыть проект в Xcode
	open $(PROJECT)

clean: ## Удалить сгенерированный проект и артефакты
	rm -rf $(PROJECT) DerivedData
