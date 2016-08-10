FROM ctac/ruby-base:2.2

ARG RAILS_ENV=production
ENV APP_HOME /voc

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  git \
  zip unzip \
  build-essential \
  && apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD Gemfile* $APP_HOME/

RUN bundle install --without test development

ADD . $APP_HOME
RUN mkdir log

EXPOSE 80

# DON'T CLEAN UP INTERMEDIARY IMAGES. DEPENDENT BUILD. MODIFY ONLY BELOW.

ENTRYPOINT [ "bundle", "exec", "rake", "reporting:daily" ]
