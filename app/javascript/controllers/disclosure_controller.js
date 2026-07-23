import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  closeOnOutside(event) {
    if (this.element.open && !this.element.contains(event.target)) {
      this.element.open = false
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape" && this.element.open) {
      this.element.open = false
      this.element.querySelector("summary")?.focus()
    }
  }
}
