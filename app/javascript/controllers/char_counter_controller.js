import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="char-counter"
export default class extends Controller {
  static targets = ["textarea", "counter"];
  static values = { max: Number };

  connect() {
    this.#updateCounter();
  }

  #updateCounter() {
    this.textareaTargets.forEach((textarea, index) => {
      const counter = this.counterTargets[index];
      const maxChars = this.maxValue;
      const charCount = textarea.value.length;
      counter.textContent = `${charCount}/${maxChars}`;
      this.#counter(textarea, charCount, maxChars, counter);
    });
  }

  count() {
    this.#updateCounter();
  }

  #counter(textarea, charCount, maxChars, counter) {
    if (textarea.id === 'place_long_description') {
      this.#setStyle(textarea, charCount, maxChars, counter, true)
    } else {
      this.#setStyle(textarea, charCount, maxChars, counter, false)
    }
  }

  #setStyle(textarea, charCount, maxChars, counter, shouldGoOver) {
    console.log(charCount);
    if (charCount < maxChars && shouldGoOver) {
      console.log("If ran");
      textarea.style.borderBottom = "red 3px solid";
      counter.style.color = "red";
      textarea.value = textarea.value.substring(0, maxChars);
      counter.textContent = `Musí být přes ${maxChars} znaků máte ${charCount}`;
    } else if (charCount < 10 && !shouldGoOver) {
      textarea.style.borderBottom = "red 3px solid";
      counter.style.color = "red";
      textarea.value = textarea.value.substring(0, maxChars);
      counter.textContent = `${charCount}/${maxChars}`;
    } else if (charCount > maxChars && !shouldGoOver) {
      console.log("else if ran");
      textarea.style.borderBottom = "red 3px solid";
      counter.style.color = "red";
      textarea.value = textarea.value.substring(0, maxChars);
      counter.textContent = `${maxChars}/${maxChars}`;
    } else {
      console.log("else ran");
      textarea.style.borderBottom = "3px solid #26A387";
      counter.style.color = "#888";
    }
  }
}
