import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { breakpoint: { type: Number, default: 1080 } }

  connect() {
    this.activeName = this.tabTargets.find(tab => tab.getAttribute("aria-selected") === "true")?.dataset.tabName || "queue"
    this.mediaQuery = window.matchMedia(`(max-width: ${this.breakpointValue}px)`)
    this.handleViewportChange = this.handleViewportChange.bind(this)
    this.mediaQuery.addEventListener("change", this.handleViewportChange)
    this.update()
  }

  disconnect() {
    this.mediaQuery?.removeEventListener("change", this.handleViewportChange)
  }

  select(event) {
    this.activeName = event.currentTarget.dataset.tabName
    this.update()
  }

  navigate(event) {
    if (!["ArrowLeft", "ArrowRight", "Home", "End"].includes(event.key)) return

    event.preventDefault()
    const currentIndex = this.tabTargets.indexOf(event.currentTarget)
    let nextIndex

    if (event.key === "Home") nextIndex = 0
    if (event.key === "End") nextIndex = this.tabTargets.length - 1
    if (event.key === "ArrowLeft") nextIndex = (currentIndex - 1 + this.tabTargets.length) % this.tabTargets.length
    if (event.key === "ArrowRight") nextIndex = (currentIndex + 1) % this.tabTargets.length

    const nextTab = this.tabTargets[nextIndex]
    this.activeName = nextTab.dataset.tabName
    this.update()
    nextTab.focus()
  }

  handleViewportChange() {
    this.update()
  }

  update() {
    const tabMode = this.mediaQuery.matches

    this.tabTargets.forEach(tab => {
      const active = tab.dataset.tabName === this.activeName
      tab.setAttribute("aria-selected", String(active))
      tab.tabIndex = active ? 0 : -1
    })

    this.panelTargets.forEach(panel => {
      const active = panel.dataset.tabName === this.activeName
      panel.hidden = tabMode && !active
      panel.tabIndex = tabMode && active ? 0 : -1
    })
  }
}
