import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="format-new-place-data"
export default class extends Controller {
  static targets = ['postalCodeInput'];

  connect() {}

  formatPostalCode() {
    const postalCode = this.postalCodeInputTarget.value
    if (postalCode[3] !== " ") this.postalCodeInputTarget.value = postalCode.match(/.{1,3}/g).join(" ")
  }

  openFileUpload(event) {
    const uploadInput = document.querySelector("#place_photos");
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      uploadInput.click()
    }
  }
}
