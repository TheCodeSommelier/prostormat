import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="edit-page"
export default class extends Controller {
  static targets = ["photosInput"];

  connect() {
    setTimeout(() => {
      this.preSelectFilters();
    }, 200);
  }

  enablePhotoInput() {
    const checkboxChangePics = document.querySelector("#change_pics");
    document.querySelector('input[type="file"]').disabled = !checkboxChangePics.checked;
    if (checkboxChangePics.checked) {
      document.querySelector('label[for="place_photos"]').classList.remove("disabled-label")
    } else {
      document.querySelector('label[for="place_photos"]').classList.add("disabled-label")
    }
  }

  preSelectFilters() {
    console.log("I ran");
    const filters = window.placeFilters;
    if (!filters || filters.length === 0) return;

    const uniqueFilters = new Set(filters)
    const filterOptions = Array.from(document.querySelector(".custom-select").querySelectorAll(".item"));

    const filtersToPick = [];

    filterOptions.forEach(option => {
      if (uniqueFilters.has(option.innerText.trim().toLowerCase())) filtersToPick.push(option);
    });

    filtersToPick.forEach(filter => {
      console.log(`Filter ${filter.innerText} clicked`);
      const event = new Event('click', { bubbles: true, cancelable: true });
      filter.dispatchEvent(event);
    });
  }
}
