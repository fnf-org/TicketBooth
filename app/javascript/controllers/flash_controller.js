// eslint-disable-next-line @typescript-eslint/prefer-nullish-coalescing
// eslint-disable @typescript-eslint

import {Controller} from '@hotwired/stimulus'

// Connects to data-controller="flash"
export default class FlashController extends Controller {
    static targets = ['flash']
    // eslint-disable-next-line @typescript-eslint/explicit-function-return-type
    connect = () => {
        // .alert only appears if the contents has a message
        if ($('#flash').html().includes('alert')) {
            this.showFlash()
        } else {
            this.hideFlash()
        }

        addEventListener('turbo:render', (event) => {
            this.showFlash()
        })
        addEventListener('turbo:frame-render', (event) => {
            this.showFlash()
        })
    }

    showFlash = () => {
        $('#flash_container').show('fast')
        this.hideFlashAfter()
    }

    // eslint-disable-next-line @typescript-eslint/explicit-function-return-type
    hideFlash = () => {
        $("#flash").html('')
        $('#flash_container').hide('fast')
    }

    // eslint-disable-next-line @typescript-eslint/explicit-function-return-type
    hideFlashAfter = (delay = 3000) => {
        const self = this
        setTimeout(function () {
            self.hideFlash()
        }, delay)
    }

    showError = (error) => {
        $("#flash").html(error)
        this.showFlash()
    }
}
