ENV["RAILS_ENV"] ||= "test"
ENV["BLOG_LOGIN_PATH"] ||= "login-privado-para-testes"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml and all fixtures in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
