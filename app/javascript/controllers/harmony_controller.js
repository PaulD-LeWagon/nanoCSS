import { Controller } from "@hotwired/stimulus"

// Per UC-027: replaces inline onclick="document.getElementById(...)..." in
// _harmony_options.html.erb. Eliminates the only ERB→JS string interpolation
// in the codebase, removing the XSS surface (data-* attrs are auto-escaped).
export default class extends Controller {
  apply(event) {
    const btn = event.currentTarget
    const secondary = btn.dataset.harmonySecondary
    const tertiary = btn.dataset.harmonyTertiary

    const secondaryInput = document.getElementById("theme_configuration_secondary")
    const tertiaryInput = document.getElementById("theme_configuration_tertiary")

    if (secondaryInput) secondaryInput.value = secondary
    if (tertiaryInput) tertiaryInput.value = tertiary

    this.element.closest("form")?.requestSubmit()
  }
}
