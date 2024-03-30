import { Controller } from "@hotwired/stimulus"

// Currently is responsible for the dropdown of the oredr from on show page

// Connects to data-controller="show-page"
export default class extends Controller {
  static targets = [ "orderForm", "dropDownChevron", "gallery" ]

  connect() {}

  dropDown() {
    if (this.orderFormTarget.style.opacity === "0" || this.orderFormTarget.style.opacity === "") {
      this.galleryTarget.classList.add("align-items-start")
      this.orderFormTarget.style.visibility = "visible";
      this.orderFormTarget.style.display = "flex";

      setTimeout(() => {
        this.orderFormTarget.style.transform = "translateY(0)";
        this.orderFormTarget.style.opacity = 1;
        this.dropDownChevronTarget.classList.add('rotated')
      }, 500);
    } else {
      this.orderFormTarget.style.opacity = 0;
      this.orderFormTarget.style.transform = "translateY(-20px)";

      setTimeout(() => {
        this.orderFormTarget.style.visibility = "hidden";
        this.orderFormTarget.style.display = "none";
        this.dropDownChevronTarget.classList.remove('rotated')
        this.galleryTarget.classList.remove("align-items-start")
      }, 500);
    }
  }
}
