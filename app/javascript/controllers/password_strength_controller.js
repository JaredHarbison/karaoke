import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["password", "confirmation", "message", "match", "bar", "strength"]

  connect() {
    this.update()
  }

  update() {
    const password = this.passwordTarget.value
    const checks = [
      password.length >= 12,
      /[a-z]/.test(password),
      /[A-Z]/.test(password),
      /[0-9]/.test(password)
    ]
    const strength = password.length === 0 ? 0 : checks.filter(Boolean).length

    this.strengthTarget.classList.remove("strength-0", "strength-1", "strength-2", "strength-3", "strength-4")
    this.strengthTarget.classList.add(`strength-${strength}`)

    this.barTargets.forEach((bar, index) => {
      bar.classList.toggle("is-active", index < strength)
    })

    this.messageTarget.textContent = password.length === 0
      ? "Use 12+ characters with uppercase, lowercase, and a number."
      : strength === checks.length
        ? "strong password"
        : "Use 12+ characters with uppercase, lowercase, and a number."
    this.messageTarget.classList.toggle("is-valid", strength === checks.length)

    const confirmation = this.confirmationTarget.value
    const matches = confirmation.length > 0 && password === confirmation
    this.matchTarget.textContent = confirmation.length === 0
      ? ""
      : matches ? "passwords match" : "passwords do not match"
    this.matchTarget.classList.toggle("is-valid", matches)
    this.matchTarget.classList.toggle("is-invalid", confirmation.length > 0 && !matches)
  }
}
