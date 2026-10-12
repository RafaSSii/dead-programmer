require "test_helper"

class Admin::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @original_user = ENV["BLOG_ADMIN_USER"]
    @original_password = ENV["BLOG_ADMIN_PASSWORD"]
    @original_forgery_protection = ActionController::Base.allow_forgery_protection
    ENV["BLOG_ADMIN_USER"] = "test-admin"
    ENV["BLOG_ADMIN_PASSWORD"] = "test-secret-password"
    Rails.cache.clear
  end

  teardown do
    ENV["BLOG_ADMIN_USER"] = @original_user
    ENV["BLOG_ADMIN_PASSWORD"] = @original_password
    ActionController::Base.allow_forgery_protection = @original_forgery_protection
  end

  test "private login page renders a credential form with an authenticity token" do
    ActionController::Base.allow_forgery_protection = true

    get admin_login_url
    assert_response :success
    assert_select "form"
    assert_select "input[type=password]"
    assert_select 'input[name="authenticity_token"][value]'
  end

  test "login rejects a request without a valid authenticity token when forgery protection is enabled" do
    ActionController::Base.allow_forgery_protection = true

    post admin_login_url, params: { username: "test-admin", password: "test-secret-password" }

    assert_response :unprocessable_entity
    get admin_articles_url
    assert_redirected_to admin_login_path
  end

  test "valid credentials create an admin session with hardened cookie attributes" do
    post admin_login_url, params: { username: "test-admin", password: "test-secret-password" }
    assert_redirected_to admin_articles_path

    cookie_header = response.headers["Set-Cookie"].to_s
    assert_match(/httponly/i, cookie_header)
    assert_match(/samesite=lax/i, cookie_header)

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

  test "invalid username is rejected" do
    post admin_login_url, params: { username: "wrong-user", password: "test-secret-password" }
    assert_response :unprocessable_entity
    assert_match "Usuário ou senha incorretos.", response.body
  end

  test "login is unavailable when credentials are not configured" do
    ENV["BLOG_ADMIN_USER"] = nil
    ENV["BLOG_ADMIN_PASSWORD"] = nil

    post admin_login_url, params: { username: "test-admin", password: "test-secret-password" }

    assert_response :service_unavailable
    assert_match "não foi configurado", response.body
  end

  test "login attempts are rate limited per client IP" do
    client_env = { "REMOTE_ADDR" => "203.0.113.77" }

    5.times do
      post admin_login_url,
        params: { username: "test-admin", password: "wrong-password" },
        env: client_env
      assert_response :unprocessable_entity
    end

    post admin_login_url,
      params: { username: "test-admin", password: "wrong-password" },
      env: client_env

    assert_response :too_many_requests
  end

  test "every admin article action rejects unauthenticated visitors" do
    requests = [
      -> { get admin_articles_url },
      -> { get new_admin_article_url },
      -> { post admin_articles_url, params: { article: { title: "Teste", body: "Texto" } } },
      -> { get edit_admin_article_url(12) },
      -> { patch admin_article_url(12), params: { article: { title: "Alterado" } } },
      -> { delete admin_article_url(12) }
    ]

    requests.each do |request|
      request.call
      assert_redirected_to admin_login_path
    end
  end

  test "logout clears the admin session" do
    post admin_login_url, params: { username: "test-admin", password: "test-secret-password" }
    delete admin_logout_url
    assert_redirected_to root_path
    get admin_articles_url
    assert_redirected_to admin_login_path
  end
end
