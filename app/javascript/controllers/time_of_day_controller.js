import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label"]

  connect() {
    this.labelTarget.textContent = new Date().getHours() >= 18 ? "Tonight" : "Today"
  }
}
