require "./lib/api"
require "rack/test"

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.order = :rand
end
