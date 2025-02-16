import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    duration: { type: Number, default: 25000 }
  }

  connect() {
    setTimeout(() => {
      this.dismiss()
    }, this.durationValue)
  }

  dismiss() {
    // Add fade-out animation
    this.element.classList.add('opacity-0')
    // Remove element after animation completes
    this.element.addEventListener('transitionend', () => {
      this.element.remove()
    }, { once: true })
  }
}