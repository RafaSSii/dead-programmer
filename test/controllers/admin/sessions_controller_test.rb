require "test_helper"

class Admin::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @original_user = ENV["BLOG_ADMIN_USER"]
    @original_password = ENV["BLOG_ADMIN_PASSWORD"]
    ENV["BLOG_ADMIN_USER"] = "test-admin"
    ENV["BLOG_ADMIN_PASSWORD"] = "test-secret-password"
    Rails.cache.clear
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
