import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="overload-timer"
export default class extends Controller {
  static targets = ["timerMessage", "timer"];

  connect() {
    this.#countDown()
  }

  #countDown() {
    let timeLeft = 60;
    this.timerTarget.textContent = `${timeLeft}s`;

    let timerId = setInterval(() => {
      timeLeft--;
      this.timerTarget.textContent = `${timeLeft}s`;

      if (timeLeft <= 0) {
        clearInterval(timerId);
        window.location.href = "/"
        this.timerMessageTarget.textContent = "Zkuste znovu načíst stránku posím!";
      }
    }, 1000);
  }
}
