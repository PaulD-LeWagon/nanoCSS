import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["window"]

  connect() {
    // On initial page load, fade in once the page is rendered.
    // Use requestAnimationFrame to ensure the opacity:0 is painted first.
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        this.fadeIn()
      })
    })

    // Listen for Turbo Stream responses that replace the stylesheet link.
    // When that happens, fade out immediately, then wait for the new sheet
    // to load before fading back in.
    this.element.addEventListener("turbo:before-stream-render", this.onBeforeStream)
  }

  disconnect() {
    this.element.removeEventListener("turbo:before-stream-render", this.onBeforeStream)
  }

  // Arrow fn so `this` is bound correctly
  onBeforeStream = (event) => {
    // Only intercept streams targeting our preview style div
    const action = event.detail?.newStream
    if (!action) return
    if (action.getAttribute("target") !== "nanocss-preview-style") return

    // Fade out, then allow the stream to render
    this.fadeOut()
  }

  // Called via data-action="load->preview#onStyleLoad" on the <link> tag
  onStyleLoad() {
    this.fadeIn()
  }

  fadeIn() {
    if (!this.hasWindowTarget) return
    const el = this.windowTarget
    el.style.transition = "opacity 0.45s ease-in-out"
    el.style.opacity   = "1"
  }

  fadeOut() {
    if (!this.hasWindowTarget) return
    const el = this.windowTarget
    el.style.transition = "opacity 0.2s ease-in-out"
    el.style.opacity   = "0"
  }
}
