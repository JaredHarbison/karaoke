import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => {
      this.element.classList.add("is-exiting")
      this.removeTimeout = setTimeout(() => this.element.remove(), 100)
    }, 3900)
  }

  disconnect() {
    clearTimeout(this.timeout)
    clearTimeout(this.removeTimeout)
  }
}
