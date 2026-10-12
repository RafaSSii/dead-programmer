import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["format", "markdown", "visual", "visualWrap"]

  connect() { this.switchFormat() }

  switchFormat(event) {
    const visualMode = this.formatTarget.value === "visual"
    this.markdownTarget.hidden = visualMode
    this.visualWrapTarget.hidden = !visualMode

    if (visualMode && !this.visualTarget.dataset.initialized) {
      if (event) {
        // When switching from Markdown, insert plain text rather than interpreting HTML.
        this.visualTarget.textContent = this.markdownTarget.value
      } else {
        // On edit pages, a visual article is stored as sanitized HTML.
        this.visualTarget.innerHTML = this.markdownTarget.value
      }
      this.visualTarget.dataset.initialized = "true"
    } else if (!visualMode && this.visualTarget.dataset.initialized === "true") {
      this.markdownTarget.value = this.visualTarget.innerText
    }
  }

  syncVisual() { this.markdownTarget.value = this.visualTarget.innerHTML }
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
}
