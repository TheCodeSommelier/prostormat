import { Controller } from "@hotwired/stimulus";

// AJAX call that searches for palces upon key down.
// When key is pressed ajax makes a call to the "places?query=" endpoint and retrieves records from the DB.
// The updates the card grid with it.

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["searchTextField", "capacityNumberField"];

  connect() {}

  startSearch(event) {
    const query = this.searchTextFieldTarget.value;

    if (["Shift", "Meta", "Control", "Alt"].includes(event.key)) {
      return;
    }

    fetch(`/places?query=${encodeURIComponent(query)}`, {
      method: "GET",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error("Network response was not ok");
        }
        return response.json();
      })
      .then((data) => {
        this.#updateCardGrid(data.html);
      })
      .catch((error) => console.error("Error:", error));
  }

  #updateCardGrid(html) {
    const cardGridContainer = document.querySelector("#index-card-grid");
    if (cardGridContainer) {
      cardGridContainer.innerHTML = html;
    }
  }
}
