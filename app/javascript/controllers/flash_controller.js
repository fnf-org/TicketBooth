import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class flashController extends Controller {
  static targets = [ "flash" ]

  connect() {
    addEventListener("turbo:render", (event) => {
      this.hideFlash()
    })
    addEventListener("turbo:before-stream-render", (event) => {
      this.hideFlash()
    })
  }

  hideFlash() {
    setTimeout(function () {
      $('#flash_container').fadeOut('500');
      setTimeout(function () {
        $('#flash').html("");
        $('#flash_container').show();
      }, 500);

    }, 5000);
  }
}
