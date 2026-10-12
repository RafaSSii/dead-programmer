import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["icon"]
  connect() {
    const saved = localStorage.getItem("dead-programmer-theme")
    const preferred = window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
    this.apply(saved || preferred)
  }
  toggle() { this.apply(document.documentElement.classList.contains("dark") ? "light" : "dark") }
  apply(theme) {
    document.documentElement.classList.toggle("dark", theme === "dark")
    document.documentElement.dataset.theme = theme
    if (this.hasIconTarget) this.iconTarget.textContent = theme === "dark" ? "☀" : "☾"
    localStorage.setItem("dead-programmer-theme", theme)
  }
}
