import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "icon", "text"]

  connect() {
    if (!this.hasInputTarget) {
      const passwordInput = document.querySelector("input[type='password'][data-password-toggle-target='input']")
      if (passwordInput) {
        this._inputElement = passwordInput
      }
    }
  }

  toggle(event) {
    const button = event.currentTarget
    const input = this.hasInputTarget ? this.inputTarget : (this._inputElement || document.querySelector("input[data-password-toggle-target='input']"))
    const icon = button.querySelector("i");

    if (!input) return;

    if (input.type === "password") {
      input.type = "text"
      icon.classList.remove("fa-eye")
      icon.classList.add("fa-eye-slash")
      if (this.hasTextTarget) {
        this.textTarget.textContent = this.textTarget.dataset.hideText || "Skryt heslo"
      }
    } else {
      input.type = "password"
      icon.classList.remove("fa-eye-slash")
      icon.classList.add("fa-eye")
      if (this.hasTextTarget) {
        this.textTarget.textContent = this.textTarget.dataset.showText || "Zobrazit heslo"
      }
    }
  }
}
