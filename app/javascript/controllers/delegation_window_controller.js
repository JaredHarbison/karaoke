import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startsAt", "endsAt"]
  static values = { eventStartsAt: String, eventEndsAt: String }

  connect() {
    this.update()
  }

  update() {
    this.endsAtTarget.min = this.startsAtTarget.value || this.eventStartsAtValue
    this.clearErrors()
  }

  validate(event) {
    const invalidTarget = this.invalidTarget()
    if (!invalidTarget) return

    event.preventDefault()
    invalidTarget.reportValidity()
  }

  invalidTarget() {
    const startsAt = this.startsAtTarget.value
    const endsAt = this.endsAtTarget.value
    const startError = this.startsAtError(startsAt, endsAt)
    const endError = this.endsAtError(startsAt, endsAt)

    this.startsAtTarget.setCustomValidity(startError)
    this.endsAtTarget.setCustomValidity(endError)

    startError ? this.startsAtTarget : (endError ? this.endsAtTarget : null)
  }

  startsAtError(startsAt, endsAt) {
    if (startsAt < this.eventStartsAtValue) return "Choose a start time within the event window."
    if (this.eventEndsAtValue && startsAt > this.eventEndsAtValue) return "Choose a start time within the event window."
    if (startsAt && endsAt && startsAt >= endsAt) return "The delegation must end after it starts."

    ""
  }

  endsAtError(startsAt, endsAt) {
    if (this.eventEndsAtValue && endsAt > this.eventEndsAtValue) return "Choose an end time within the event window."
    if (startsAt && endsAt && endsAt <= startsAt) return "The delegation must end after it starts."

    ""
  }

  clearErrors() {
    this.startsAtTarget.setCustomValidity("")
    this.endsAtTarget.setCustomValidity("")
  }
}
