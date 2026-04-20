import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "dropdownContainer", "searchInput", "hiddenInput" ]

  connect() {
    this.activeIndex = -1
    document.addEventListener("click", this.closeAll.bind(this))
  }

  disconnect() {
    document.removeEventListener("click", this.closeAll.bind(this))
  }

  open(event) {
    const container = event.currentTarget.closest('.custom-font-select')
    this.closeAll()
    const list = container.querySelector('.font-dropdown-list')
    list.style.display = 'block'
    
    // Fetch initial list if empty
    if (list.children.length === 0) {
      this.fetchFonts("", container)
    }
  }

  closeAll(event) {
    if (event && event.target.closest('.custom-font-select')) return
    this.dropdownContainerTargets.forEach(container => {
      const list = container.querySelector('.font-dropdown-list')
      if (list) list.style.display = 'none'
    })
    this.activeIndex = -1
  }

  search(event) {
    const input = event.currentTarget
    const query = input.value
    const container = input.closest('.custom-font-select')
    
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.fetchFonts(query, container)
    }, 300)
  }

  async fetchFonts(query, container) {
    try {
      const response = await fetch(`/fonts?q=${encodeURIComponent(query)}`)
      const data = await response.json()
      this.populateDropdown(container, data.fonts)
    } catch (error) {
      console.error("Error fetching fonts catalogue:", error)
    }
  }

  populateDropdown(container, fonts) {
    const list = container.querySelector('.font-dropdown-list')
    const currentSelected = container.querySelector('input[type="hidden"]').value
    
    list.innerHTML = ""
    this.activeIndex = -1
    
    const allFonts = ["System Default", ...fonts]
    
    // Inject dynamic stylesheet for the fonts so they render correctly in the list
    const fontNames = fonts.map(f => f.replace(/ /g, '+'))
    if (fontNames.length > 0) {
      const link = document.createElement('link')
      link.rel = 'stylesheet'
      link.href = `https://fonts.googleapis.com/css2?${fontNames.map(f => `family=${f}`).join('&')}&display=swap`
      document.head.appendChild(link)
    }

    allFonts.forEach((font, index) => {
      const item = document.createElement('div')
      item.dataset.action = "click->fonts#select mouseenter->fonts#hover"
      item.dataset.index = index
      item.dataset.font = font === "System Default" ? "" : font
      item.style.padding = "0.5rem 1rem"
      item.style.cursor = "pointer"
      item.style.fontFamily = font === "System Default" ? "system-ui, sans-serif" : font
      item.style.color = (item.dataset.font === currentSelected) ? "var(--chrome-brand-a)" : "var(--chrome-text)"
      item.className = "font-option"
      
      const span = document.createElement('span')
      span.textContent = font
      item.appendChild(span)
      
      list.appendChild(item)
    })
  }

  hover(event) {
    const item = event.currentTarget
    const list = item.parentElement
    this.updateActiveItem(list, parseInt(item.dataset.index, 10))
  }

  handleKeydown(event) {
    const container = event.currentTarget.closest('.custom-font-select')
    const list = container.querySelector('.font-dropdown-list')
    const items = list.querySelectorAll('.font-option')
    
    if (list.style.display === 'none' && (event.key === 'ArrowDown' || event.key === 'Enter')) {
      this.open(event)
      event.preventDefault()
      return
    }

    if (event.key === 'ArrowDown') {
      event.preventDefault()
      this.updateActiveItem(list, this.activeIndex + 1 >= items.length ? 0 : this.activeIndex + 1)
    } else if (event.key === 'ArrowUp') {
      event.preventDefault()
      this.updateActiveItem(list, this.activeIndex - 1 < 0 ? items.length - 1 : this.activeIndex - 1)
    } else if (event.key === 'Enter' || event.key === 'Tab') {
      if (this.activeIndex >= 0 && this.activeIndex < items.length) {
        event.preventDefault()
        this.selectItem(items[this.activeIndex], container)
      } else {
        // If they just press enter on what they typed
        this.closeAll()
      }
    } else if (event.key === 'Escape') {
      this.closeAll()
    }
  }

  updateActiveItem(list, index) {
    const items = list.querySelectorAll('.font-option')
    if (items.length === 0) return
    
    items.forEach((item, i) => {
      if (i === index) {
        item.style.background = "rgba(255,255,255,0.05)"
      } else {
        item.style.background = "transparent"
      }
    })
    this.activeIndex = index
    
    // Scroll into view
    const activeItem = items[index]
    if (activeItem) {
      const offsetBottom = activeItem.offsetTop + activeItem.offsetHeight
      if (offsetBottom > list.scrollTop + list.offsetHeight) {
        list.scrollTop = offsetBottom - list.offsetHeight
      } else if (activeItem.offsetTop < list.scrollTop) {
        list.scrollTop = activeItem.offsetTop
      }
    }
  }

  select(event) {
    const item = event.currentTarget
    const container = item.closest('.custom-font-select')
    this.selectItem(item, container)
  }

  selectItem(item, container) {
    const font = item.dataset.font
    
    const hiddenInput = container.querySelector('input[type="hidden"]')
    hiddenInput.value = font
    
    const searchInput = container.querySelector('input[type="text"]')
    searchInput.value = font || "System Default"
    searchInput.style.fontFamily = font || "system-ui, sans-serif"
    
    this.closeAll()
    
    hiddenInput.form.requestSubmit()
  }
}
