export default class Validator {
  static validateCustomSelect() {
    const customSelect = document.querySelector(".custom-select");
    const numSelectItems = customSelect.querySelectorAll(".highlight");
    return {
      isValid: numSelectItems && numSelectItems.length >= 1,
      message: numSelectItems && numSelectItems.length >= 1 ? "" : "Vyberte prosím alespoň jeden filtr."
    };
  }

  static validateDatepickr(datepickr) {
    if (!datepickr) {
      return {
        isValid: false,
        message: "Datepicker element not found"
      };
    }

    const daySelected = datepickr.querySelector(".active")?.dataset.day;
    const monthSelected = datepickr.querySelector(".monthSelect")?.value;
    const yearSelected = datepickr.querySelector(".yearSelect")?.value;

    if (!daySelected || !monthSelected || !yearSelected) {
      return {
        isValid: false,
        message: "Vyberte prosím platné datum"
      };
    }

    const dateSelected = new Date(yearSelected, monthSelected - 1, daySelected);
    const isValid = this.#validateDate(dateSelected);

    return {
      isValid: isValid,
      message: isValid ? "" : "Vyberte prosím datum v budoucnu"
    };
  }

  static setFlashMessage(form, message) {
    const flashMessage = `
      <div class="alert alert-dismissible fade show m-1 flash-alert-container" role="alert">
        <h5>Prosím opravte tyto údaje</h5>
        <br>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        <li>${message}</li>
      </div>
    `;
    form.insertAdjacentHTML("beforeend", flashMessage);
  }

  static dispatchValidationFailed(form) {
    const validationFailedEv = new Event('validationFailed');
    form.dispatchEvent(validationFailedEv);
  }

  static dispatchValidationPassed(form) {
    const validationFailedEv = new Event('validationPassed');
    form.dispatchEvent(validationFailedEv);
  }

  static validateFileInput(fileInput) {
    const numFiles = fileInput.files.length;
    return {
      isValid: numFiles >= 3,
      message: numFiles && numFiles >= 3 ? "" : "Vyberte prosím alespoň 3 fotky"
    };
  }

  // Private

  static #validateDate(dateSelected) {
    const dateToday = new Date();
    return dateSelected > dateToday;
  }
}
