import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="loader"
export default class extends Controller {
  static targets = ["form", "loader", "percentage", "loaderContainer", "loaderMessage" ];

  connect() {
    console.log("Hi from loader")
    this.#hideLoader()
  }

  nextStep(event) {
    event.preventDefault();

    const formData = new FormData(this.element);
    const context = this.element.dataset.context;

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
        if (context === "new-place") {
          window.location.href = data.redirect_url;
        }
      });
  }

  startLoading() {
    const totalImages = this.element.querySelector("[type=file]").files.length;
    let progress = 0;

    this.loaderContainerTarget.classList.remove("d-none");

    clearInterval(this.progressInterval);

    const interval = setInterval(() => {
      progress += 100 / ((totalImages || 1) * 2);
      this.percentageTarget.innerHTML = `${Math.min(Math.round(progress), 100)}<span>%</span>`;

      if (progress < 20) {
        this.loaderMessageTarget.textContent = 'Ukládám jméno...'
      } else if (progress > 20 && progress < 50) {
        this.loaderMessageTarget.textContent = 'Spojuji filtry...'
      } else if (progress > 50 && progress < 75) {
        this.loaderMessageTarget.textContent = 'Ukládám popisky...'
      } else if (progress > 75) {
        this.loaderMessageTarget.textContent = 'Nahrávám fotky...'
      }

      if (progress >= 100) {
        clearInterval(interval);
      }
    }, 1000);
  }

  #hideLoader() {
    this.loaderContainerTarget.classList.add("d-none");
  }

  handleImageLoad(event) {
    const image  = event.target;
    const loader = image.previousElementSibling;

    loader.style.display = 'none';
    image.style.visibility = 'visible';
    image.style.opacity = '1';
  }
}
