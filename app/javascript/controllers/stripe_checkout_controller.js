import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="stripe-checkout"
export default class extends Controller {
  connect() {
    console.log('Stripe over here!')
  }
}
