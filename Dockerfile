ARG RUBY_VERSION
ARG DEBIAN_RELEASE
FROM ruby:${RUBY_VERSION}-slim-${DEBIAN_RELEASE} as base

RUN apt update -yq && \
    DEBIAN_FRONTEND=noninteractive apt install -yq --no-install-recommends \
    libpq-dev \
    && \
    apt-get clean && \
    apt -y autoremove && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

WORKDIR /app

ARG BUNDLER_VERSION
RUN gem install bundler:${BUNDLER_VERSION} && \
    bundle config path vendor/bundle && \
    bundle config set --local without 'development test'

EXPOSE 3000/tcp

CMD ["bundle", "exec", "rails s -b 0.0.0.0 -p 3000"]

FROM base as build-prod

RUN apt update -yq && \
    DEBIAN_FRONTEND=noninteractive apt install -yq --no-install-recommends \
    build-essential \
    git \
		curl \
    && \
    apt-get clean && \
    apt -y autoremove && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

ARG NODE_VERSION
RUN curl -sL -o node-${NODE_VERSION}-linux-x64.tar.gz "https://nodejs.org/download/release/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz" && \
    tar xfz node-${NODE_VERSION}-linux-x64.tar.gz && \
    rm node-${NODE_VERSION}-linux-x64.tar.gz && \
    mv node-v${NODE_VERSION}-linux-x64 /usr/local/nodejs

ENV PATH=/usr/local/nodejs/bin:${PATH} \
    RAILS_ENV=production

COPY .ruby-version Gemfile Gemfile.lock ./
COPY vendor ./vendor

RUN bundle install --jobs 4 --retry 3

FROM build-prod as build-dev

ENV RAILS_ENV=development

RUN bundle config set --local without 'test' && \
    bundle install --jobs 4 --retry 3

COPY . .

FROM build-prod as cleanup

COPY . .

RUN rm -rf \
		.nvmrc \
    node_modules \
		test

FROM base as runtime

COPY --from=cleanup /usr/local/nodejs /usr/local/nodejs
COPY --from=cleanup /app /app

ENV PATH=/usr/local/nodejs/bin:${PATH} \
    RAILS_ENV=production

