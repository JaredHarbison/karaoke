import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String, version: String }

  connect() {
    if (!this.hasUrlValue) return

    this.timer = window.setInterval(() => this.refresh(), 3_000)
    this.handleVisibilityChange = () => this.refresh()
    document.addEventListener("visibilitychange", this.handleVisibilityChange)
  }

  disconnect() {
    window.clearInterval(this.timer)
    document.removeEventListener("visibilitychange", this.handleVisibilityChange)
  }

  async refresh() {
    if (document.hidden || document.querySelector(".song-player:not([hidden])")) return

    try {
      const response = await fetch(this.urlValue, { headers: { Accept: "application/json" } })
      const state = await response.json()
      if (response.ok && state.version !== this.versionValue) window.location.reload()
    } catch (_error) {
      // The next poll will reconcile the queue after a transient network error.
    }
  }
}
