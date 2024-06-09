import { Controller } from "@hotwired/stimulus"

// Upon load intilizes the count down from 60 sec to 0 sec when it reaches 0 redirects to the root path

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
        this.timerMessageTarget.innerHTML = '<p>Pokud jste nebyli přesměrování automaticky klikněte <a href="/">zde</a></p>';
      }
    }, 1000);
  }
}
