FROM ctac/ruby-base:1.9

ARG RAILS_ENV=production
ENV APP_HOME /voc_admin

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install git nodejs -y --no-install-recommends && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD Gemfile* $APP_HOME/

RUN bundle install

ADD . $APP_HOME

RUN rm -f tmp/pids/unicorn.pid tmp/pids/server.pid

EXPOSE 80
ENTRYPOINT [ "unicorn", "-c", "config/unicorn.rb" ]
