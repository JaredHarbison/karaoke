import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle", "details", "newSeries", "existingSeries", "frequency", "customRule"]

  connect() {
    this.update()
  }

  update() {
    const repeats = this.toggleTarget.checked
    this.detailsTarget.hidden = !repeats
    this.setDisabled(this.detailsTarget, !repeats)

    if (!repeats) return

    const mode = this.element.querySelector('input[name="recurrence[mode]"]:checked')?.value
    this.newSeriesTarget.hidden = mode !== "new"
    this.existingSeriesTarget.hidden = mode !== "existing"
    this.setDisabled(this.newSeriesTarget, mode !== "new")
    this.setDisabled(this.existingSeriesTarget, mode !== "existing")
    this.updateFrequency()
  }

  updateFrequency() {
    const custom = this.frequencyTarget.value === "custom"
    this.customRuleTarget.hidden = !custom
    this.setDisabled(this.customRuleTarget, !custom)
  }

  setDisabled(container, disabled) {
    container.querySelectorAll("input, select, textarea").forEach((field) => {
      field.disabled = disabled
    })
  }
}
