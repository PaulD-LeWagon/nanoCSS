import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const saved = localStorage.getItem("nanocss-theme")
    if (saved === "dark" || saved === "light") {
      // Honour explicitly saved preference (Tier 3)
      document.documentElement.setAttribute("data-theme", saved)
    } else if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
      // Honour OS preference on first visit — sets data-theme so Tier 2 manages it
      document.documentElement.setAttribute("data-theme", "dark")
    } else {
      // Default explicit light — protects component renders from unintentional OS media-query
      document.documentElement.setAttribute("data-theme", "light")
    }
  }

  toggleDark() {
    const isDark = document.documentElement.getAttribute("data-theme") === "dark"
    if (isDark) {
      // UC-047: explicitly set "light" — do NOT remove the attribute.
      // Removing the attribute lets @media prefers-color-scheme re-engage,
      // which breaks the toggle on dark-OS machines.
      document.documentElement.setAttribute("data-theme", "light")
      localStorage.setItem("nanocss-theme", "light")
    } else {
      document.documentElement.setAttribute("data-theme", "dark")
      localStorage.setItem("nanocss-theme", "dark")
    }
  }

  applyPreset(event) {
    const themeParams = event.currentTarget.dataset.themeParams
    if (themeParams) {
      window.location.href = `/configure?theme=${themeParams}`
    }
  }
}
