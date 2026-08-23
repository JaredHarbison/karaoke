import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { duration: { type: Number, default: 1400 } }

  connect() {
    this.markVisited = this.markVisited.bind(this)
    this.element.addEventListener("click", this.markVisited)
  }

  disconnect() {
    this.element.removeEventListener("click", this.markVisited)
  }

  markVisited(event) {
    const link = event.target.closest("a.welcome-button")
    if (!link) return

    link.classList.add("welcome-button--visited")
    window.setTimeout(() => link.classList.remove("welcome-button--visited"), this.durationValue)
  }
}
