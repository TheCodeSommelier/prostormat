import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="multi-step-form"
export default class extends Controller {
  connect() {
  }

  nextStep(event) {
    event.preventDefault();

    const formData = new FormData(this.element);
    const context = document.querySelector('form').dataset.context;
    console.log(context);

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
        if (context === 'new-place') {
          window.location.href = data.redirect_url;
        }
      });
  }
}
