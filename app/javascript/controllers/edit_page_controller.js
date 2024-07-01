import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="edit-page"
export default class extends Controller {
  static tragets = ["photosInput"];

  connect() {}

  enablePhotoInput() {
    const checkboxChangePics = document.querySelector("#change_pics");
    document.querySelector('input[type="file"]').disabled = !checkboxChangePics.checked;
    const label = document.querySelector('.photos-input-container label');
    label.style.color = checkboxChangePics.checked ? "black" : "lightgrey";
  }
}
