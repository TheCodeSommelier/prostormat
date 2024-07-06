import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["modal", "form"];
  connect() {}

  showModal(event) {
    this.modalTarget.classList.remove("d-none");
    this.placeSlug = event.target.dataset.placeSlug;
    this.#getDataForModal();
  }

  hideModal() {
    this.modalTarget.classList.add("d-none");
    this.formTarget.action = "";
  }

  #getDataForModal() {
    if (this.formTarget.dataset.context === "transferPlace") {
      this.#getTransferUrl();
      document.querySelector("#place").value = this.placeSlug;
    }
  }

  #getTransferUrl() {
    this.formTarget.action = `/places/${this.placeSlug}/transfer`;
  }
}
