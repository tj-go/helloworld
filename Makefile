# Self-Documented Makefile see https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.DEFAULT_GOAL := help

.PHONY: help
# Put it first so that "make" without argument is like "make help".
help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-32s-\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: format
format:  ## Format go modules
	@go fmt ./...

.PHONY: tidy
tidy:  ## Tidy go.mod
	@go mod tidy

.PHONY: clean
clean:  ## Clean binary file
	@echo "Cleaning binary..."
	@rm -rf ./bin

.PHONY: build
build: clean  ## Compile go modules
	@echo "Compiling go modules..."
	@go build -o ./bin/helloworld .

.PHONY: run
run: build  ## Execute binary
	@echo "Executing binary..."
	@./bin/helloworld