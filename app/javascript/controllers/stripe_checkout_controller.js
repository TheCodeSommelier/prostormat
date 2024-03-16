import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="stripe-checkout"
export default class extends Controller {
  async connect() {
    const publicKey    = this.element.dataset.stripePublicKey;
    const stripe       = Stripe(publicKey);
    const clientSecret = await this.#fetchClientSecret(stripe);
    let elements;

    if (!clientSecret) {
      console.error("Client secret was not fetched successfully.");
      return;
    }

    elements             = stripe.elements({ clientSecret: clientSecret });
    const paymentElement = elements.create("payment");

    paymentElement.mount("#payment-element-display");
    this.#setupForm(stripe, elements);
  }

  async #fetchClientSecret(stripe) {
    try {
      const response = await fetch("create-setup-intent", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
        },
      });
      const data = await response.json();
      return data.clientSecret;
    } catch (error) {
      console.error("Error fetching client secret:", error);
    }
  }

  #setupForm(stripe, elements) {
    const form = document.querySelector("#payment-form");
    form.addEventListener("submit", async (e) => {
      e.preventDefault();

      const { setupIntent, error } = await stripe.confirmSetup({
        elements,
        redirect: 'if_required',
        confirmParams: {
          // return_url: window.location.href.split('?') + 'complete', // Needs to be here but commented out otherwise the whole things come crumbling down...
        },
      });

      if (error) {
        const errorMessages     = document.getElementById("error-messages");
        errorMessages.innerText = error.message;
      } else if (setupIntent && setupIntent.status === "succeeded") {
        await this.#subscribeCustomer(setupIntent.payment_method);
        window.location.href = window.location.href.split("?") + "complete";
      }
    });
  }

  #subscribeCustomer(paymentMethodId) {
    fetch("create-subscription", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
      },
      body: JSON.stringify({ payment_method_id: paymentMethodId }),
    })
      .then((response) => response.json())
      .then((data) => {
      });
  }
}
