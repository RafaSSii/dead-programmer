module ApplicationHelper
  ARTICLE_TAGS = %w[p br h1 h2 h3 h4 ul ol li blockquote pre code strong em a hr].freeze
  ARTICLE_ATTRIBUTES = %w[href title class rel target].freeze

  def article_body_html(article)
    article.content_format == "visual" ? sanitize(article.body, tags: ARTICLE_TAGS, attributes: ARTICLE_ATTRIBUTES) : render_markdown(article.body)
  end

  private

  def render_markdown(source)
    lines = ERB::Util.html_escape(source.to_s).split("\n")
    output, paragraph, list_type, code_lines = [], [], nil, []
    in_code = false
    flush_paragraph = -> { unless paragraph.empty?; output << "<p>#{paragraph.join(' ')}</p>"; paragraph.clear; end }
    close_list = -> { if list_type; output << "</#{list_type}>"; list_type = nil; end }
    lines.each do |line|
      if line.start_with?("```")
        flush_paragraph.call; close_list.call
        if in_code
          output << "<pre><code>#{code_lines.join("\n")}</code></pre>"; code_lines.clear; in_code = false
        else
          in_code = true
        end
        next
      end
      if in_code
        code_lines << line
      elsif line.strip.empty?
        flush_paragraph.call; close_list.call
      elsif (m = line.match(/\A(#{'#'}{1,4})\s+(.+)\z/))
        flush_paragraph.call; close_list.call
        level = m[1].length
        output << "<h#{level}>#{inline_markdown(m[2])}</h#{level}>"
      elsif (m = line.match(/\A[-*]\s+(.+)\z/))
        flush_paragraph.call
        if list_type != "ul"; close_list.call; output << "<ul>"; list_type = "ul"; end
        output << "<li>#{inline_markdown(m[1])}</li>"
      elsif (m = line.match(/\A\d+\.\s+(.+)\z/))
        flush_paragraph.call
        if list_type != "ol"; close_list.call; output << "<ol>"; list_type = "ol"; end
        output << "<li>#{inline_markdown(m[1])}</li>"
      elsif line.start_with?("&gt; ")
        flush_paragraph.call; close_list.call
        output << "<blockquote><p>#{inline_markdown(line.delete_prefix('&gt; '))}</p></blockquote>"
      else
        close_list.call; paragraph << inline_markdown(line)
      end
    end
    output << "<pre><code>#{code_lines.join("\n")}</code></pre>" if in_code
    flush_paragraph.call; close_list.call
    sanitize(output.join("\n"), tags: ARTICLE_TAGS, attributes: ARTICLE_ATTRIBUTES)
  end

  def inline_markdown(text)
    value = text.gsub(/`([^`]+)`/, '<code>\1</code>')
    value = value.gsub(/\*\*(.+?)\*\*/, '<strong>\1</strong>')
    value = value.gsub(/(?<!\*)\*([^*]+)\*(?!\*)/, '<em>\1</em>')
    value.gsub(/\[([^\]]+)\]\((https?:\/\/[^\s)]+)\)/, '<a href="\2" rel="nofollow noopener" target="_blank">\1</a>')
  end
end
