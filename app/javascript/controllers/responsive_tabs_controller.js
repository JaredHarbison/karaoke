import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { breakpoint: { type: Number, default: 1000 } }

  connect() {
    this.activeName = this.tabTargets.find(tab => tab.getAttribute("aria-selected") === "true")?.dataset.tabName || "queue"
    this.activeName = this.savedTabName() || this.activeName
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
    this.saveTabName()
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
    this.saveTabName()
    this.update()
    nextTab.focus()
  }

  handleViewportChange() {
    this.update()
  }

  update() {
    this.tabTargets.forEach(tab => {
      const active = tab.dataset.tabName === this.activeName
      tab.setAttribute("aria-selected", String(active))
      tab.tabIndex = 0
    })

    this.panelTargets.forEach(panel => {
      const active = panel.dataset.tabName === this.activeName
      panel.hidden = !active
      panel.tabIndex = -1
    })
  }

  savedTabName() {
    const savedName = window.sessionStorage.getItem(this.storageKey)
    if (this.tabTargets.some(tab => tab.dataset.tabName === savedName)) return savedName
  }

  saveTabName() {
    window.sessionStorage.setItem(this.storageKey, this.activeName)
  }

  get storageKey() {
    return `responsive-tabs:${window.location.pathname}`
  }
}
