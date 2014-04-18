# -*- encoding: utf-8 -*-
# stub: best_in_place 0.2.4 ruby lib

Gem::Specification.new do |s|
  s.name = "best_in_place"
  s.version = "0.2.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bernat Farrero"]
  s.date = "2014-04-18"
  s.description = "BestInPlace is a jQuery script and a Rails 3 helper that provide the method best_in_place to display any object field easily editable for the user by just clicking on it. It supports input data, text data, boolean data and custom dropdown data. It works with RESTful controllers."
  s.email = ["bernat@itnig.net"]
  s.files = [".gitignore", ".rspec", ".travis.yml", "Gemfile", "README.md", "Rakefile", "best_in_place.gemspec", "lib/best_in_place.rb", "lib/best_in_place/controller_extensions.rb", "lib/best_in_place/display_methods.rb", "lib/best_in_place/engine.rb", "lib/best_in_place/helper.rb", "lib/best_in_place/railtie.rb", "lib/best_in_place/test_helpers.rb", "lib/best_in_place/utils.rb", "lib/best_in_place/version.rb", "lib/generators/best_in_place/setup_generator.rb", "public/javascripts/best_in_place.js", "public/javascripts/jquery-1.4.4.js", "public/javascripts/jquery.purr.js", "spec/helpers/best_in_place_spec.rb", "spec/integration/double_init_spec.rb", "spec/integration/js_spec.rb", "spec/integration/text_area_spec.rb", "spec/spec_helper.rb", "test_app/Gemfile", "test_app/Gemfile.lock", "test_app/README", "test_app/Rakefile", "test_app/app/controllers/application_controller.rb", "test_app/app/controllers/users_controller.rb", "test_app/app/helpers/application_helper.rb", "test_app/app/helpers/users_helper.rb", "test_app/app/models/user.rb", "test_app/app/views/layouts/application.html.erb", "test_app/app/views/users/_form.html.erb", "test_app/app/views/users/double_init.html.erb", "test_app/app/views/users/index.html.erb", "test_app/app/views/users/new.html.erb", "test_app/app/views/users/show.html.erb", "test_app/config.ru", "test_app/config/application.rb", "test_app/config/boot.rb", "test_app/config/database.yml", "test_app/config/environment.rb", "test_app/config/environments/development.rb", "test_app/config/environments/production.rb", "test_app/config/environments/test.rb", "test_app/config/initializers/backtrace_silencers.rb", "test_app/config/initializers/countries.rb", "test_app/config/initializers/inflections.rb", "test_app/config/initializers/mime_types.rb", "test_app/config/initializers/secret_token.rb", "test_app/config/initializers/session_store.rb", "test_app/config/locales/en.yml", "test_app/config/routes.rb", "test_app/db/migrate/20101206205922_create_users.rb", "test_app/db/migrate/20101212170114_add_receive_email_to_user.rb", "test_app/db/migrate/20110115204441_add_description_to_user.rb", "test_app/db/schema.rb", "test_app/db/seeds.rb", "test_app/doc/README_FOR_APP", "test_app/lib/tasks/.gitkeep", "test_app/lib/tasks/cron.rake", "test_app/public/404.html", "test_app/public/422.html", "test_app/public/500.html", "test_app/public/favicon.ico", "test_app/public/images/rails.png", "test_app/public/images/red_pen.png", "test_app/public/javascripts/application.js", "test_app/public/javascripts/best_in_place.js", "test_app/public/javascripts/jquery-1.4.4.min.js", "test_app/public/javascripts/jquery.purr.js", "test_app/public/javascripts/rails.js", "test_app/public/robots.txt", "test_app/public/stylesheets/.gitkeep", "test_app/public/stylesheets/scaffold.css", "test_app/public/stylesheets/style.css", "test_app/script/rails", "test_app/test/fixtures/users.yml", "test_app/test/functional/users_controller_test.rb", "test_app/test/performance/browsing_test.rb", "test_app/test/test_helper.rb", "test_app/test/unit/helpers/users_helper_test.rb", "test_app/test/unit/user_test.rb", "test_app/vendor/plugins/.gitkeep"]
  s.homepage = "http://github.com/bernat/best_in_place"
  s.require_paths = ["lib"]
  s.rubyforge_project = "best_in_place"
  s.rubygems_version = "2.1.11"
  s.summary = "It makes any field in place editable by clicking on it, it works for inputs, textareas, select dropdowns and checkboxes"
  s.test_files = ["spec/helpers/best_in_place_spec.rb", "spec/integration/double_init_spec.rb", "spec/integration/js_spec.rb", "spec/integration/text_area_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, ["~> 3.0.0"])
      s.add_development_dependency(%q<rspec-rails>, ["~> 2.7.0"])
      s.add_development_dependency(%q<nokogiri>, [">= 1.5.0"])
      s.add_development_dependency(%q<capybara>, [">= 1.0.1"])
    else
      s.add_dependency(%q<rails>, ["~> 3.0.0"])
      s.add_dependency(%q<rspec-rails>, ["~> 2.7.0"])
      s.add_dependency(%q<nokogiri>, [">= 1.5.0"])
      s.add_dependency(%q<capybara>, [">= 1.0.1"])
    end
  else
    s.add_dependency(%q<rails>, ["~> 3.0.0"])
    s.add_dependency(%q<rspec-rails>, ["~> 2.7.0"])
    s.add_dependency(%q<nokogiri>, [">= 1.5.0"])
    s.add_dependency(%q<capybara>, [">= 1.0.1"])
  end
end
