import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gallery"
export default class extends Controller {
  static targets = ["display"]

  connect() {
    console.log('image gallery controller connected')
  }

  display() {
    this.displayTarget.src = event.currentTarget.src
  }
}
