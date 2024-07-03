import { Controller } from "@hotwired/stimulus"

// Currently is responsible for the dropdown of the oredr from on show page

// Connects to data-controller="show-page"
export default class extends Controller {
  static targets = [ "orderForm", "dropDownChevron", "pictureModal", "pictureModalContainer", "overlay", "mapContainer" ]
  static values = {
    apiKey: String,
    markers: Object
  }

  connect() {
  }

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

  showPictureModal(event) {
    const photoUrl = event.target.dataset.photoUrl;
    this.overlayTarget.style.opacity = 1;
    this.overlayTarget.style.display = "block";
    this.pictureModalContainerTarget.style.display = "block";
    this.pictureModalContainerTarget.style.opacity = 1;
    this.pictureModalTarget.style.backgroundImage = `url('${photoUrl}')`;
  }

  hidePictureModal() {
    this.overlayTarget.style.opacity = 0;
    this.overlayTarget.style.display = "none";
    this.pictureModalContainerTarget.style.opacity = 0;
    this.pictureModalContainerTarget.style.display = "none";
    this.pictureModalTarget.style.backgroundImage = "";
  }
}
