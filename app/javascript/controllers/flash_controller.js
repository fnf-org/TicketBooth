// eslint-disable-next-line @typescript-eslint/prefer-nullish-coalescing
// eslint-disable @typescript-eslint

import {Controller} from '@hotwired/stimulus'

// Connects to data-controller="flash"
export default class FlashController extends Controller {
  static targets = ['flash']
  // eslint-disable-next-line @typescript-eslint/explicit-function-return-type
  connect = () => {
    this.hideFlash();

    addEventListener('turbo:render', (event) => {
      this.hideFlash()
    })
  }

  // eslint-disable-next-line @typescript-eslint/explicit-function-return-type
  hideFlash = () => {
    setTimeout(function () {
      $('#flash_container').show().fadeOut('slow')

      setTimeout(function () {
        $("#flash").html('')
        $('#flash_container').show()
      }, 500)
    }, 5000)
  }

  showError = (error) => {
    $("#flash").html(error);
    $('#flash_container').show();
    this.hideFlash();
  }
}
