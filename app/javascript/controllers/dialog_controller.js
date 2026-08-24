import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  connect() {
    if (this.hasDialogTarget && this.dialogTarget.hasAttribute("open")) {
      this.dialogTarget.removeAttribute("open")
      this.dialogTarget.showModal()
    }
  }

  open() {
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) {
      this.close()
    }
  }
}
