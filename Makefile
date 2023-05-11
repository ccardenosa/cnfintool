BINARY_NAME=cnfintool
BINARY_DIR=$(shell pwd)/bin
BINARY_PATH=${BINARY_DIR}/${BINARY_NAME}

OS := $(shell uname)

.PHONY: generate
generate: generate-cobraCmd-skeleton

.PHONY: generate-cobraCmd-skeleton
generate-cobraCmd-skeleton:
	bash scripts/generate_cobraCmd_skeleton.sh

GOOS:=windows
ifeq ($(OS),Darwin)
	GOOS:=darwin
else
	ifeq ($(OS),Linux)
		GOOS := linux
	endif
endif

.PHONY: build
build:
	GOARCH=amd64 GOOS=${GOOS} go build -o ${BINARY_PATH}-${GOOS} main.go

run: build
	${BINARY_PATH}-${GOOS}

clean:
	go clean
	rm -rf ${BINARY_DIR}

test:
	go test ./...

test_coverage:
	go test ./... -coverprofile=coverage.out

dep:
	go mod download

vet:
	go vet

lint:
	golangci-lint run --enable-all

