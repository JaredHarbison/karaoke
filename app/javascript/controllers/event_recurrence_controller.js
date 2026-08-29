import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle", "details", "frequency", "customSchedule"]

  connect() {
    this.update()
  }

  update() {
    const repeats = this.toggleTarget.checked
    this.detailsTarget.hidden = !repeats
    this.setDisabled(this.detailsTarget, !repeats)

    if (!repeats) return

    this.updateFrequency()
  }

  updateFrequency() {
    const custom = this.frequencyTarget.value === "custom"
    this.customScheduleTarget.hidden = !custom
    this.setDisabled(this.customScheduleTarget, !custom)
  }

  setDisabled(container, disabled) {
    container.querySelectorAll("input, select, textarea").forEach((field) => {
      field.disabled = disabled
    })
  }
}
