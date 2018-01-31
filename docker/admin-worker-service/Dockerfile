FROM ctac/ruby-base:2.2

ARG RAILS_ENV=production
ENV APP_HOME /voc

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  git \
  zip unzip \
  build-essential \
  zlib1g libfontconfig1 libfreetype6 libx11-6 libx11-data libxau6 libxcb1 libxdmcp6 libxext6 libxrender1 \
  && apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY Gemfile /tmp/Gemfile
COPY Gemfile.lock /tmp/Gemfile.lock
COPY bundle.sh /tmp/bundle.sh
WORKDIR /tmp
RUN bash bundle.sh

RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD . $APP_HOME
RUN mkdir log

EXPOSE 80

COPY vendor/s6-overlay-amd64.tar.gz /tmp/s6-overlay-amd64.tar.gz
ADD  https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem /etc/ssl/certs/rds-combined-ca-bundle.pem

RUN tar xfz /tmp/s6-overlay-amd64.tar.gz -sC / \
    && rm /tmp/s6-overlay-amd64.tar.gz

# Inject Consul Template
ENV CONSUL_TEMPLATE_VERSION 0.15.0

## S6 managed consul-template to generate env files

ADD https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip /

RUN unzip -d / /consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    mv /consul-template /usr/local/bin/consul-template &&\
    rm -rf /consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    mkdir -p /consul-template /consul-template/config.d /consul-template/templates

COPY consul-template/workers/config.d /consul-template/config.d/
COPY consul-template/templates /consul-template/templates/

COPY s6/rake-resque-work /etc/services.d/rake-resque-work
COPY s6/consul-template /etc/services.d/consul-template

# DON'T CLEAN UP INTERMEDIARY IMAGES. DEPENDENT BUILD. MODIFY ONLY BELOW.

COPY vendor/wkhtmltox-0.12.3_linux-generic-amd64.tar.xz /tmp
WORKDIR /tmp
RUN tar xvf wkhtmltox-0.12.3_linux-generic-amd64.tar.xz && \
    mv wkhtmltox/bin/wkhtmlto* /usr/bin/ && \
    rm -rf wkhtmltox*

RUN chmod a+t /usr/local/bundle && chmod a+t /usr/local/bundle/bin

WORKDIR $APP_HOME

ENV QUEUES=voc_report_email,voc_rules,voc_dfs

CMD [ "/init" ]
