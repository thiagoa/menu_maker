require 'menu_maker'

require 'active_support/test_case'
require "shoulda-context"
require "codeclimate-test-reporter"

CodeClimate::TestReporter.configure do |config|
    config.logger.level = Logger::WARN
end

CodeClimate::TestReporter.start
