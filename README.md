# Voice of the Consumer - Admin Application

Voice of the Consumer (VOC) is a pair of Rails applications collectively
capable of first generating and presenting surveys, then collecting and
analyzing the results.

This (Admin) application is concerned with the administration interface,
including site setup, survey creation and versioning, and results processing.
In addition to the administration site, there are some additional task
workers in the project which leverage [Resque](https://github.com/resque/resque).

The [Public](https://github.com/HHS/voc-public) application is responsible for presenting surveys and collecting
responses.

VOC currently works on Rails 3.0.13 and either MRI Ruby 1.9.3-p194 (Linux only)
or the Win32 version of JRuby 1.7.1.

Both versions rely on a database in [MySQL](http://www.mysql.com/) 5.1 or
greater and [Redis](http://redis.io/), shared between Admin and Public applications.

The Admin application depends on [Mongo](http://www.mongodb.org/).

## Quick Installation and Usage

Note: These instructions presume Ruby/JRuby dependencies have already been met
and walk through running a development environment only; setting up to run in
production requires additional configuration.

More information is provided in the [Wiki](https://github.com/HHS/voc-admin/wiki).

### MRI Ruby 1.9.3-p194

Run `bundle install` to satisfy gem dependencies.

Check the `config/` directory for examples of the YAML configuration files which
need to be in place and generate appropriately.

Edit `db/seeds.rb` to set the administrative user credentials. It's at the bottom, with the email address `sysadmin@YOURCOMPANYURL.com`. More admin users can be added to the end of `db/seeds.rb` prior to running the following commands. Simply copy/paste the section for `sysadmin@YOURCOMPANYURL.com`.

Run database tasks:

    rake db:create
    rake db:migrate
    rake db:seed
    rake db:mongoid:create_indexes

In one command window, start `webrick`:

    rails s webrick -p XXXX

In a second, start a jobs worker. It takes the optional ENV variables NUM_WORKERS and NUM_EXPORT_WORKERS.

    rake resque:start_workers

In production, this command can be run:

    rake application:start_all

To run the daily reporting tasks, run manually or in a cronjob:

    rake reporting:daily

Navigate to the configured port to log into the administration interface.

### Win32 JRuby 1.7.1

Follow steps for MRI Ruby, but prepend `jruby -S` to all `rake` and
`rails` commands.

The PDF generating software requires the wkhtmltopdf binary to be manually installed in Windows. It works with version [0.9.6](http://code.google.com/p/wkhtmltopdf/downloads/detail?name=wkhtmltopdf-0.9.6-installer.exe&can=4&q=). Uncomment the contents of `/config/initializers/pdfkit.rb` and fill in the location of the wkhtmltopdf binary.

Windows batch scripts have been provided for use with Tomcat (or other Java
Servlet container.)

### Adding New Admin Users

If an admin user is needed, it can be added through the rails console. This method should only be used if unable to log into the website as an admin user. If able to log in as an admin user, add new users by clicking on the `Manage Users` tab on the website.

For MRI Ruby, run `rails console` on the command line. For JRuby, run `jruby -S rails console`. This will open a new console for interacting with the application. To exit the console, type `exit`. To add a new admin user, type the following (with the various fields replaced as needed).

```
User.create(:email => "sysadmin@YOURCOMPANYURL.com", :f_name => "System", 
    :l_name => "Administrator", :password => "password", 
    :password_confirmation => "password", :role => Role::ADMIN)
```

### Branding

To use branding, uncomment the branding section in `config/app_config.yml`:

```
  branding:		# optional block, defaults shown
    css-filename: application        # (minus the .css extension)
    header-layout: voc_header
    footer-layout: voc_footer
```

Place the branded css file in `public/stylesheets/your_stylesheet_name.css`. The branded headers and footers go in `app/views/layouts/_your_header_or_footer_name.html.erb`.

