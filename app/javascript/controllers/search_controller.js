import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ['searchTextField']

  connect() {
    console.log('Hi')
  }

  startSearch(event) {
    const query = this.searchTextFieldTarget.value;

    if (['Shift', 'Meta', 'Control', 'Alt'].includes(event.key)) {
      return;
    }

    fetch(`/places?query=${encodeURIComponent(query)}`,{
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      return response.json();
    })
    .then(data => {
      this.updateCardGrid(data.html)
    })
    .catch(error => console.error('Error:', error));
  }

  updateCardGrid(html) {
    const cardGridContainer = document.querySelector('#index-card-grid');
    console.log(cardGridContainer)
    if (cardGridContainer) {
      cardGridContainer.innerHTML = html;
    }
  }
}
