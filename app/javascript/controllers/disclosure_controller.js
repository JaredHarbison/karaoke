import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  close() {
    this.element.open = false
  }

  closeOnOutside(event) {
    if (this.element.open && !this.element.contains(event.target)) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape" && this.element.open) {
      this.close()
      this.element.querySelector("summary")?.focus()
    }
  }
}
