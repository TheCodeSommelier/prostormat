import { Controller } from "@hotwired/stimulus";
import Validator from "modules/validator";

// Connects to data-controller="format-new-place-data"
export default class extends Controller {
  static targets = ["postalCodeInput"];

  connect() {
    this.element.addEventListener("submit", (event) => {
      event.preventDefault();
      if (!this.#validateFormData()) {
        console.error("I ran failed validation");
        Validator.dispatchValidationFailed(this.element);
      } else {
        this.element.submit();
        Validator.dispatchValidationPassed(this.element);
      }
    });
  }

  formatPostalCode() {
    const postalCode = this.postalCodeInputTarget.value;
    if (postalCode[3] !== " ")
      this.postalCodeInputTarget.value = postalCode.match(/.{1,3}/g).join(" ");
  }

  openFileUpload(event) {
    const uploadInput = document.querySelector("#place_photos");
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      uploadInput.click();
    }
  }

  updatePhotoLabel() {
    const label = document.querySelector('label[for="place_photos"]');
    const labelText = label.querySelector("p");
    const filesNumber = label.querySelector("input#place_photos").files.length;
    labelText.innerText = `Fotky ${filesNumber}`;
    if (filesNumber > 0) {
      labelText.innerText = `Fotky ${filesNumber}`;
      labelText.style.color = "#252625";
    } else {
      labelText.innerText = "Fotky";
      labelText.style.color = "";
    }
  }

  // Private

  #validateFormData() {
    const filterInput = document.querySelector(".custom-select");
    const fileInput = document.querySelector('input[type="file"]');
    const filterValidation = filterInput ? this.#validateFiltersData() : null
    const fileValidation = fileInput ? this.#fileInputValidation() : null
    const validationsPasses = [ filterValidation.isValid, fileValidation.isValid ];

    if (filterValidation && !filterValidation.isValid) {
      Validator.setFlashMessage(this.element, filterValidation.message);
      validationsPasses.push(fileValidation.isValid)
    }

    if (fileValidation && !fileValidation.isValid) {
      Validator.setFlashMessage(this.element, fileValidation.message);
      validationsPasses.push(fileValidation.isValid)
    }

    if (validationsPasses.includes(false)) Validator.dispatchValidationFailed(this.element);

    return validationsPasses.every(pass => pass === true);
  }

  #validateFiltersData() {
    const filterValidObject = Validator.validateCustomSelect();
    const styling = filterValidObject.isValid
      ? "3px solid #26A387"
      : "3px solid #ff0000";
    document.querySelector(".custom-select").style.borderBottom = styling;
    return filterValidObject;
  }

  #fileInputValidation() {
    const fileInput = this.element.querySelector('input[type="file"]');
    const fileInputLabel = this.element.querySelector('label[for="place_photos"]');
    const filesValidObject = Validator.validateFileInput(fileInput);
    const styling = filesValidObject.isValid ? "3px solid #26A387" : "3px solid #ff0000";
    fileInputLabel.style.borderBottom = styling;
    return filesValidObject;
  }
}
