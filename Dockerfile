# Use the official Ruby image because the Rails images have been deprecated
FROM ruby:3.1.4

RUN apt-get update \
    && apt-get install -y --no-install-recommends postgresql-client \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /usr/local/node \
    && curl -L https://nodejs.org/dist/v16.20.2/node-v16.20.2-linux-x64.tar.xz | tar Jx -C /usr/local/node --strip-components=1
RUN ln -s ../node/bin/node /usr/local/bin/

WORKDIR /ohana-api

COPY Gemfile /ohana-api-smc
COPY Gemfile.lock /ohana-api-smc

RUN gem install bundler
RUN bundle install --jobs 20 --retry 5 --without production

COPY . /ohana-api-smc

EXPOSE 8080
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8080"]
