FROM ruby:2.5
MAINTAINER HowToHireMe Team <opensource@howtohireme.ru>
ARG master_key

RUN apt-get -y update
RUN apt-get -y install nodejs netcat

WORKDIR /app
COPY ./ .
ENV RAILS_ENV production
ENV RAILS_MASTER_KEY=$master_key

RUN gem install foreman
RUN bundle install
# TODO: for some reason official ruby image does not load gems from
# vendor/bundle, where bundler installs gems with --deployment flag
# --deployment --without development test
RUN cp config/database.yml.sample config/database.yml

RUN rails assets:precompile

CMD rm -f /app/tmp/pids/server.pid && rails db:migrate:with_data && foreman start -f Procfile.production
