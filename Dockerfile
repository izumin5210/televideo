FROM ruby:2.4.0-alpine

ENV APP /app
WORKDIR $APP

RUN apk --update add --virtual build-deps \
    git \
  && apk add \
    tzdata \
  && rm -rf /var/cache/apk/* \
  && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

COPY . $APP

RUN bundle install --jobs=4 --path vendor/bundle

RUN apk del build-deps \
  && rm -rf /var/cache/apk/*

CMD ["bundle", "exec", "rackup", "--port", "80", "--host", "0.0.0.0"]
