FROM ctac/ruby-base:1.9

ARG RAILS_ENV=production
ENV APP_HOME /voc
ENV QUEUE=voc_responses

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install git -y --no-install-recommends && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD Gemfile* $APP_HOME/

RUN bundle install

ADD . $APP_HOME

EXPOSE 80
ENTRYPOINT [ "bundle", "exec", "rake", "resque:work" ]
