import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "newThemeFields"]
  static values = { existingNames: Array }

  connect() {
    this.update()
  }

  update() {
    const typedName = this.nameTarget.value.trim().toLocaleLowerCase()
    const isExistingTheme = this.existingNamesValue.some((name) => name.toLocaleLowerCase() === typedName)

    this.newThemeFieldsTarget.hidden = typedName.length === 0 || isExistingTheme
  }
}
