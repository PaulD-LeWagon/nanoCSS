import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this._outsideClick = this._outsideClick.bind(this)
    this._keydown = this._keydown.bind(this)
    document.addEventListener("click", this._outsideClick)
    document.addEventListener("keydown", this._keydown)
  }

  disconnect() {
    document.removeEventListener("click", this._outsideClick)
    document.removeEventListener("keydown", this._keydown)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    if (!this.element.classList.contains("open")) {
      // Close any other open dropdowns on the page before opening this one
      document.querySelectorAll("[data-controller~='dropdown'].open").forEach(el => {
        if (el !== this.element) el.classList.remove("open")
      })
    }

    this.element.classList.toggle("open")
  }

  close() {
    this.element.classList.remove("open")
  }

  _outsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  _keydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
