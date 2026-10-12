# Multithreading-iOS-Case
#
# Генерация проекта и сборка в одну команду.
# Требования: macOS + Xcode, xcodegen (`brew install xcodegen`).
#
#   make generate — сгенерировать .xcodeproj из project.yml
#   make build    — собрать приложение (iOS Simulator)
#   make open     — открыть проект в Xcode
#
# .xcodeproj не коммитится — он всегда генерируется из project.yml.

PROJECT   := Multithreading-iOS-Case.xcodeproj
SCHEME    := MultithreadingiOSCase
DEST      := generic/platform=iOS Simulator
CONFIG    := Debug

.DEFAULT_GOAL := generate
.PHONY: generate build open

generate: ## Сгенерировать .xcodeproj через XcodeGen
	xcodegen generate

build: generate ## Собрать приложение для iOS Simulator
	xcodebuild build \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-destination '$(DEST)' \
		-configuration $(CONFIG) \
		CODE_SIGNING_ALLOWED=NO

open: generate ## Открыть проект в Xcode
	open $(PROJECT)

help: ## Показать список команд
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'
