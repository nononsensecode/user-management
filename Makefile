# References: 
# 1. https://github.com/azer/go-makefile-example/blob/master/Makefile
# 2. https://gist.github.com/serinth/16391e360692f6a000e5a10382d1148c
# 3. https://betterprogramming.pub/my-ultimate-makefile-for-golang-projects-fcc8ca20c9bb

VERSION := $(shell git describe --tags)
BUILD := $(shell git rev-parse --short HEAD)
PROJECTNAME := $(shell basename "$(PWD)")

# Go related variables

GOBASE := $(shell pwd)
GOPATH := $(GOBASE)
GOBIN := $(GOBASE)/bin
GOFILES := $(wildcard *.go)

# Go commands
GOCMD = go
GOTEST := $(GOCMD) test
GOVET := $(GOCMD) vet
GOFMT := $(GOCMD) fmt
GOVENDOR := $(GOCMD) mod vendor

# Project based variables

CMD_BASE := $(GOBASE)/cmd

# User management
USER_MGMT_BASE := $(CMD_BASE)/user-mgmt
USER_MGMT_MAIN := $(USER_MGMT_BASE)/main.go
USER_MGMT_NAME := $(shell basename "$(USER_MGMT_BASE)")

# Use linker flags to provide version/build settings also strip
LDFLAGS := -ldflags "-X=main.Version=$(VERSION) -X=main.Build=$(BUILD) -s -w"

# Redirect error output to a file, so we can show it in the development mode.
STDERR := /tmp/.$(PROJECTNAME)-stderr.txt

# Make is verbose in Linux. Make it silent
MAKEFLAGS += --silent

## install: Install missing dependencies. Runs `go get` internally. E.g: make install get=github.com/x/y
install: go-get

## compile: Compile the binary
compile:
	# '@' don't show the command
	# '-' don't mind the exit status
	@-touch $(STDERR)
	@-rm $(STDERR)
	@-$(MAKE) -s go-compile 2> $(STDERR)
	@cat $(STDERR) | sed -e '1s/.*/\nError:\n/' | sed 's/make\[.*/ /' | sed "/^/s/^/     /" 1>&2

## exec: Run given command, wrapped with custom GOPATH: e.g: make exec run="go test ./..."	
exec:
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) $(run)

## clean: Clean build files. Runs `go clean` internally
clean:
	@-rm $(GOBIN)/$(PROJECTNAME) 2> /dev/null
	@-$(MAKE) go-clean

## usermgmt-build: Builds usermgmt command
usermgmt-build:
	@echo "   > Building usermgmt command..."
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) go build -mod=mod $(LDFLAGS) -o $(GOBIN)/$(USER_MGMT_NAME) $(USER_MGMT_MAIN)

go-compile: go-get go-build

go-build:
	@echo "   > Building binary..."
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) go build $(LDFLAGS) -o $(GOBIN)/$(PROJECTNAME) $(GOFILES)

go-generate:
	@echo "   > Generating dependency files..."
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) go generate $(generate)

go-get:
	@echo "   > Checking if there is any missing dependencies..."
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) go get $(get)	

go-install:
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) go install $(GOFILES)

go-clean:
	@echo "  >  Cleaning build cache"
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) go clean

go-vendor:
	@echo "   > Creating vendor directory..."
	@GOPATH=$(GOPATH) go mod tidy
	@GOPATH=$(GOPATH) go mod vendor

.PHONY: help
all: help
help: Makefile
	@echo
	@echo " Choose a command run in "$(PROJECTNAME)":"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo