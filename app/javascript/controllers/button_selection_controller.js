import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.updateIcons()
    this.element.addEventListener("change", () => this.updateIcons())
  }

  updateIcons() {
    this.element.querySelectorAll(".btn-check").forEach(input => {
      const label = this.element.querySelector(`label[for="${input.id}"]`)
      if (!label) return
      const icon = label.querySelector(".check-icon")
      if (!icon) return
      if (input.checked) {
        icon.classList.remove("d-none")
      } else {
        icon.classList.add("d-none")
      }
    })
  }
}
