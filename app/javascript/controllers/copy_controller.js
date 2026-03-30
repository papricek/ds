import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source"]
  static values = { text: String }

  connect() {
    if (["BUTTON", "A"].includes(this.element.tagName)) {
      this.element.style.cursor = "pointer"
    }
  }

  copy(event) {
    const triggerElement = event?.currentTarget || this.element
    const textToCopy = this.textToCopy()

    if (!textToCopy) {
      return
    }

    navigator.clipboard.writeText(textToCopy).then(() => {
      this.showFeedback(triggerElement)
    }).catch(err => {
      console.error("Could not copy text: ", err)
    })
  }

  textToCopy() {
    if (this.hasTextValue) {
      return this.textValue
    }

    if (this.hasSourceTarget) {
      const source = this.sourceTarget

      if (source instanceof HTMLInputElement || source instanceof HTMLTextAreaElement) {
        return source.value
      }

      return source.textContent.trim()
    }

    return ""
  }

  showFeedback(triggerElement) {
    if (!triggerElement) {
      return
    }

    const originalContent = triggerElement.innerHTML
    triggerElement.innerHTML = '<i class="fas fa-check text-success"></i>'
    triggerElement.classList.add("text-success")

    setTimeout(() => {
      triggerElement.innerHTML = originalContent
      triggerElement.classList.remove("text-success")
    }, 1500)
  }
}
