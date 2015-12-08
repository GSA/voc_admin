Capybara.javascript_driver = :webkit
Capybara.asset_host = "http://localhost:3000"

Capybara::Webkit.configure do |config|
  # Enable debug mode. Prints a log of everything the driver is doing.
  #config.debug = true
end
