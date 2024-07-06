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

  updatePhotoLabel() {
    const label = document.querySelector('label[for="place_photos"]');
    const labelText = label.querySelector('p');
    const filesNumber = label.querySelector("input#place_photos").files.length;
    labelText.innerText = `Fotky ${filesNumber}`;
  }
}
