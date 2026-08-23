import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.markVisited = this.markVisited.bind(this)
    this.restoreVisited()
    this.element.addEventListener("click", this.markVisited)
  }

  disconnect() {
    this.element.removeEventListener("click", this.markVisited)
  }

  restoreVisited() {
    this.links.forEach((link) => {
      if (sessionStorage.getItem(this.storageKey(link))) link.classList.add("welcome-button--visited")
    })
  }

  markVisited(event) {
    const link = event.target.closest("a.welcome-button")
    if (!link) return

    link.classList.add("welcome-button--visited")
    sessionStorage.setItem(this.storageKey(link), "true")
  }

  get links() {
    return this.element.querySelectorAll("a.welcome-button")
  }

  storageKey(link) {
    return `karaoke-cta:${link.href}`
  }
}
