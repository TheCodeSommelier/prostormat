import { Controller } from "@hotwired/stimulus"
import FormUtils from "modules/form_utils";

export default class extends Controller {
  static targets = ["form", "submit", "turnstileResponse", "turViContainer"]
  static values = {
    sitekey: String,
    sitekeyVisible: String
  }

  connect() {
    this.submitTarget.disabled = true;
    this.#renderInvisibleTurnstile();
  }

  disconnect() {
    document.cookie = "invisible_turnstile_verified=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
  }

  onTurnstileError() {
    this.submitTarget.disabled = true;
    this.#stopLoading();
  }

  // Private

  #onVisibleTurnstileSuccess(token) {
    this.turnstileResponseTarget.value = token;
    this.submitTarget.disabled = false;
    this.#stopLoading();
  }

  #renderInvisibleTurnstile() {
    turnstile.ready(() => {
      turnstile.render(this.element, {
        sitekey: this.sitekeyValue,
        callback: (token) => this.#verifyInvisibleToken(token),
        size: 'invisible'
      })
    })
  }

  #verifyInvisibleToken(token) {
    fetch('/verify-turnstile', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ token: token })
    })
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return response.json();
    })
    .then(data => {
      this.isVerifiedInvisible = data.success;
      if (this.isVerifiedInvisible) {
        this.submitTarget.disabled = false;
      } else {
        this.#renderVisibleTurnstile();
      }
    })
    .catch(error => {
      console.error('Error details:', error);
    });
  }

  #renderVisibleTurnstile() {
    if (this.isVerifiedInvisible) this.isVerifiedInvisible = false;
    document.cookie = "invisible_turnstile_verified=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
    const turnstileVisibleInput = FormUtils.buildInput("hidden", "turnStileVisible", "true", null, null)
    this.element.appendChild(turnstileVisibleInput);
    this.turViContainerTarget.style.margin = "15px 15px 0";
    turnstile.ready(() => {
      turnstile.render(this.turViContainerTarget, {
        sitekey: this.sitekeyVisibleValue,
        theme: 'light',
        callback: (token) => this.#onVisibleTurnstileSuccess(token),
        'error-callback': () => this.onTurnstileError()
      });
    });
  }

  #stopLoading() {
    const loaderController = this.application.getControllerForElementAndIdentifier(this.element, 'loader');
    if (loaderController) {
      loaderController.stopLoading();
    }
  }
}
