import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="multi-step-form"
export default class extends Controller {
  connect() {
    console.log("Multi step form controller here!");
    this.formCouter = 0;
    this.venuesId = 1;
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
    const nextButton = document.querySelector("button");
    const placeInputs = Array.from(document.querySelectorAll(".place-input"));

    this.cleanPreviousVenue();

    const venueForm = `
    <div>
    <label for="place_venues_attributes_${this.venuesId}_name">Name:</label>
    <input type="text" name="venues${this.venuesId}[name]" class="venue${this.venuesId}" id="place_venues_attributes_${this.venuesId}_name">
    </div>
    <div>
    <label for="place_venues_attributes_${this.venuesId}_capacity">Capacity:</label>
    <input type="number" name="venues${this.venuesId}[capacity]" class="venue${this.venuesId}" id="place_venues_attributes_${this.venuesId}_capacity">
    </div>
    <div>
    <label for="place_venues_attributes_${this.venuesId}_description">Description:</label>
    <textarea type="text" name="venues${this.venuesId}[description]" class="venue${this.venuesId}" id="place_venues_attributes_${this.venuesId}_description"></textarea>
    </div>
    `;
    this.cleanPlacesInputs(placeInputs);

    nextButton.insertAdjacentHTML("beforebegin", venueForm);
    this.venuesId++;
    this.venueFormCounter(nextButton);

    // When button next is clicked d-none is applied to current form
    // Forms for two venues are built out infront of the customer
    // This porcess repeats until there are no more venues to fill a form out for
    // the submit button appears and upon click send everything to the backend
  }

  cleanPlacesInputs(placeInputs) {
    placeInputs.forEach((input) => {
      input.classList.add("d-none");
    });
  }

  cleanPreviousVenue() {
    const previousVenueInputs = document.querySelectorAll(
      `.venue${this.venuesId - 1}`
    );
    previousVenueInputs.forEach((input) => {
      input.parentNode.classList.add('d-none');
    });
  }

  venueFormCounter(nextButton) {
    const number_of_venues = parseInt(
      document.querySelector("#number_of_venues").value
    );
    const submitButton = document.querySelector('input[type="submit"]');
    this.formCouter++;

    if (number_of_venues === this.formCouter) {
      submitButton.classList.remove("d-none");
      nextButton.classList.add("d-none", "disable");
    }
  }
}
