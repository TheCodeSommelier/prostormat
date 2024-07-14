import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="datepickr"
export default class extends Controller {
  static targets = [
    "datepickr",
    "dateTable",
    "year",
    "month",
    "day",
    "dateHiddenInput",
  ];

  connect() {
    this.populateYearSelect();
    this.populateMonthSelect();
    this.yearTarget.addEventListener("change", this.pickedMonth.bind(this));
    this.monthTarget.addEventListener("change", this.pickedMonth.bind(this));
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
    const oldDay = this.dateTableTarget.querySelector(".active") || null;
    if (oldDay) oldDay.classList.remove("active");
    day.classList.add("active");
    const formattedDate = `${this.yearTarget.value}-${this.monthTarget.value}-${day.dataset.day}`;
    this.dateHiddenInputTarget.value = formattedDate;
    this.#changeLabel(day);
  }

  preventHideOnSlect(event) {
    event.stopPropagation();
  }

  pickedMonth() {
    const monthDaysObject = this.#createMonthDaysObject();
    const pickedDay = this.datepickrTarget.querySelector(".active") || null;
    const day = pickedDay;
    const key = `${
      this.monthTarget.options[this.monthTarget.selectedIndex].text
    }`;
    const numDays = monthDaysObject[key];
    this.#createDays(numDays);
    this.#changeLabel(day);
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
      "Leden",
      "Únor",
      "Březen",
      "Duben",
      "Květen",
      "Červen",
      "Červenec",
      "Srpen",
      "Září",
      "Říjen",
      "Listopad",
      "Prosinec",
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

  populateMonthSelect() {
    const monthsNum = [
      "01",
      "02",
      "03",
      "04",
      "05",
      "06",
      "07",
      "08",
      "09",
      "10",
      "11",
      "12",
    ];
    const monthNames = [
      "Leden",
      "Únor",
      "Březen",
      "Duben",
      "Květen",
      "Červen",
      "Červenec",
      "Srpen",
      "Září",
      "Říjen",
      "Listopad",
      "Prosinec",
    ];
    monthNames.forEach((monthName, index) => {
      const option = document.createElement("option");
      option.value = monthsNum[index];
      option.text = monthName;
      this.monthTarget.add(option);
    });
  }
}
