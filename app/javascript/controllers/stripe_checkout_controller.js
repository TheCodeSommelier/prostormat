import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="stripe-checkout"
export default class extends Controller {
  async connect() {
    console.log("Stripe over here!");
    const publicKey = this.element.dataset.stripePublicKey;
    const stripe = Stripe(publicKey);
    // const cardNumberStyle = {
    //   base: {
    //     color: "#32325d",
    //     fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
    //     fontSmoothing: "antialiased",
    //     fontSize: "16px",
    //     "::placeholder": {
    //       color: "#aab7c4"
    //     }
    //   },
    //   invalid: {
    //     color: "#fa755a",
    //     iconColor: "#fa755a"
    //   }
    // };
    let elements;

    const clientSecret = await this.fetchClientSecret(stripe);
    if (!clientSecret) {
      console.error("Client secret was not fetched successfully.");
      return;
    }

    elements = stripe.elements({ clientSecret: clientSecret });

    // const cardNumberElement = elements.create("cardNumber", { style: cardNumberStyle });
    // const cardExpiry = elements.create("cardExpiry");
    // const cvcElement = elements.create("cardCvc");
    // cardNumberElement.mount("#card-number");
    // cardExpiry.mount('#card-expiry')
    // cvcElement.mount('#card-cvc');

    const paymentElement = elements.create("payment");
    paymentElement.mount("#payment-element-display");
    this.setupForm(stripe, elements);
  }

  async fetchClientSecret(stripe) {
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

  setupForm(stripe, elements) {
    const form = document.querySelector("#payment-form");
    form.addEventListener("submit", async (e) => {
      e.preventDefault();

      // const { paymentMethod } = await stripe.createPaymentMethod({
      //   type: "card",
      //   card: elements.getElement("card"),
      // });

      const { setupIntent, error } = await stripe.confirmSetup({
        elements,
        redirect: 'if_required',
        confirmParams: {
          // return_url: window.location.href.split('?') + 'complete',
        },
      });

      if (error) {
        const errorMessages = document.getElementById("error-messages");
        errorMessages.innerText = error.message;
      } else if (setupIntent && setupIntent.status === "succeeded") {
        await this.subscribeCustomer(setupIntent.payment_method);
        window.location.href = window.location.href.split("?") + "complete";
      }
    });
  }

  subscribeCustomer(paymentMethodId) {
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
        console.log(data);
      });
  }
}

// const { paymentMethod, error } = await stripe.createPaymentMethod({
//   type: 'card',
//   card: elements.getElement('payment'),
// });

// if (error) {
//   console.error('Error creating payment method:', error);
//   const errorMessages = document.getElementById("error-messages");
//   errorMessages.innerText = error.message;
// } else {
//   // Submit paymentMethod.id and any other info to your server
//   fetch('create-subscription', {
//     method: 'POST',
//     headers: {
//       'Content-Type': 'application/json',
//       'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
//     },
//     body: JSON.stringify({ payment_method_id: paymentMethod.id })
//   }).then(async (response) => {
//     const { error } = await stripe.confirmCardSetup(
//       clientSecret,
//       {
//         payment_method: {
//           card: elements.getElement('payment'),
//         },
//       },
//       {
//         return_url: response.return_url
//       }
//       );
//     if (error) {
//       const errorMessages = document.getElementById("error-messages");
//       errorMessages.innerText = error.message;
//     }
//   }).catch(error => {
//     console.error('Error submitting payment method to server:', error);
//   });
// }

// old code

// const { error } = await stripe.confirmSetup({
//   elements,
//   confirmParams: {
//     return_url: `${window.location.origin}/stripe/checkout/success`,
//   },
// });

// if (error) {
//   const errorMessages = document.getElementById("error-messages");
//   errorMessages.innerText = error.message;
// }
// });
