import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="multi-step-form"
export default class extends Controller {
  connect() {
    this.animateFormInputs();
  }

  animateFormInputs() {
    const labels = document.querySelectorAll(".form-label");
    const inputs = document.querySelectorAll(".form-input");

    labels.forEach((label) => label.classList.add("label-enter-active"));
    inputs.forEach((input) => input.classList.add("input-enter-active"));
  }

  nextStep(event) {
    event.preventDefault();

    const formData = new FormData(this.element);

    fetch(this.element.action, {
      method: "POST",
      body: formData,
      headers: {
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
      },
      credentials: "include",
    })
      .then((response) => response.json())
      .then((data) => {
        window.location.href = data.redirect_url;
      });
  }

  // TODO: Maybe commented out code will be used for stripe form
  async showVenue(event) {
    event.preventDefault();
    await this.moveOutCurrentForm();
  }

  moveOutCurrentForm() {
    return new Promise((resolve) => {
      const placeLabels = document.querySelectorAll(".form-label");
      const placeInputs = document.querySelectorAll(".form-input");

      placeLabels.forEach((label) =>
        label.classList.add("label-exit-left", "active")
      );
      placeInputs.forEach((input) =>
        input.classList.add("input-exit-right", "active")
      );

      setTimeout(() => {
        // this.appendVenueForm();
        resolve()
      }, 1000);
    })
  }

  // appendVenueForm() {
  //   const numberOfVenues = parseInt(
  //     document.querySelector("#number_of_venues").value
  //   );
  //   const placeInputsContainers = document.querySelectorAll(".input-container");

  //   placeInputsContainers.forEach((container) => {
  //     container.style.display = "none";
  //   });

  //   requestAnimationFrame(() => {
  //     for (let i = 0; i < numberOfVenues; i++) {
  //       this.createAndInsertVenueForm(i);
  //     }
  //   });
  // }

  // createAndInsertVenueForm(index) {
  //   const nextButton = this.element.querySelector("button");
  //   const venueFormHtml = this.venueFormTemplate(index);

  //   nextButton.insertAdjacentHTML("beforebegin", venueFormHtml);

  //   requestAnimationFrame(() => {
  //     document.querySelectorAll(".venue-title").forEach((title) => {
  //       title.classList.add("show-title");
  //     });
  //     document.querySelectorAll(`.venue${index}-label`).forEach((label) => {
  //       label.classList.remove("d-none");
  //       label.classList.add("label-enter-left", "label-enter-active");
  //     });
  //     document.querySelectorAll(`.venue${index}-input`).forEach((input) => {
  //       input.classList.remove("d-none");
  //       input.classList.add("input-enter-right", "input-enter-active");
  //     });
  //     document
  //       .querySelector('input[type="submit"]')
  //       .classList.add("show-submit");
  //   });
  // }

  // venueFormTemplate(index) {
  //   return `
  //   <h3 class="venue-title hidden-title">Prostor číslo ${index + 1}</h3>
  //   <div class="input-container d-flex">
  //     <div class="input-container col-6">
  //       <label for="place_venues_attributes_${index}_name" class="form-label venue${index}-label label-start-position d-none">Jméno prostoru</label>
  //       <input type="text" name="place[venues_attributes][${index}][venue_name]" class="venue-input venue${index}-input input-start-position form-control d-none" placeholder="Ballet room" id="place_venues_attributes_${index}_name">
  //     </div>
  //     <div class="input-container col-6">
  //       <label for="place_venues_attributes_${index}_capacity" class="form-label venue${index}-label label-start-position d-none">Kapacita</label>
  //       <input type="number" name="place[venues_attributes][${index}][capacity]" class="venue-input venue${index}-input input-start-position form-control d-none" placeholder="20" id="place_venues_attributes_${index}_capacity">
  //     </div>
  //   </div>
  //   <div class="input-container col-12">
  //     <label for="place_venues_attributes_${index}_photo" class="form-label venue${index}-label label-start-position d-none">Přidejte fotku</label>
  //     <input type="file" name="place[venues_attributes][${index}][photo]" id="place_venues_attributes_${index}_photo" class="venue-input venue${index}-input input-start-position form-control d-none">
  //   </div>
  //   <div class="input-container">
  //     <label for="place_venues_attributes_${index}_description" class="form-label venue${index}-label label-start-position d-none">Popište váš prostor</label>
  //     <textarea type="text" name="place[venues_attributes][${index}][description]" class="venue-input venue${index}-input input-start-position form-control d-none" placeholder="Povězte nám víc..." id="place_venues_attributes_${index}_description"></textarea>
  //   </div>
  //   `;
  // }
}
