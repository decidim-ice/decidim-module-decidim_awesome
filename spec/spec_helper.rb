# frozen_string_literal: true

require "decidim/dev"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

Decidim::Dev.dummy_app_path = File.expand_path(File.join(__dir__, "decidim_dummy_app"))

require "decidim/dev/test/base_spec_helper"

def legacy_version?
  Decidim::DecidimAwesome.legacy_version?
end

require 'capybara'
require 'selenium/webdriver'

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.args << "--explicitly-allowed-ports=#{Capybara.server_port}"
  options.args << "--headless-new"
  options.args << "--no-sandbox"
  options.args << if ENV["BIG_SCREEN_SIZE"].present?
                    "--window-size=1920,3000"
                  else
                    "--window-size=1920,1080"
                  end
  options.args << "--ignore-certificate-errors" if ENV["TEST_SSL"]
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end
