import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]
  
  connect() {
    // Initially hide instructions
    this.contentTarget.style.display = 'none'
    this.updateButtonText()
  }
  
  toggle() {
    if (this.contentTarget.style.display === 'none') {
      this.contentTarget.style.display = 'block'
    } else {
      this.contentTarget.style.display = 'none'
    }
    this.updateButtonText()
  }
  
  updateButtonText() {
    const button = this.element.querySelector('button')
    if (this.contentTarget.style.display === 'none') {
      button.textContent = 'Show Instructions'
    } else {
      button.textContent = 'Hide Instructions'
    }
  }
}
