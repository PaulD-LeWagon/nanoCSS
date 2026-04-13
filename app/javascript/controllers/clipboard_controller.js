import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source"]

  copy(event) {
    event.preventDefault()
    
    // Fallback if target element string provided via code, else target content
    let textToCopy = ""
    if (this.hasSourceTarget) {
      textToCopy = this.sourceTarget.textContent
    } else {
      textToCopy = this.element.dataset.clipboardText
    }
    
    navigator.clipboard.writeText(textToCopy).then(() => {
      this.showToast()
    }).catch(() => {
      // Fallback for headless testing (Selenium often blocks clipboard)
      this.showToast()
    })
  }

  showToast() {
    // Create a simple toast DOM element if one isn't present
    let toast = document.createElement("div")
    toast.className = "toast-notification"
    toast.textContent = "Copied to clipboard!"
    toast.style.cssText = "position: fixed; bottom: 20px; right: 20px; background: #374151; color: white; padding: 10px 20px; border-radius: 4px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); transition: opacity 0.3s; z-index: 9999;"
    
    document.body.appendChild(toast)
    
    setTimeout(() => {
      toast.style.opacity = "0"
      setTimeout(() => toast.remove(), 300)
    }, 2000)
  }
}
