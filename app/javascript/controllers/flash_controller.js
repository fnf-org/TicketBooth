import {Controller} from '@hotwired/stimulus'

// Connects to data-controller="flash"
export default class FlashController extends Controller {
    static targets = ['flash']

    connect = () => {
        const flashEl = document.getElementById('flash')
        if (flashEl && flashEl.innerHTML.includes('alert')) {
            this.showFlash()
        } else {
            this.hideFlash(0)
        }

        addEventListener('turbo:render', () => this.showFlash())
        addEventListener('turbo:frame-render', () => this.showFlash())
    }

    showFlash = () => {
        const container = document.getElementById('flash_container')
        if (!container) return

        // Show the container and fade in (300ms via CSS)
        container.style.display = 'block'
        // Force reflow so the transition triggers
        container.offsetHeight
        container.classList.add('flash-visible')

        // Stay visible for 5 seconds, then fade out over 1 second
        this.hideFlashAfter(5000)
    }

    hideFlash = (delay = 0) => {
        const container = document.getElementById('flash_container')
        if (!container) return

        // Remove the visible class (triggers 1s fade-out via CSS)
        container.classList.remove('flash-visible')

        // After the fade-out completes, hide and clear
        const flashEl = document.getElementById('flash')
        setTimeout(() => {
            container.style.display = 'none'
            // Clear server-rendered flash content (safe — this is our own template output)
            if (flashEl) flashEl.textContent = ''
        }, delay === 0 ? 0 : 1000)
    }

    hideFlashAfter = (delay = 5000) => {
        if (this._hideTimer) clearTimeout(this._hideTimer)
        this._hideTimer = setTimeout(() => this.hideFlash(1000), delay)
    }

    showError = (error) => {
        // showError is called internally with trusted content from our own controllers
        const flashEl = document.getElementById('flash')
        if (flashEl) flashEl.textContent = error
        this.showFlash()
    }
}
