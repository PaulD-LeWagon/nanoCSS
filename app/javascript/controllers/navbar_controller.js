import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "toggle"]

  connect() {
    this._keydown = this._keydown.bind(this)
    document.addEventListener("keydown", this._keydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this._keydown)
  }

  toggle() {
    const isOpen = this.menuTarget.classList.toggle("open")
    this.toggleTarget.setAttribute("aria-expanded", String(isOpen))
  }

  close() {
    this.menuTarget.classList.remove("open")
    this.toggleTarget.setAttribute("aria-expanded", "false")
  }

  _keydown(event) {
    if (event.key === "Escape" && this.menuTarget.classList.contains("open")) {
      this.close()
    }
  }
}
