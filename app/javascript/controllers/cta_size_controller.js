import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.resize = this.resize.bind(this)
    this.resize()
    window.addEventListener("resize", this.resize)
  }

  disconnect() {
    window.removeEventListener("resize", this.resize)
  }

  resize() {
    if (!this.hasButtonTarget) return

    this.element.style.removeProperty("--welcome-cta-width")
    const widest = Math.max(...this.buttonTargets.map((button) => button.scrollWidth))
    this.element.style.setProperty("--welcome-cta-width", `${widest}px`)
  }
}
