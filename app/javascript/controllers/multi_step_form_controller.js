import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="multi-step-form"
export default class extends Controller {
  connect() {
    console.log("Multi step form controller here!");
    this.formCouter = 0;
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

  showVenue(event) {
    event.preventDefault();
    this.moveOutCurrentForm();
  }

  moveOutCurrentForm() {
    const placeLabels = document.querySelectorAll(".place-label");
    const placeInputs = document.querySelectorAll(".place-input");
    const nextButton = this.element.querySelector("button");

    placeLabels.forEach((label) =>
      label.classList.add("label-exit-left", "active")
    );
    placeInputs.forEach((input) =>
      input.classList.add("input-exit-right", "active")
    );
    nextButton.classList.add("hidden-next");

    setTimeout(() => {
      this.appendVenueForm();
      nextButton.style.display = 'none';
    }, 1000);
  }

  appendVenueForm() {
    const numberOfVenues = parseInt(
      document.querySelector("#number_of_venues").value
    );
    const placeInputsContainers = document.querySelectorAll(".input-container");

    placeInputsContainers.forEach((container) => {
      container.style.display = "none";
    });

    requestAnimationFrame(() => {
      for (let i = 0; i < numberOfVenues; i++) {
        this.createAndInsertVenueForm(i + 1);
      }
    });
  }

  createAndInsertVenueForm(index) {
    const nextButton = this.element.querySelector("button");
    const venueFormHtml = this.venueFormTemplate(index);

    nextButton.insertAdjacentHTML("beforebegin", venueFormHtml);

    requestAnimationFrame(() => {
      document.querySelectorAll(".venue-title").forEach((title) => {
        title.classList.add("show-title");
      });
      document.querySelectorAll(`.venue${index}-label`).forEach((label) => {
        label.classList.add("label-enter-left", "label-enter-active");
      });
      document.querySelectorAll(`.venue${index}-input`).forEach((input) => {
        input.classList.add("input-enter-right", "input-enter-active");
      });
      document.querySelector('input[type="submit"]').classList.add("show-submit");
    });
  }

  venueFormTemplate(index) {
    return `
    <h3 class="venue-title hidden-title">Venue number ${index}</h3>
    <div class="input-container">
      <label for="place_venues_attributes_${index}_name" class="venue${index}-label label-start-position">Name:</label>
      <input type="text" name="venues${index}[name]" class="venue${index}-input input-start-position" id="place_venues_attributes_${index}_name">
    </div>
    <div class="input-container">
      <label for="place_venues_attributes_${index}_capacity" class="venue${index}-label label-start-position">Capacity:</label>
      <input type="number" name="venues${index}[capacity]" class="venue${index}-input input-start-position" id="place_venues_attributes_${index}_capacity">
    </div>
    <div class="input-container">
      <label for="place_venues_attributes_${index}_description" class="venue${index}-label label-start-position">Description:</label>
      <textarea type="text" name="venues${index}[description]" class="venue${index}-input input-start-position" id="place_venues_attributes_${index}_description"></textarea>
    </div>
    `;
  }
}
