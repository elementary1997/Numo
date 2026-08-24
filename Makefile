# Унифицированные команды: dev и CI выполняют одно и то же.
.PHONY: setup check test analyze build build-linux run-web clean

setup:
	flutter pub get

analyze:
	flutter analyze

test:
	flutter test

check: analyze test

build:
	flutter build web

build-linux:
	flutter build linux --release

run-web:
	flutter run -d web-server --web-port 8377

clean:
	flutter clean
