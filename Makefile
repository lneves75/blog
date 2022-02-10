APP := blog
DEBIAN_RELEASE := buster
RUBY_VERSION := $(shell cat .ruby-version)
NODE_VERSION := $(shell cat .nvmrc)
BUNDLER_VERSION := $(shell grep -A1 'BUNDLED WITH' Gemfile.lock |tail -1 |xargs)

.PHONY: build build-with-cache build-dev

build:
	@docker buildx build -t $(APP) \
	--build-arg RUBY_VERSION=$(RUBY_VERSION) \
	--build-arg DEBIAN_RELEASE=$(DEBIAN_RELEASE) \
	--build-arg NODE_VERSION=$(NODE_VERSION) \
	--build-arg BUNDLER_VERSION=$(BUNDLER_VERSION) \
	--target runtime \
	--load \
	.

build-with-cache:
	@docker buildx build -t $(APP) \
	--build-arg RUBY_VERSION=$(RUBY_VERSION) \
	--build-arg DEBIAN_RELEASE=$(DEBIAN_RELEASE) \
	--build-arg NODE_VERSION=$(NODE_VERSION) \
	--build-arg BUNDLER_VERSION=$(BUNDLER_VERSION) \
	--target runtime \
	--load \
	--cache-from type=local,mode=max,src=/tmp/.buildx-cache \
	--cache-to type=local,mode=max,dest=/tmp/.buildx-cache-new \
	.
	@rm -rf /tmp/.buildx-cache
	@mv /tmp/.buildx-cache-new /tmp/.buildx-cache

build-dev:
	@docker buildx build -t $(APP):dev \
	--build-arg RUBY_VERSION=$(RUBY_VERSION) \
	--build-arg DEBIAN_RELEASE=$(DEBIAN_RELEASE) \
	--build-arg NODE_VERSION=$(NODE_VERSION) \
	--build-arg BUNDLER_VERSION=$(BUNDLER_VERSION) \
	--target build-dev \
	.

