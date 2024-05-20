import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="popovers"
export default class PopoversController extends Controller {
  connect() {
    const popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
    const popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
      return new bootstrap.Popover(popoverTriggerEl)
    });
    // $(function () {
    //   $('[data-toggle="popover"]').popover({container: 'body'})
    // })
  }
}
