import { Controller } from "@hotwired/stimulus";
import FormUtils from "modules/form_utils";

// Connects to data-controller="filter-select"
export default class extends Controller {
  static targets = ["selectItems"];

  connect() {
    document.addEventListener("click", this.handleClickOutside.bind(this));
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside.bind(this));
  }

  rollOutSelect() {
    const isSelectVisible = this.selectItemsTarget.style.display === "none";
    this.selectItemsTarget.style.display = isSelectVisible ? "flex" : "none";
  }

  selectOption(event) {
    event.stopPropagation();
    const filter = event.target;

    filter.classList.contains("highlight")
      ? filter.classList.remove("highlight")
      : filter.classList.add("highlight");
    this.#toggleHiddenInput(filter);
    this.#updateFiltersLabel();
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.selectItemsTarget.style.display = "none";
    }
  }

  openSelect(event) {
    const isSelectVisible = this.selectItemsTarget.style.display === "none";
    if (isSelectVisible && (event.key === "Enter" || event.key === " "))
      this.rollOutSelect();
  }

  keepOpen() {
    clearTimeout(this.closeTimeout);
  }

  closeSelect(event) {
    this.closeTimeout = setTimeout(() => {
      if (!this.element.contains(event.relatedTarget)) {
        this.element.setAttribute("aria-expanded", "false");
        this.selectItemsTarget.style.display = "none";
      }
    }, 100);
  }

  selectOptionKeyboard(event) {
    if (event.key === "Enter") this.selectOption(event);
  }

  #toggleHiddenInput(filter) {
    const isHiddenInput =
      filter.nextSibling.tagName === "INPUT" &&
      filter.nextSibling.type === "hidden";
    if (isHiddenInput) {
      filter.nextSibling.remove();
    } else {
      const hiddenInput = FormUtils.buildInput(
        "hidden",
        "place[filter_ids][]",
        filter.dataset.filterId,
        null,
        false
      );
      filter.insertAdjacentElement("afterend", hiddenInput);
    }
  }

  #updateFiltersLabel() {
    const customSelect = document.querySelector(".custom-select");
    const selectedOptionsNumber = Array.from(
      customSelect.querySelectorAll(".highlight")
    ).length;
    const label = customSelect.querySelector(".custom-label");
    if (selectedOptionsNumber > 0) {
      label.innerText = `Filtry ${selectedOptionsNumber}`;
      label.style.color = "#252625";
    } else {
      label.innerText = "Filtry";
      label.style.color = "";
    }
  }
}
