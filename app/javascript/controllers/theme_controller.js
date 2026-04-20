import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const savedTheme = localStorage.getItem("nanocss-theme")
    if (savedTheme === "dark") {
      document.documentElement.setAttribute("data-theme", "dark")
    }
  }

  toggleDark() {
    const isDark = document.documentElement.getAttribute("data-theme") === "dark"
    if (isDark) {
      document.documentElement.removeAttribute("data-theme")
      localStorage.setItem("nanocss-theme", "light")
      console.log("nanoCSS: Switched to light mode.")
    } else {
      document.documentElement.setAttribute("data-theme", "dark")
      localStorage.setItem("nanocss-theme", "dark")
      console.log("nanoCSS: Switched to dark mode.")
    }
  }
  
  applyPreset(event) {
    const themeParams = event.currentTarget.dataset.themeParams
    if (themeParams) {
      window.location.href = `/configure?theme=${themeParams}`
    }
  }
}
