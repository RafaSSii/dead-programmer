require "test_helper"

class Admin::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @original_user = ENV["BLOG_ADMIN_USER"]
    @original_password = ENV["BLOG_ADMIN_PASSWORD"]
    ENV["BLOG_ADMIN_USER"] = "test-admin"
    ENV["BLOG_ADMIN_PASSWORD"] = "test-secret-password"
  end

  teardown do
    ENV["BLOG_ADMIN_USER"] = @original_user
    ENV["BLOG_ADMIN_PASSWORD"] = @original_password
  end

  test "private login page renders a credential form" do
    get admin_login_url
    assert_response :success
    assert_select "form"
    assert_select "input[type=password]"
  end

  test "valid credentials create an admin session" do
    post admin_login_url, params: { username: "test-admin", password: "test-secret-password" }
    assert_redirected_to admin_articles_path
    follow_redirect!
    assert_response :success
    assert_select "h1", "Suas publicações"
  end

  test "invalid credentials do not create an admin session" do
    post admin_login_url, params: { username: "test-admin", password: "wrong-password" }
    assert_response :unprocessable_entity
    get admin_articles_url
    assert_redirected_to admin_login_path
  end

  test "admin article panel redirects unauthenticated visitors to login" do
    get admin_articles_url
    assert_redirected_to admin_login_path
  end

  test "logout clears the admin session" do
    post admin_login_url, params: { username: "test-admin", password: "test-secret-password" }
    delete admin_logout_url
    assert_redirected_to root_path
    get admin_articles_url
    assert_redirected_to admin_login_path
  end
end
