all: build

build:
	@docker build --rm --tag=cdssnc/dmi-tcat .
