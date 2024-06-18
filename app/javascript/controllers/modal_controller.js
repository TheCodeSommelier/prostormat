import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["modal", "form"];
  connect() {
    console.log("hi");
  }

  showModal(event) {
    this.modalTarget.classList.remove("d-none");
    this.placeId = event.target.dataset.placeId;
    this.#getDataForModal();
  }

  hideModal() {
    this.modalTarget.classList.add("d-none");
    this.formTarget.action = "";
  }

  #getDataForModal() {
    if (this.formTarget.dataset.context === "transferPlace") {
      this.#getTransferUrl();
      document.querySelector("#place").value = this.placeId;
    }
  }

  #getTransferUrl() {
    this.formTarget.action = `/places/${this.placeId}/transfer`;
  }
}
