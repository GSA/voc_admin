# Voice of the Consumer - Admin Application

Voice of the Consumer (VOC) is a pair of Rails applications collectively
capable of first generating and presenting surveys, then collecting and
analyzing the results.

This (Admin) application is concerned with the administration interface,
including site setup, survey creation and versioning, and results processing.
In addition to the administration site, there are some additional task
workers in the project which leverage [Delayed::Job](https://github.com/collectiveidea/delayed_job#delayedjob--).

The [Public](https://github.com/HHS/voc-public) application is responsible for presenting surveys and collecting
responses.

VOC currently works on Rails 3.0.13 and either MRI Ruby 1.9.3-p194 (Linux only)
or the Win32 version of JRuby 1.7.1.

Both versions rely on a database in [MySQL](http://www.mysql.com/) 5.1 or
greater, shared between Admin and Public applications.

## Quick Installation and Usage

Note: These instructions presume Ruby/JRuby dependencies have already been met
and walk through running a development environment only; setting up to run in
production requires additional configuration.

More information is provided in the [Wiki](https://github.com/HHS/voc-admin/wiki).

### MRI Ruby 1.9.3-p194

Run `bundle install` to satisfy gem dependencies.

Check the `config/` directory for examples of the YAML configuration files which
need to be in place and generate appropriately.

Also edit `db/seeds.rb` to set administrative user credentials.

Run database tasks:

    rake db:create
    rake db:migrate
    rake db:seed

In one command window, start `webrick`:

    rails s webrick -p XXXX

In a second, start a jobs worker:

    rake jobs:work

In a third, start the nightly process runner:

    rake nightly_rules:process

Navigate to the configured port to log into the administration interface.

### Win32 JRuby 1.7.1

Follow steps for MRI Ruby, but prepend `jruby -S` to all `rake` and
`rails` commands.

Windows batch scripts have been provided for use with Tomcat (or other Java
Servlet container.)
