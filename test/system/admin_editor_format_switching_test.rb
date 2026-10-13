require "application_system_test_case"

class Admin::EditorFormatSwitchingTest < ApplicationSystemTestCase
  setup do
    @original_user = ENV["BLOG_ADMIN_USER"]
    @original_password = ENV["BLOG_ADMIN_PASSWORD"]
    ENV["BLOG_ADMIN_USER"] = "editor-admin"
    ENV["BLOG_ADMIN_PASSWORD"] = "editor-secret"

    visit admin_login_path
    fill_in "Usuário", with: "editor-admin"
    fill_in "Senha", with: "editor-secret"
    click_button "Entrar"
    assert_current_path admin_articles_path
    visit new_admin_article_path
  end

  teardown do
    ENV["BLOG_ADMIN_USER"] = @original_user
    ENV["BLOG_ADMIN_PASSWORD"] = @original_password
  end

  test "preserves Markdown formatting when switching to visual and back" do
    markdown = "# Meu título\n\nTexto **forte** e *ênfase*.\n\n- primeiro item\n- segundo item\n\n> uma citação"

    fill_in "Conteúdo", with: markdown
    select "Editor visual", from: "Modo de escrita"

    assert_selector ".visual-editor h1", text: "Meu título"
    assert_selector ".visual-editor strong", text: "forte"
    assert_selector ".visual-editor em", text: "ênfase"
    assert_selector ".visual-editor ul li", text: "primeiro item"
    assert_selector ".visual-editor blockquote", text: "uma citação"

    select "Markdown", from: "Modo de escrita"

    body = find("textarea[name='article[body]']").value
    assert_includes body, "# Meu título"
    assert_includes body, "**forte**"
    assert_includes body, "*ênfase*"
    assert_includes body, "- primeiro item"
    assert_includes body, "- segundo item"
    assert_includes body, "> uma citação"
  end

  test "keeps visual formatting when toggling back to Markdown repeatedly" do
    fill_in "Conteúdo", with: "# Título visual\n\nTexto **importante**."
    select "Editor visual", from: "Modo de escrita"
    select "Markdown", from: "Modo de escrita"
    select "Editor visual", from: "Modo de escrita"

    assert_selector ".visual-editor h1", text: "Título visual"
    assert_selector ".visual-editor strong", text: "importante"
  end
end
