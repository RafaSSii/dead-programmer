import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["format", "markdown", "visual", "visualWrap"]

  connect() {
    this.switchFormat()
  }

  switchFormat(event) {
    const visualMode = this.formatTarget.value === "visual"

    if (visualMode && !this.visualTarget.dataset.initialized) {
      if (event) {
        this.visualTarget.innerHTML = this.markdownToHtml(this.markdownTarget.value)
      } else {
        // Existing visual articles are stored as HTML; Markdown articles are plain text.
        this.visualTarget.innerHTML = this.formatTarget.value === "visual"
          ? this.markdownTarget.value
          : this.markdownToHtml(this.markdownTarget.value)
      }
      this.visualTarget.dataset.initialized = "true"
    } else if (!visualMode && this.visualTarget.dataset.initialized === "true") {
      this.markdownTarget.value = this.htmlToMarkdown(this.visualTarget)
    }

    this.markdownTarget.hidden = visualMode
    this.visualWrapTarget.hidden = !visualMode
  }

  syncVisual() {
    this.markdownTarget.value = this.visualTarget.innerHTML
  }

  bold() { this.exec("bold") }
  italic() { this.exec("italic") }
  heading() { this.exec("formatBlock", "h2") }
  list() { this.exec("insertUnorderedList") }
  quote() { this.exec("formatBlock", "blockquote") }

  exec(command, value = null) {
    this.visualTarget.focus()
    document.execCommand(command, false, value)
    this.syncVisual()
  }

  markdownToHtml(markdown) {
    const escapeHtml = (text) => text
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;")

    const inline = (text) => {
      let html = escapeHtml(text)
      html = html.replace(/`([^`\n]+)`/g, "<code>$1</code>")
      html = html.replace(/\*\*([^*\n]+)\*\*/g, "<strong>$1</strong>")
      html = html.replace(/__([^_\n]+)__/g, "<strong>$1</strong>")
      html = html.replace(/(^|[^*])\*([^*\n]+)\*/g, "$1<em>$2</em>")
      html = html.replace(/(^|[^_])_([^_\n]+)_/g, "$1<em>$2</em>")
      html = html.replace(/\[([^\]]+)\]\((https?:\/\/[^\s)]+)\)/g, '<a href="$2" rel="noopener noreferrer">$1</a>')
      return html
    }

    const lines = markdown.replace(/\r\n?/g, "\n").split("\n")
    const blocks = []
    let paragraph = []
    let listItems = []
    const flushParagraph = () => {
      if (paragraph.length) {
        blocks.push("<p>" + paragraph.map(inline).join("<br>") + "</p>")
        paragraph = []
      }
    }
    const flushList = () => {
      if (listItems.length) {
        blocks.push("<ul>" + listItems.map((item) => "<li>" + inline(item) + "</li>").join("") + "</ul>")
        listItems = []
      }
    }

    for (const line of lines) {
      const heading = line.match(/^(#{1,6})\s+(.+)$/)
      const item = line.match(/^\s*[-*+]\s+(.+)$/)
      const quote = line.match(/^>\s?(.*)$/)

      if (line.trim() === "") {
        flushParagraph()
        flushList()
      } else if (heading) {
        flushParagraph()
        flushList()
        const level = heading[1].length
        blocks.push("<h" + level + ">" + inline(heading[2]) + "</h" + level + ">")
      } else if (item) {
        flushParagraph()
        listItems.push(item[1])
      } else if (quote) {
        flushParagraph()
        flushList()
        blocks.push("<blockquote><p>" + inline(quote[1]) + "</p></blockquote>")
      } else {
        flushList()
        paragraph.push(line)
      }
    }
    flushParagraph()
    flushList()
    return blocks.join("")
  }

  htmlToMarkdown(root) {
    const inline = (node) => {
      if (node.nodeType === Node.TEXT_NODE) return node.nodeValue
      if (node.nodeType !== Node.ELEMENT_NODE) return ""

      const content = Array.from(node.childNodes).map(inline).join("")
      switch (node.tagName.toLowerCase()) {
        case "strong":
        case "b": return "**" + content + "**"
        case "em":
        case "i": return "*" + content + "*"
        case "code": return "`" + content + "`"
        case "a": {
          const href = node.getAttribute("href") || ""
          return /^https?:\/\//i.test(href) ? "[" + content + "](" + href + ")" : content
        }
        case "br": return "\n"
        default: return content
      }
    }

    const block = (node) => {
      if (node.nodeType === Node.TEXT_NODE) return node.nodeValue.trim() ? node.nodeValue : ""
      if (node.nodeType !== Node.ELEMENT_NODE) return ""
      const tag = node.tagName.toLowerCase()
      const children = Array.from(node.childNodes).map(block).join("")
      const content = Array.from(node.childNodes).map(inline).join("").trim()

      if (/^h[1-6]$/.test(tag)) return "#".repeat(Number(tag[1])) + " " + content + "\n\n"
      if (tag === "p") return content + "\n\n"
      if (tag === "li") return "- " + content + "\n"
      if (tag === "ul" || tag === "ol") return children + "\n"
      if (tag === "blockquote") {
        return content.split("\n").map((line) => line ? "> " + line : ">").join("\n") + "\n\n"
      }
      if (tag === "pre") return "```\n" + node.textContent + "\n```\n\n"
      return children || content
    }

    return Array.from(root.childNodes).map(block).join("")
      .replace(/[ \t]+\n/g, "\n")
      .replace(/\n{3,}/g, "\n\n")
      .trim()
  }
}
