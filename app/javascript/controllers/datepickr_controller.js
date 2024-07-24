import { Controller } from "@hotwired/stimulus";
import Validator from "modules/validator";

// Connects to data-controller="datepickr"
export default class extends Controller {
  static targets = ["datepickr", "dateTable", "year", "month", "day", "dateHiddenInput"];

  connect() {
    this.populateYearSelect();
    this.handleInitialMonthSelect();
    this.yearTarget.addEventListener("change", this.pickedYear.bind(this));
    this.monthTarget.addEventListener("change", this.pickedMonth.bind(this));
    document.addEventListener("click", this.handleDocumentClick.bind(this));
    this.datepickrTarget.querySelector(".custom-label").innerText = "Datum";
    this.datepickrTarget.querySelector(".custom-label").style.color = "#757575";
  }

  disconnect() {
    document.removeEventListener("click", this.handleDocumentClick.bind(this));
  }

  handleInitialMonthSelect() {
    const currentYear = new Date().getFullYear();
    const currentMonth = new Date().getMonth();

    // Set the initial year select value to the current year
    this.yearTarget.value = currentYear;

    // Populate months starting from the current month for the current year
    this.populateMonthSelect(currentMonth);

    // Update days for the initial month
    this.pickedMonth();
  }

  showDatepickr(event) {
    event.stopPropagation();
    const dateTableVisible =
      this.dateTableTarget.classList.contains("active-datepickr");
    this.dateTableTarget.className = dateTableVisible
      ? "inactive-datepickr"
      : "active-datepickr";
    if (!this.dateTableTarget.querySelector(".day-input")) this.#createDays(31);
  }

  selectDate(event) {
    event.stopPropagation();
    const day = event.target;
    const oldDay = this.dateTableTarget.querySelector(".active");
    if (oldDay) oldDay.classList.remove("active");
    day.classList.add("active");
    this.changeHiddenInputValue(day);
    this.#changeLabel(day);
    this.#validateDateData();
  }

  changeHiddenInputValue(day) {
    const formattedDate = `${this.yearTarget.value}-${this.monthTarget.value}-${day.dataset.day}`;
    this.dateHiddenInputTarget.value = formattedDate;
  }

  preventHideOnSlect(event) {
    event.stopPropagation();
  }

  pickedMonth() {
    const monthDaysObject = this.#createMonthDaysObject();
    const key = `${this.monthTarget.options[this.monthTarget.selectedIndex].text}`;
    const numDays = monthDaysObject[key];
    this.#createDays(numDays);
    const activeDay = this.dateTableTarget.querySelector(".active") || this.dateTableTarget.querySelector(".day-input");
    this.changeHiddenInputValue(activeDay);
    this.#changeLabel(activeDay);
  }

  pickedYear() {
    const currentYear = new Date().getFullYear();
    const selectedYear = parseInt(this.yearTarget.value, 10);

    if (selectedYear === currentYear) {
      const currentMonth = new Date().getMonth();
      this.populateMonthSelect(currentMonth);
    } else {
      this.populateMonthSelect(0, true);
    }
    this.pickedMonth();
  }


  handleDocumentClick(event) {
    if (!this.element.contains(event.target)) {
      this.dateTableTarget.className = "inactive-datepickr";
    }
  }

  #changeLabel(day) {
    const displayDate = `${day ? day.dataset.day : "01"}/${this.monthTarget.value}/${this.yearTarget.value}`;
    const label = this.datepickrTarget.querySelector(".custom-label");
    label.innerText = `${displayDate}`;
    label.style.color = "#252625";
  }

  #createDays(numDays) {
    const existingDayInputs =
      this.dateTableTarget.querySelectorAll(".day-input").length;

    if (existingDayInputs < numDays) {
      for (let i = existingDayInputs; i < numDays; i++) {
        const dayInput = document.createElement("div");
        dayInput.className = "day-input";
        dayInput.dataset.action = "click->datepickr#selectDate";
        dayInput.dataset.day = i < 9 ? `0${i + 1}` : `${i + 1}`;
        dayInput.innerText = `${i + 1}`;
        this.dateTableTarget.appendChild(dayInput);
      }
    } else if (existingDayInputs > numDays) {
      for (let i = existingDayInputs; i > numDays; i--) {
        const dayInput = this.dateTableTarget.querySelector(
          `.day-input[data-day='${i}']`
        );
        if (dayInput) this.dateTableTarget.removeChild(dayInput);
      }
    }
  }

  #createMonthDaysObject() {
    const monthNames = [
      "Leden", "Únor", "Březen", "Duben", "Květen", "Červen",
      "Červenec", "Srpen", "Září", "Říjen", "Listopad", "Prosinec"
    ];

    const currentYear = this.yearTarget.value;
    const monthDays = {};

    monthNames.forEach((month, index) => {
      monthDays[month] = new Date(currentYear, index + 1, 0).getDate();
    });

    return monthDays;
  }

  populateYearSelect() {
    const currentYear = new Date().getFullYear();
    for (let i = currentYear; i <= currentYear + 10; i++) {
      const option = document.createElement("option");
      option.value = i;
      option.text = i;
      this.yearTarget.add(option);
    }
  }

  populateMonthSelect(startMonth = 0, showAllMonths = false) {
    this.monthTarget.innerHTML = "";
    const monthsNum = [
      "01", "02", "03", "04", "05", "06",
      "07", "08", "09", "10", "11", "12",
    ];
    const monthNames = [
      "Leden", "Únor", "Březen", "Duben", "Květen", "Červen",
      "Červenec", "Srpen", "Září", "Říjen", "Listopad", "Prosinec"
    ];

    const endMonth = showAllMonths ? 12 : 12 - startMonth;

    for (let i = 0; i < endMonth; i++) {
      const monthIndex = (startMonth + i) % 12;
      const option = document.createElement("option");
      option.value = monthsNum[monthIndex];
      option.text = monthNames[monthIndex];
      this.monthTarget.add(option);
    }
  }

  // Needs to be on show and where ever are date inputs
  #validateDateData() {
    const dateValidObject = Validator.validateDatepickr(this.datepickrTarget);
    const styling = dateValidObject.isValid
    ? "3px solid #26A387"
    : "3px solid #ff0000";
    console.log("Valid? ", dateValidObject.isValid);
    console.log("Message? ", dateValidObject.message);
    console.log(this.datepickrTarget);
    this.datepickrTarget.style.borderBottom = styling;
    return dateValidObject.isValid;
  }
}
