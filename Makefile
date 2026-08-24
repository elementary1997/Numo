# Унифицированные команды: dev и CI выполняют одно и то же.
.PHONY: setup check test analyze build build-linux run-web clean coverage

setup:
	flutter pub get

analyze:
	flutter analyze

test:
	flutter test

check: analyze test

coverage:
	flutter test --coverage
	@awk -F: '/^LF/{lf+=$$2} /^LH/{lh+=$$2} END{printf "Line coverage: %.1f%% (%d/%d lines)\n", 100*lh/lf, lh, lf}' coverage/lcov.info

build:
	flutter build web

build-linux:
	flutter build linux --release

run-web:
	flutter run -d web-server --web-port 8377

clean:
	flutter clean
