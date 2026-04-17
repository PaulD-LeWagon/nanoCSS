import { Controller } from "@hotwired/stimulus"

// Fetches fonts from the nanoCSS /fonts endpoint and populates the connected <select> element.
export default class extends Controller {
  static targets = [ "select" ]
  static values = {
    selected: String
  }

  connect() {
    this.fetchFonts()
  }

  async fetchFonts() {
    try {
      const response = await fetch('/fonts')
      const data = await response.json()
      
      this.populateSelects(data.fonts)
    } catch (error) {
      console.error("Error fetching fonts catalogue:", error)
    }
  }

  populateSelects(fonts) {
    this.selectTargets.forEach((selectAttr) => {
      // Clear existing, keeping placeholder if we wanted, but we will just overwrite
      const currentSelected = selectAttr.getAttribute('data-fonts-selected-value') || this.selectedValue
      
      selectAttr.innerHTML = ""
      
      // Optional Empty Placeholder
      const placeHolder = document.createElement('option')
      placeHolder.value = ""
      placeHolder.text = "System Default"
      selectAttr.appendChild(placeHolder)

      fonts.forEach(font => {
        const option = document.createElement('option')
        option.value = font
        option.text = font
        if (font === currentSelected) {
          option.selected = true
        }
        selectAttr.appendChild(option)
      })
    })
  }
}
