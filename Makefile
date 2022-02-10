APP := blog
DEBIAN_RELEASE := buster
RUBY_VERSION := $(shell cat .ruby-version)
NODE_VERSION := $(shell cat .nvmrc)
BUNDLER_VERSION := $(shell grep -A1 'BUNDLED WITH' Gemfile.lock |tail -1 |xargs)

.PHONY: build build-dev

build:
	@DOCKER_BUILDKIT=1 docker build -t $(APP) \
	--build-arg RUBY_VERSION=$(RUBY_VERSION) \
	--build-arg DEBIAN_RELEASE=$(DEBIAN_RELEASE) \
	--build-arg NODE_VERSION=$(NODE_VERSION) \
	--build-arg BUNDLER_VERSION=$(BUNDLER_VERSION) \
	--target runtime \
	.

build-dev:
	@DOCKER_BUILDKIT=1 docker build -t $(APP):dev \
	--build-arg RUBY_VERSION=$(RUBY_VERSION) \
	--build-arg DEBIAN_RELEASE=$(DEBIAN_RELEASE) \
	--build-arg NODE_VERSION=$(NODE_VERSION) \
	--build-arg BUNDLER_VERSION=$(BUNDLER_VERSION) \
	--target build-dev \
	.

