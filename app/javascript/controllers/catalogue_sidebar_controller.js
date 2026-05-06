import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["navLink"]

  connect() {
    this.observer = new IntersectionObserver(
      (entries) => this.#onIntersect(entries),
      { rootMargin: "-5% 0px -75% 0px", threshold: 0 }
    )
    document.querySelectorAll(".component-section[id]").forEach(section => {
      this.observer.observe(section)
    })
  }

  disconnect() {
    this.observer?.disconnect()
  }

  #onIntersect(entries) {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return
      const id = entry.target.id
      this.navLinkTargets.forEach(link => {
        link.classList.toggle("active", link.dataset.sectionId === id)
      })
    })
  }
}
