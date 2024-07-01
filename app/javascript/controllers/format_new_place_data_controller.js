import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="format-new-place-data"
export default class extends Controller {
  static targets = ['postalCodeInput'];

  connect() {}

  formatPostalCode() {
    const postalCode = this.postalCodeInputTarget.value
    this.postalCodeInputTarget.value = postalCode.match(/.{1,3}/g).join(" ")
  }
}
