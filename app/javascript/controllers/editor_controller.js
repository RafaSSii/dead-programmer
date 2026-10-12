import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["format", "markdown", "visual", "visualWrap"]
  connect() { this.switchFormat() }
  switchFormat() {
    const visual = this.formatTarget.value === "visual"
    this.markdownTarget.hidden = visual
    this.visualWrapTarget.hidden = !visual
    if (visual && !this.visualTarget.dataset.initialized) {
      this.visualTarget.innerHTML = this.markdownTarget.value
      this.visualTarget.dataset.initialized = "true"
    } else if (!visual && this.visualTarget.dataset.initialized === "true") {
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
