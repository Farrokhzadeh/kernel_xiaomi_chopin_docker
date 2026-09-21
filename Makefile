.PHONY: all build configure verify clean

all: build

build:
	./scripts/build.sh

configure:
	./scripts/configure.sh

verify:
	./scripts/verify-config.sh .work/out/.config

clean:
	rm -rf .work dist

